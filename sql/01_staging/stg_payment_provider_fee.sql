-- Staging: Payment Provider Fee Rules
-- Replace source_db/source_schema with your own Redshift Zero-ETL destination.

CREATE SCHEMA IF NOT EXISTS staging;

CREATE OR REPLACE VIEW staging.stg_payment_provider_fee AS
SELECT
    id,
    payment_provider,
    platform_type,
    CAST(fee AS DECIMAL(38,6)) AS fee_percent,
    status

FROM "source_db"."source_schema"."payment_provider_fee"
WITH NO SCHEMA BINDING;
