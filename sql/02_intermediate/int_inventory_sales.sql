-- Intermediate: Inventory Sale Events

CREATE SCHEMA IF NOT EXISTS intermediate;

CREATE OR REPLACE VIEW intermediate.int_inventory_sales AS
SELECT
    'INVENTORY_SALE' AS event_type,
    i.id AS source_id,
    NULL::BIGINT AS order_id,

    CAST(i.assign_time_la AS DATE) AS event_date,
    i.assign_time_la AS event_timestamp,

    i.revenue_usd AS revenue,
    i.cost_usd AS cost,
    CAST(0 AS DECIMAL(38,6)) AS payment_fee,

    COALESCE(i.revenue_usd, 0)
        - COALESCE(i.cost_usd, 0) AS profit,

    NULL::VARCHAR(256) AS payment_provider,
    NULL::VARCHAR(256) AS customer_platform_type

FROM staging.stg_inventory_cards i
WHERE i.preorder_id IS NOT NULL
  AND i.card_barcode_number IS NOT NULL

WITH NO SCHEMA BINDING;
