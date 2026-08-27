# Data Model

## Design objective

The model centralizes financial reporting logic in Redshift and keeps downstream BI tools focused on presentation rather than repeated joins and formulas.

## Grain

### Staging

Staging preserves source-system row grain while standardizing data types, monetary units, and timestamps.

### Intermediate

Each intermediate object represents one financial event class:

| Model | Grain | Source |
|---|---|---|
| `int_regular_sales` | one eligible sale/order | `orders` + active fee rule |
| `int_inventory_sales` | one eligible inventory-card sale | `inventory_cards` |
| `int_void_events` | one void event | `orders` |
| `int_refund_events` | one refund event | `order_refund_historys` + `orders` + active fee rule |

### Fact

`fact.financial_event_fact` uses one row per financial event.

An order may produce more than one fact row if it generates events at different times.

Example:

```text
sale:1001    SALE    2026-08-20
refund:812   REFUND  2026-08-25
```

This prevents a later refund or void from overwriting the date of the original sale.

## Event keys

```text
sale:{orders.id}
inventory_sale:{inventory_cards.id}
void:{orders.id}
refund:{order_refund_historys.id}
```

These keys are deterministic and suitable for a future incremental `MERGE` strategy.

## Measures

### Regular sale

```text
revenue     = transaction_total_cost_usd / 100
cost        = buy_card_total_cost
payment_fee = ((transaction_total_cost_usd - point_amount) / 100) * (fee / 100)
profit      = revenue - cost - payment_fee
```

### Inventory sale

```text
revenue     = transaction_total_cost_usd / 100
cost        = buy_card_total_cost
payment_fee = 0
profit      = revenue - cost
```

### Void

```text
revenue     = 0
cost        = -buy_card_total_cost
payment_fee = 0
profit      = +buy_card_total_cost
```

### Refund

```text
revenue     = -original_revenue
cost        = 0
payment_fee = -original_payment_fee
profit      = revenue - cost - payment_fee
```

## Unified accounting equation

Because event-direction signs are encoded in the fact measures, every event type follows:

```text
Profit = Revenue - Cost - Payment Fee
```

This allows downstream marts to use simple `SUM` aggregation without re-implementing refund or void logic.

## Time standard

All business event timestamps are normalized from GMT/UTC to:

```text
America/Los_Angeles
```

Daily aggregation uses the converted local event date.

Event timestamps:

| Event | Timestamp |
|---|---|
| Sale | `orders.created_at` |
| Inventory sale | `inventory_cards.assign_time` |
| Void | `orders.card_void_time` |
| Refund | `order_refund_historys.created_at` |

## Payment-fee mapping

Fee rules are joined with:

```text
orders.customer_platform_type = payment_provider_fee.platform_type
orders.payment_provider       = payment_provider_fee.payment_provider
payment_provider_fee.status   = 'active'
```

The join is intentionally a `LEFT JOIN` to preserve the existing reporting behavior. Unmatched fee rows therefore remain in the event model; payment fee may be null while profit logic treats the missing fee contribution as zero.

A data-quality check verifies that each provider/platform pair has at most one active rule so that the join cannot multiply order rows.

## Daily mart

`mart.daily_financial` aggregates the event fact by `event_date`:

```text
revenue        = SUM(revenue)
cost           = SUM(cost)
gross_profit   = SUM(revenue) - SUM(cost)
payment_fee    = SUM(payment_fee)
profit         = SUM(profit)
```

## Reporting view

`mart.daily_financial_report` adds comparison metrics by self-joining the daily mart to:

```text
current date - 1 month
current date - 1 year
```

The reporting view includes:

- current revenue/cost/gross profit/payment fee/profit
- last-month values
- last-year values
- absolute differences
- percentage differences
- gross-profit rates

`NULLIF(..., 0)` prevents division-by-zero errors in percentage calculations.

## Refresh model

The source layer is synchronized separately by Zero-ETL. Derived models do not create another source replication pipeline.

POC refresh:

```text
1. Zero-ETL updates raw/source tables.
2. Staging and intermediate views immediately reflect the latest source state.
3. Rebuild `fact.financial_event_fact` with TRUNCATE + INSERT.
4. Rebuild `mart.daily_financial` with TRUNCATE + INSERT.
5. `mart.daily_financial_report` automatically reflects the refreshed daily mart.
```

For production, replace the non-atomic POC rebuild with an atomic refresh pattern or incremental `MERGE` if required by uptime and scale.

## BI access boundary

BI users should read only curated mart objects. They should not receive write access to raw, staging, intermediate, or fact layers.

Recommended grants:

```sql
GRANT USAGE ON SCHEMA mart TO dashboard_readonly;
GRANT SELECT ON TABLE mart.daily_financial TO dashboard_readonly;
GRANT SELECT ON TABLE mart.daily_financial_report TO dashboard_readonly;
```
