-- Intermediate: Refund Events

CREATE SCHEMA IF NOT EXISTS intermediate;

CREATE OR REPLACE VIEW intermediate.int_refund_events AS
SELECT
    'REFUND' AS event_type,
    r.refund_id AS source_id,
    r.order_id,

    CAST(r.refund_at_la AS DATE) AS event_date,
    r.refund_at_la AS event_timestamp,

    -o.revenue_usd AS revenue,
    CAST(0 AS DECIMAL(38,6)) AS cost,

    -(
        (o.revenue_usd - o.point_amount_usd)
        * (f.fee_percent / 100.0)
    ) AS payment_fee,

    COALESCE(-o.revenue_usd, 0)
        + COALESCE(
            (o.revenue_usd - o.point_amount_usd)
            * (f.fee_percent / 100.0),
            0
        ) AS profit,

    o.payment_provider,
    o.customer_platform_type

FROM staging.stg_refunds r
LEFT JOIN staging.stg_orders o
    ON r.order_id = o.id
LEFT JOIN staging.stg_payment_provider_fee f
    ON o.customer_platform_type = f.platform_type
   AND o.payment_provider = f.payment_provider
   AND f.status = 'active'

WITH NO SCHEMA BINDING;
