# supply-chain-fulfillment-analytics
# Supply Chain Fulfilment & Delivery Bottleneck Analysis

[![SQL](https://img.shields.io/badge/Language-SQL-blue.svg)](#)
[![PostgreSQL](https://img.shields.io/badge/Dialect-PostgreSQL%20%7C%20SQLite-336791.svg)](#)
[![Tableau](https://img.shields.io/badge/BI-Tableau%20Public-orange.svg)](#)

## Executive Summary
This project analyzes fulfillment cycle times and Service Level Agreement (SLA) breach drivers across 96,000+ orders from the Brazilian E-Commerce Public Dataset (Olist). The analysis reveals that roughly 82% of customer delivery delays originate in long-haul carrier transit rather than internal warehouse pick/pack handling. High-friction interstate corridors from southern fulfillment centers to northern consumer hubs experience SLA breach rates exceeding 18%, correlating with an average drop in customer satisfaction ratings from 4.2 to 1.6 out of 5 stars.

---

## Business Questions Answered
1. **Bottleneck Isolation:** Where in the fulfillment cycle (Warehouse Handoff vs. Carrier Transit) do late delivery delays occur?
2. **Corridor Vulnerabilities:** Which origin-destination shipping routes generate the highest frequency and cost of SLA violations?
3. **Sentiment Elasticity:** How severely does each additional day of delivery delay depress customer review scores?

---

## Repository Structure
```text
├── README.md                          <-- Project overview, KPIs, and findings
├── sql/
│   └── 01_fulfillment_analysis.sql    <-- CTE-based data cleaning, milestone staging, & KPIs
├── notebooks/                         <-- Python EDA & sentiment correlation
└── assets/                            <-- Visualizations, route charts, and dashboard previews
