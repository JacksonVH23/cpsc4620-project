-- CPSC 4620 | Fall 2024
-- Professor Roger Van Scoy
-- Jackson Van Hyning & Kevin Lin

-- CreateViews.sql - Define views for PizzaDB

USE PizzaDB;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- VIEW 1: ToppingPopularity
-- Description: Ranks all toppings (including double toppings) by popularity.
CREATE OR REPLACE VIEW ToppingPopularity AS
SELECT 
    t.topping_TopName AS ToppingName,
    SUM(CASE WHEN pt.pizza_topping_IsDouble = 1 THEN 2 ELSE 1 END) AS TotalUsed
FROM 
    pizza_topping pt
JOIN 
    topping t ON pt.topping_TopID = t.topping_TopID
GROUP BY 
    t.topping_TopName
ORDER BY 
    TotalUsed DESC;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- VIEW 2: ProfitByPizza
-- Description: Summarizes pizza profit by size and crust type over time.
CREATE OR REPLACE VIEW ProfitByPizza AS
SELECT 
    p.pizza_Size AS PizzaSize,
    p.pizza_CrustType AS CrustType,
    DATE_FORMAT(p.pizza_PizzaDate, '%Y-%m') AS Month,
    SUM(p.pizza_CustPrice - p.pizza_BusPrice) AS TotalProfit
FROM 
    pizza p
GROUP BY 
    PizzaSize, CrustType, Month
ORDER BY 
    TotalProfit DESC;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- VIEW 3: ProfitByOrderType
-- Description: Summarizes profit by order type (dine-in, pickup, delivery) and month.
CREATE OR REPLACE VIEW ProfitByOrderType AS
SELECT 
    o.ordertable_OrderType AS OrderType,
    DATE_FORMAT(o.ordertable_OrderDateTime, '%Y-%m') AS Month,
    SUM(o.ordertable_CustPrice - o.ordertable_BusPrice) AS TotalProfit
FROM 
    ordertable o
GROUP BY 
    OrderType, Month
ORDER BY 
    OrderType, Month;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
