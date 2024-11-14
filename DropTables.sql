-- CPSC 4620 | Fall 2024
-- Professor Roger Van Scoy
-- Jackson Van Hyning & Kevin Lin

-- DropTables.sql - Drop each table and view in the PizzaDB database

USE PizzaDB;

-- * * * * * * * * * * * * * * * DROP TABLES * * * * * * * * * * * * * * *
-- IMPORTANT: Tables with FKs must be dropped before
--            the tables they are referencing

-- Subtype tables:
DROP TABLE IF EXISTS dinein;
DROP TABLE IF EXISTS delivery;
DROP TABLE IF EXISTS pickup;

-- Bridge tables:
DROP TABLE IF EXISTS order_discount;
DROP TABLE IF EXISTS pizza_discount;
DROP TABLE IF EXISTS pizza_topping;

-- Other tables with FKs:
DROP TABLE IF EXISTS ordertable;
DROP TABLE IF EXISTS pizza;

-- Tables without FKs;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS discount;
DROP TABLE IF EXISTS topping;
DROP TABLE IF EXISTS baseprice;
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *