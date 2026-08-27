-- Intermediate: Regular Sale Events

CREATE SCHEMA IF NOT EXISTS intermediate;

CREATE OR REPLACE VIEW intermediate.int_regular_sales AS
SELECT
    'SALE' AS event_type,
    o.id AS source_id,
    o.id AS order_id,

    CAST(o.created_at_la AS DATE) AS event_date,
    o.created_at_la AS event_timestamp,

    o.revenue_usd AS revenue,
    o.cost_usd AS cost,

    (o.revenue_usd - o.point_amount_usd)
        * (f.fee_percent / 100.0) AS payment_fee,

    COALESCE(o.revenue_usd, 0)
        - COALESCE(o.cost_usd, 0)
        - COALESCE(
            (o.revenue_usd - o.point_amount_usd)
            * (f.fee_percent / 100.0),
            0
        ) AS profit,

    o.payment_provider,
    o.customer_platform_type

FROM staging.stg_orders o
LEFT JOIN staging.stg_payment_provider_fee f
    ON o.customer_platform_type = f.platform_type
   AND o.payment_provider = f.payment_provider
   AND f.status = 'active'

WHERE o.success_charge_data IS NOT NULL
  AND o.card_barcode_number IS NOT NULL

WITH NO SCHEMA BINDING;
