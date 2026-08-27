-- Staging: Inventory Cards
-- Replace source_db/source_schema with your own Redshift Zero-ETL destination.

CREATE SCHEMA IF NOT EXISTS staging;

CREATE OR REPLACE VIEW staging.stg_inventory_cards AS
SELECT
    id,
    preorder_id,
    card_barcode_number,

    transaction_total_cost_usd AS transaction_total_cost_cents,
    CAST(transaction_total_cost_usd AS DECIMAL(38,6)) / 100 AS revenue_usd,
    CAST(buy_card_total_cost AS DECIMAL(38,6)) AS cost_usd,

    assign_time,
    CONVERT_TIMEZONE('GMT', 'America/Los_Angeles', assign_time) AS assign_time_la

FROM "source_db"."source_schema"."inventory_cards"
WITH NO SCHEMA BINDING;
