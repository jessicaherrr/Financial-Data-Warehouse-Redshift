-- Mart: BI-Ready Daily Financial Reporting View
-- Adds current metrics, MoM, YoY, differences, percentage changes, and rates.

CREATE SCHEMA IF NOT EXISTS mart;

CREATE OR REPLACE VIEW mart.daily_financial_report AS
SELECT
    cur.event_date,
    TO_CHAR(cur.event_date, 'YYYY-MM-DD') AS sold_date_string,
    cur.days_in_month,

    -- Current metrics.
    cur.revenue AS current_revenue,
    cur.cost AS current_cost,
    cur.gross_profit,
    cur.gross_profit / NULLIF(cur.revenue, 0) AS gross_profit_rate,
    cur.payment_fee AS current_payment_fee,
    cur.profit AS current_profit,

    -- Revenue: last month and last year.
    COALESCE(lm.revenue, 0) AS lastmonth_revenue,
    cur.revenue - COALESCE(lm.revenue, 0) AS diff_lastmonth_revenue,
    (cur.revenue - lm.revenue) / NULLIF(lm.revenue, 0) AS diff_lastmonth_revenue_pct,

    COALESCE(ly.revenue, 0) AS lastyear_revenue,
    cur.revenue - COALESCE(ly.revenue, 0) AS diff_lastyear_revenue,
    (cur.revenue - ly.revenue) / NULLIF(ly.revenue, 0) AS diff_lastyear_revenue_pct,

    -- Cost: last month and last year.
    COALESCE(lm.cost, 0) AS lastmonth_cost,
    cur.cost - COALESCE(lm.cost, 0) AS diff_lastmonth_cost,
    (cur.cost - lm.cost) / NULLIF(lm.cost, 0) AS diff_lastmonth_cost_pct,

    COALESCE(ly.cost, 0) AS lastyear_cost,
    cur.cost - COALESCE(ly.cost, 0) AS diff_lastyear_cost,
    (cur.cost - ly.cost) / NULLIF(ly.cost, 0) AS diff_lastyear_cost_pct,

    -- Gross profit: last month and last year.
    COALESCE(lm.gross_profit, 0) AS lastmonth_gprofit,
    cur.gross_profit - COALESCE(lm.gross_profit, 0) AS diff_lastmonth_gprofit,
    (cur.gross_profit - lm.gross_profit)
        / NULLIF(lm.gross_profit, 0) AS diff_lastmonth_gprofit_pct,
    lm.gross_profit / NULLIF(lm.revenue, 0) AS lastmonth_gprofit_rate,

    COALESCE(ly.gross_profit, 0) AS lastyear_gprofit,
    cur.gross_profit - COALESCE(ly.gross_profit, 0) AS diff_lastyear_gprofit,
    (cur.gross_profit - ly.gross_profit)
        / NULLIF(ly.gross_profit, 0) AS diff_lastyear_gprofit_pct,
    ly.gross_profit / NULLIF(ly.revenue, 0) AS lastyear_gprofit_rate,

    -- Expense is the existing BI label for payment fee.
    COALESCE(lm.payment_fee, 0) AS lastmonth_expense,
    cur.payment_fee - COALESCE(lm.payment_fee, 0) AS diff_lastmonth_expense,
    (cur.payment_fee - lm.payment_fee)
        / NULLIF(lm.payment_fee, 0) AS diff_lastmonth_expense_pct,

    COALESCE(ly.payment_fee, 0) AS lastyear_expense,
    cur.payment_fee - COALESCE(ly.payment_fee, 0) AS diff_lastyear_expense,
    (cur.payment_fee - ly.payment_fee)
        / NULLIF(ly.payment_fee, 0) AS diff_lastyear_expense_pct,

    -- Profit: last month and last year.
    COALESCE(lm.profit, 0) AS lastmonth_profit,
    cur.profit - COALESCE(lm.profit, 0) AS diff_lastmonth_profit,
    (cur.profit - lm.profit)
        / NULLIF(lm.profit, 0) AS diff_lastmonth_profit_pct,

    COALESCE(ly.profit, 0) AS lastyear_profit,
    cur.profit - COALESCE(ly.profit, 0) AS diff_lastyear_profit,
    (cur.profit - ly.profit)
        / NULLIF(ly.profit, 0) AS diff_lastyear_profit_pct

FROM mart.daily_financial cur
LEFT JOIN mart.daily_financial lm
    ON lm.event_date = DATEADD(month, -1, cur.event_date)
LEFT JOIN mart.daily_financial ly
    ON ly.event_date = DATEADD(year, -1, cur.event_date)
WITH NO SCHEMA BINDING;
