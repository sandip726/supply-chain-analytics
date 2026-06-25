# Supply Chain Analytics Project

## Overview
End-to-end supply chain analytics project built on Microsoft Azure, 
analyzing 158,000+ orders from DataCo Global across 5 global markets.

## Tools & Technologies
- **Azure Blob Storage** — Raw data storage
- **Azure Data Factory** — ETL pipeline (CSV → Azure SQL)
- **Azure SQL Database** — Data warehouse
- **Power BI** — Dashboard & visualization
- **SQL** — Data analysis and querying

## Dataset
- **Source:** DataCo Smart Supply Chain Dataset (Kaggle)
- **Size:** 158,000+ orders
- **Coverage:** 2015–2018 | Markets: Europe, LATAM, Pacific Asia, USCA, Africa
- **Products:** Clothing, Sports, Electronics

## Architecture
Blob Storage → Azure Data Factory → Azure SQL Database → Power BI

## Dashboard Pages
1. **Delivery Analysis** — Late delivery rates by market and shipping mode
2. **Sales Analysis** — Revenue and profit by market, segment and category
3. **Customer Analysis** — Customer segments and top customers
4. **Product Analysis** — Top products and category profitability

## Key Findings
1. **54.83% of orders are delivered late** across all markets
2. **First Class shipping has 95% late delivery rate** — promises 1 day, delivers in 2
3. **Standard Class is most reliable** — promises 4 days, delivers in 4
4. **Europe leads in revenue** with 10M+ in sales
5. **Consumer segment drives 51.91%** of total sales
6. **Fishing is the top product category** by both sales and profit

## Live Dashboard
(https://app.powerbi.com/view?r=eyJrIjoiOGQ1ZWFkZjctMjY1Ni00ODczLWFlNjYtODVjOTViNjg0NjQ0IiwidCI6IjlkOTc1MzBlLThmMjctNDEzNy1hMmE5LTVjYjRkY2YyNmYyZSIsImMiOjh9)

## SQL Queries
See `supply_chain_queries.sql` for all analysis queries
