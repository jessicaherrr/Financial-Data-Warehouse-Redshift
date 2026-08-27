-- Intermediate: Void Events

CREATE SCHEMA IF NOT EXISTS intermediate;

CREATE OR REPLACE VIEW intermediate.int_void_events AS
SELECT
    'VOID' AS event_type,
    o.id AS source_id,
    o.id AS order_id,

    CAST(o.card_void_time_la AS DATE) AS event_date,
    o.card_void_time_la AS event_timestamp,

    CAST(0 AS DECIMAL(38,6)) AS revenue,
    -o.cost_usd AS cost,
    CAST(0 AS DECIMAL(38,6)) AS payment_fee,
    COALESCE(o.cost_usd, 0) AS profit,

    o.payment_provider,
    o.customer_platform_type

FROM staging.stg_orders o
WHERE o.success_charge_data IS NOT NULL
  AND o.card_barcode_number IS NOT NULL
  AND o.card_void = 1
  AND o.card_void_time_la IS NOT NULL

WITH NO SCHEMA BINDING;
