-- Staging: Orders
-- Replace source_db/source_schema with your own Redshift Zero-ETL destination.

CREATE SCHEMA IF NOT EXISTS staging;

CREATE OR REPLACE VIEW staging.stg_orders AS
SELECT
    id,

    -- Preserve source values for reconciliation.
    transaction_total_cost_usd AS transaction_total_cost_cents,
    COALESCE(point_amount, 0) AS point_amount_cents,

    -- Standardize monetary values.
    CAST(transaction_total_cost_usd AS DECIMAL(38,6)) / 100 AS revenue_usd,
    CAST(COALESCE(point_amount, 0) AS DECIMAL(38,6)) / 100 AS point_amount_usd,
    CAST(buy_card_total_cost AS DECIMAL(38,6)) AS cost_usd,

    payment_provider,
    customer_platform_type,

    success_charge_data,
    card_barcode_number,
    card_void,

    created_at,
    card_void_time,

    -- Standardize business timestamps to Los Angeles time.
    CONVERT_TIMEZONE('GMT', 'America/Los_Angeles', created_at) AS created_at_la,
    CONVERT_TIMEZONE('GMT', 'America/Los_Angeles', card_void_time) AS card_void_time_la

FROM "source_db"."source_schema"."orders"
WITH NO SCHEMA BINDING;
