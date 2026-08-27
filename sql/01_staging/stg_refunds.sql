-- Staging: Refund History
-- Replace source_db/source_schema with your own Redshift Zero-ETL destination.

CREATE SCHEMA IF NOT EXISTS staging;

CREATE OR REPLACE VIEW staging.stg_refunds AS
SELECT
    id AS refund_id,
    order_id,
    created_at,
    CONVERT_TIMEZONE('GMT', 'America/Los_Angeles', created_at) AS refund_at_la

FROM "source_db"."source_schema"."order_refund_historys"
WITH NO SCHEMA BINDING;
