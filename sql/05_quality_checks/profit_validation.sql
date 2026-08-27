-- Data Quality: Fact-Level Financial Consistency

-- Unified event equation:
-- Profit = Revenue - Cost - Payment Fee
SELECT COUNT(*) AS inconsistent_profit_rows
FROM fact.financial_event_fact
WHERE ABS(
    COALESCE(profit, 0)
    - (
        COALESCE(revenue, 0)
        - COALESCE(cost, 0)
        - COALESCE(payment_fee, 0)
      )
) > 0.000001;

-- Expected: 0.

-- Optional aggregate reconciliation by event type.
SELECT
    event_type,
    COUNT(*) AS event_count,
    SUM(revenue) AS revenue,
    SUM(cost) AS cost,
    SUM(payment_fee) AS payment_fee,
    SUM(profit) AS profit
FROM fact.financial_event_fact
GROUP BY event_type
ORDER BY event_type;

-- Daily mart should contain one row per event date.
SELECT
    COUNT(*) AS total_days,
    MIN(event_date) AS first_date,
    MAX(event_date) AS latest_date
FROM mart.daily_financial;
