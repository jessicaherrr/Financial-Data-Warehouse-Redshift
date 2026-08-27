-- Data Quality: Row Counts and Event-Date Completeness

-- 1. Eligible order count should match the regular-sale intermediate count.
SELECT
    (
        SELECT COUNT(*)
        FROM staging.stg_orders
        WHERE success_charge_data IS NOT NULL
          AND card_barcode_number IS NOT NULL
    ) AS eligible_source_orders,
    (
        SELECT COUNT(*)
        FROM intermediate.int_regular_sales
    ) AS intermediate_sales;

-- 2. Refund source count should match refund intermediate count.
SELECT
    (
        SELECT COUNT(*)
        FROM staging.stg_refunds
    ) AS source_refunds,
    (
        SELECT COUNT(*)
        FROM intermediate.int_refund_events
    ) AS intermediate_refunds;

-- 3. All modeled events should have a business event date.
SELECT
    event_type,
    COUNT(*) AS null_event_date_count
FROM (
    SELECT event_type, event_date FROM intermediate.int_regular_sales
    UNION ALL
    SELECT event_type, event_date FROM intermediate.int_inventory_sales
    UNION ALL
    SELECT event_type, event_date FROM intermediate.int_void_events
    UNION ALL
    SELECT event_type, event_date FROM intermediate.int_refund_events
) x
WHERE event_date IS NULL
GROUP BY event_type;

-- Expected: 0 rows.

-- 4. Event counts by type for reconciliation.
SELECT 'SALE' AS event_type, COUNT(*) AS row_count
FROM intermediate.int_regular_sales
UNION ALL
SELECT 'INVENTORY_SALE', COUNT(*)
FROM intermediate.int_inventory_sales
UNION ALL
SELECT 'VOID', COUNT(*)
FROM intermediate.int_void_events
UNION ALL
SELECT 'REFUND', COUNT(*)
FROM intermediate.int_refund_events;
