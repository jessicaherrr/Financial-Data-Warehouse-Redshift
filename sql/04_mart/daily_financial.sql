-- Mart: Daily Financial Aggregate

CREATE SCHEMA IF NOT EXISTS mart;

CREATE TABLE IF NOT EXISTS mart.daily_financial (
    event_date     DATE,
    days_in_month  INTEGER,
    revenue        DECIMAL(38,6),
    cost           DECIMAL(38,6),
    payment_fee    DECIMAL(38,6),
    profit         DECIMAL(38,6),
    gross_profit   DECIMAL(38,6)
);

TRUNCATE TABLE mart.daily_financial;

INSERT INTO mart.daily_financial (
    event_date,
    days_in_month,
    revenue,
    cost,
    payment_fee,
    profit,
    gross_profit
)
SELECT
    event_date,
    EXTRACT(DAY FROM LAST_DAY(event_date))::INTEGER AS days_in_month,
    SUM(revenue) AS revenue,
    SUM(cost) AS cost,
    SUM(payment_fee) AS payment_fee,
    SUM(profit) AS profit,
    SUM(revenue) - SUM(cost) AS gross_profit
FROM fact.financial_event_fact
GROUP BY event_date;
