# OTT Streaming SQL Analytics Project

## 📌 Project Overview
This project is a resume-ready SQL analytics project based on an OTT streaming platform dataset.  
It includes database design, table creation, CSV import, joins, aggregations, views, indexes, and stored procedures.

---

## 📂 Project Structure

OTT-Streaming-SQL-Analytics-Project/
│
├── sql/
│   └── ott_project.sql
│
├── dataset/
│   ├── users.csv
│   ├── plans.csv
│   ├── content.csv
│   ├── devices.csv
│   ├── subscriptions.csv
│   ├── watch_history.csv
│   ├── ratings.csv
│   └── payments.csv
│
├── screenshots/
│
└── README.md

---

## 🛠️ Tools Used
- MySQL Workbench
- SQL
- CSV Dataset
- Git & GitHub

---

## 🧱 Database Features
- Database creation
- 8 relational tables
- Primary Keys & Foreign Keys
- CSV data import
- Views
- Indexes
- Stored Procedure
- Analytical SQL Queries

---

## 📊 Tables Included
- users
- plans
- content
- devices
- subscriptions
- watch_history
- ratings
- payments

---

## 🔥 SQL Concepts Covered
- DDL (CREATE, ALTER)
- DML (SELECT)
- WHERE, ORDER BY, GROUP BY
- Aggregate Functions
- INNER JOIN / LEFT JOIN
- Subqueries
- CASE WHEN
- CTE
- Window Functions
- Views
- Indexes
- Stored Procedures

---

## ▶️ How to Run This Project
1. Open MySQL Workbench
2. Create schema/database
3. Run `sql/ott_project.sql`
4. Import CSV files into each table from the `dataset/` folder
5. Run analytical queries
6. Execute stored procedure:
   ```sql
   CALL GetUserWatchStats(1);
