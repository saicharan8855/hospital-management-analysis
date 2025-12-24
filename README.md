# 🏥 Hospital Management System - SQL Analysis

## 📊 Project Overview
Complete SQL analysis of a hospital database with 5 tables and 20+ analytical queries. This project demonstrates real-world healthcare data analysis skills.

## 📁 Database Tables
| Table | Records | Description |
|-------|---------|-------------|
| **patients** | 50 | Patient demographics & insurance |
| **doctors** | 10 | Doctor information & specializations |
| **appointments** | 200 | Patient-doctor appointments |
| **treatments** | 200 | Medical treatments with costs |
| **billing** | 200 | Billing & payment records |

## 🔍 Analysis Performed
1. **Patient Demographics**: Age distribution, insurance coverage
2. **Doctor Performance**: Appointment completion rates, specialization analysis
3. **Appointment Patterns**: No-show rates, day-wise trends
4. **Treatment Analysis**: Most common treatments, revenue by type
5. **Financial Insights**: Payment methods, revenue status

## 🛠️ SQL Skills Demonstrated
- Complex JOIN operations (5-table joins)
- Window Functions (RANK, ROW_NUMBER)
- CTEs (Common Table Expressions)
- Aggregate functions with GROUP BY, HAVING
- Date and time calculations
- Percentage and ratio analysis

## 🚀 How to Use
1. Create database in pgAdmin/MySQL
2. Import CSV files from `data/` folder
3. Run SQL queries from `scripts/sql_queries.sql`

## 📈 Key Findings
- Highest revenue treatment: **MRI**
- Busiest appointment day: **Wednesday**
- Patient retention rate: **67.5%**
- Most common insurance: **MedCare Plus**

## 📂 Project Structure
hospital-management-analysis/
├── data/ # 5 CSV datasets
├── scripts/ # SQL analysis file
├── docs/ # Documentation
└── README.md # This file

## 🚀 **Getting Started**

### **Prerequisites**
- PostgreSQL 12+ or MySQL 8+
- pgAdmin 4+ or MySQL Workbench
- Basic SQL knowledge

### **Installation & Setup**
bash
# 1. Clone repository
git clone https://github.com/saicharan8855/hospital-management-analysis.git

# 2. Navigate to project
cd hospital-management-analysis

# 3. Database setup (PostgreSQL)
CREATE DATABASE hospital_analysis;
\c hospital_analysis;
\i scripts/sql_queries.sql

Alternative: Step-by-Step Execution

-- 1. Create database
CREATE DATABASE hospital_management;

-- 2. Create tables using schema in sql_queries.sql
-- 3. Import CSV data using pgAdmin Import/Export wizard
-- 4. Execute analytical queries section by section

## 👨‍💻 Author
**Sai Charan** - SQL Portfolio Project

---
*Showcasing healthcare data analytics skills for data science roles.*
