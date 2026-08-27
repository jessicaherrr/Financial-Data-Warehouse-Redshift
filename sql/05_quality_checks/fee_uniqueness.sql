-- Data Quality: Active Fee Rule Uniqueness and Coverage

-- 1. There should not be multiple active rules for the same provider/platform.
SELECT
    payment_provider,
    platform_type,
    COUNT(*) AS active_rule_count
FROM staging.stg_payment_provider_fee
WHERE status = 'active'
GROUP BY payment_provider, platform_type
HAVING COUNT(*) > 1;

-- Expected: 0 rows.

-- 2. Diagnose eligible sales that do not match an active fee rule.
SELECT
    o.payment_provider,
    o.customer_platform_type,
    COUNT(*) AS unmatched_orders
FROM staging.stg_orders o
LEFT JOIN staging.stg_payment_provider_fee f
    ON o.customer_platform_type = f.platform_type
   AND o.payment_provider = f.payment_provider
   AND f.status = 'active'
WHERE o.success_charge_data IS NOT NULL
  AND o.card_barcode_number IS NOT NULL
  AND f.id IS NULL
GROUP BY o.payment_provider, o.customer_platform_type
ORDER BY unmatched_orders DESC;
