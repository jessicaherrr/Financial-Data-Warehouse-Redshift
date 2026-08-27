-- Fact: Unified Financial Events
-- POC strategy: deterministic full rebuild from the latest source state.

CREATE SCHEMA IF NOT EXISTS fact;

CREATE TABLE IF NOT EXISTS fact.financial_event_fact (
    event_key              VARCHAR(100),
    event_type             VARCHAR(30),
    source_id              BIGINT,
    order_id               BIGINT,
    event_date             DATE,
    event_timestamp        TIMESTAMP,
    revenue                DECIMAL(38,6),
    cost                   DECIMAL(38,6),
    payment_fee            DECIMAL(38,6),
    profit                 DECIMAL(38,6),
    payment_provider       VARCHAR(256),
    customer_platform_type VARCHAR(256)
);

-- Full rebuild. Do not use this pattern for high-availability production refreshes
-- without considering an atomic table-swap or MERGE strategy.
TRUNCATE TABLE fact.financial_event_fact;

INSERT INTO fact.financial_event_fact (
    event_key,
    event_type,
    source_id,
    order_id,
    event_date,
    event_timestamp,
    revenue,
    cost,
    payment_fee,
    profit,
    payment_provider,
    customer_platform_type
)

SELECT
    'sale:' || source_id::VARCHAR AS event_key,
    event_type,
    source_id,
    order_id,
    event_date,
    event_timestamp,
    revenue,
    cost,
    payment_fee,
    profit,
    payment_provider,
    customer_platform_type
FROM intermediate.int_regular_sales

UNION ALL

SELECT
    'inventory_sale:' || source_id::VARCHAR AS event_key,
    event_type,
    source_id,
    order_id,
    event_date,
    event_timestamp,
    revenue,
    cost,
    payment_fee,
    profit,
    payment_provider,
    customer_platform_type
FROM intermediate.int_inventory_sales

UNION ALL

SELECT
    'void:' || source_id::VARCHAR AS event_key,
    event_type,
    source_id,
    order_id,
    event_date,
    event_timestamp,
    revenue,
    cost,
    payment_fee,
    profit,
    payment_provider,
    customer_platform_type
FROM intermediate.int_void_events

UNION ALL

SELECT
    'refund:' || source_id::VARCHAR AS event_key,
    event_type,
    source_id,
    order_id,
    event_date,
    event_timestamp,
    revenue,
    cost,
    payment_fee,
    profit,
    payment_provider,
    customer_platform_type
FROM intermediate.int_refund_events;
