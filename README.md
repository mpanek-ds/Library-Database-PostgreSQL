# Relational Library Management System (PostgreSQL)

## 📌 Project Overview
This project involves the design, implementation, and population of a robust relational database for a library management system. Developed in **PostgreSQL**, the database features a fully normalized schema (3NF) consisting of 14 tables, handling everything from inventory and user management to rental transactions and geographical tracking.

## 🏗️ Database Architecture
The schema is built with a strong emphasis on data integrity and relational mapping. Key structural domains include:
* **Core Inventory:** `book`, `author`, `category`, `language`, `inventory`
* **Transactions:** `rental`, `payment`
* **Users & Staff:** `customer`, `staff`
* **Geographical Data:** `address`, `city`, `country`

## ⚙️ Key Technical Features
* **Data Validation & Integrity:** Extensive use of `CHECK` constraints to ensure high data quality at the database level:
  * Regex validation for 9-digit phone numbers (`^\d{9}$`).
  * Email format verification (ensuring `@` presence and specific domain rules for staff).
  * Chronological consistency (e.g., `return_date >= rental_date`, `release_year <= 2025`).
  * Proper-noun capitalization checks for names and cities.
* **Analytical Views:** 7 pre-built SQL views designed for reporting and data extraction:
  * `active_customer_rental` – aggregates total rentals for active customers.
  * `language_quantity` – tracks inventory distribution across languages.
  * `staff_data`, `staff_address`, `customer_address`, `book_cat_desc`, `title_author`.
* **Mock Data Injection:** Populated with realistic dataset records across all entities, enabling immediate query testing and schema validation.

## 🛠️ Technology Stack
* **RDBMS:** PostgreSQL
* **Languages & Tools:** SQL, DDL/DML, pg_dump

## 🚀 How to Run
To set up and evaluate the database locally with PostgreSQL installed:

```bash
# 1. Create a new database
createdb library_system

# 2. Restore schema and data from the dump file
psql -d library_system -f library_dump.sql
```

## 📊 Example Query
Identify the top 10 most active readers using the analytical view:

```sql
SELECT first_name, last_name, email, total_rentals 
FROM active_customer_rental 
ORDER BY total_rentals DESC 
LIMIT 10;
```

## 👥 Contributors
This project was developed collaboratively by a 3-person team:
* **Mateusz Panek**
* **Piotr Jasiak**
* **Konrad Serocki**
