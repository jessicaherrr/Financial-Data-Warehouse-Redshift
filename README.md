# Financial-Data-Warehouse-Redshift
Financial data warehouse for revenue, cost, payment fee, gross profit, and profit reporting with MoM and YoY analysis on AWS using RDS, Zero-ETL, Redshift Serverless, and BI-ready financial marts.

## Overview

This project designs and implements a cloud-based financial data warehouse for operational and financial reporting.

The goal of this project was to move financial calculations into a centralized warehouse so that downstream BI tools could consume consistent, reusable metrics instead of repeatedly joining and transforming production tables.

The warehouse supports:

- Revenue
- Cost
- Payment processing fees
- Gross profit
- Profit
- Sales events
- Inventory sales
- Voids
- Refunds
- Daily reporting
- Month-over-month comparisons
- Year-over-year comparisons

## Architecture

```text
Amazon RDS
   ↓
RDS Read Replica
   ↓
Amazon Zero-ETL Integration
   ↓
Amazon Redshift Serverless
   ↓
Raw / Source Layer
   ↓
Staging
   ↓
Intermediate
   ↓
Financial Event Fact
   ↓
Daily Financial Mart
   ↓
Financial Reporting View
   ↓
Lark / BI / SQL Consumers
```


## Warehouse layers

### 1. Source / Raw

Zero-ETL replicates source-system tables into Redshift. This layer is not modified by business transformations.


### 2. Staging

Staging views standardize source fields while preserving business meaning:
- cents to USD
- UTC/GMT to `America/Los_Angeles`
- numeric precision
- source identifiers for reconciliation

Objects:

- `staging.stg_orders`
- `staging.stg_inventory_cards`
- `staging.stg_refunds`
- `staging.stg_payment_provider_fee`

### 3. Intermediate

Each intermediate view corresponds to one business event from the original reporting logic:

- `intermediate.int_regular_sales`
- `intermediate.int_inventory_sales`
- `intermediate.int_void_events`
- `intermediate.int_refund_events`

#### Regular sale

```text
Revenue     = transaction_total_cost / 100
Cost        = buy_card_total_cost
Payment Fee = (Revenue - Point Amount) * Fee Rate
Profit      = Revenue - Cost - Payment Fee
```

#### Inventory sale

```text
Revenue     = Revenue
Cost        = Cost
Payment Fee = 0
Profit      = Revenue - Cost
```

#### Void

```text
Revenue     = 0
Cost        = -Original Cost
Payment Fee = 0
Profit      = +Original Cost
```

#### Refund

```text
Revenue     = -Original Revenue
Cost        = 0
Payment Fee = -Original Payment Fee
Profit      = Revenue - Cost - Payment Fee
```

### 4. Fact

`fact.financial_event_fact` uses an event-level grain:

> One row = one financial event.

A single order can therefore create multiple events on different dates, such as a sale followed by a refund or void.



### 5. Mart

`mart.daily_financial` stores the daily aggregate:

```text
Revenue
Cost
Gross Profit
Payment Fee
Profit
```

with:

```text
Gross Profit = Revenue - Cost
Profit       = Gross Profit - Payment Fee
```

`mart.daily_financial_report` adds BI-ready comparison metrics including last-month, last-year, differences, percentage changes, and gross-profit rates.



## Source placeholders

The staging SQL uses the sanitized placeholder path:

```sql
"source_db"."source_schema"."orders"
```

Replace `source_db` and `source_schema` with the source database and schema in your own Redshift environment.



## Security model

Recommended access pattern:

```text
Developer / Administrator
  -> IAM authentication

BI service user
  -> read-only database login
  -> USAGE on mart schema
  -> SELECT only on approved mart tables/views
```

Example:

```sql
GRANT USAGE ON SCHEMA mart TO dashboard_readonly;
GRANT SELECT ON TABLE mart.daily_financial TO dashboard_readonly;
GRANT SELECT ON TABLE mart.daily_financial_report TO dashboard_readonly;
```

## Repository structure
```text
financial-data-warehouse-redshift/
├── README.md
├── architecture/
│   └── architecture_diagram.png
├── sql/
│   ├── 01_staging/
│   │   ├── stg_orders.sql
│   │   ├── stg_inventory_cards.sql
│   │   ├── stg_refunds.sql
│   │   └── stg_payment_provider_fee.sql
│   ├── 02_intermediate/
│   │   ├── int_regular_sales.sql
│   │   ├── int_inventory_sales.sql
│   │   ├── int_void_events.sql
│   │   └── int_refund_events.sql
│   ├── 03_fact/
│   │   └── financial_event_fact.sql
│   ├── 04_mart/
│   │   ├── daily_financial.sql
│   │   └── daily_financial_report.sql
│   └── 05_quality_checks/
│       ├── fee_uniqueness.sql
│       ├── row_count_validation.sql
│       └── profit_validation.sql
└── docs/
    └── data_model.md
```

## Disclaimer
This repository is a sanitized portfolio reconstruction. It contains no production credentials, customer information, internal infrastructure identifiers, proprietary datasets, or confidential company information.
