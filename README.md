# Financial-Data-Warehouse-Redshift
Financial data warehouse for revenue, cost, payment fee, gross profit, and profit reporting with MoM and YoY analysis on AWS using RDS, Zero-ETL, Redshift Serverless, and BI-ready financial marts.

## Overview

This project designs and implements a cloud-based financial data warehouse for operational and financial reporting.

The goal of this project was to move financial calculations into a centralized warehouse so that downstream BI tools could consume consistent, reusable metrics instead of repeatedly joining and transforming production tables.

The warehouse supports:

- Revenue
- Cost
- Payment processing fees
- Gross profit
- Profit
- Sales events
- Inventory sales
- Voids
- Refunds
- Daily reporting
- Month-over-month comparisons
- Year-over-year comparisons

## Architecture

```text
Amazon RDS
   ↓
RDS Read Replica
   ↓
Amazon Zero-ETL Integration
   ↓
Amazon Redshift Serverless
   ↓
Raw / Source Layer
   ↓
Staging
   ↓
Intermediate
   ↓
Financial Event Fact
   ↓
Daily Financial Mart
   ↓
Financial Reporting View
   ↓
Lark / BI / SQL Consumers
