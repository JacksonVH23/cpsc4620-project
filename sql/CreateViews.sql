-- CPSC 4620 | Fall 2024
-- Professor Roger Van Scoy
-- Jackson Van Hyning & Kevin Lin

-- CreateViews.sql - Define views for PizzaDB

USE PizzaDB;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- VIEW 1: ToppingPopularity
-- Description: Ranks all toppings (including double toppings) by popularity.
CREATE VIEW ToppingPopularity AS
SELECT 
    t.topping_TopName AS Topping,
    COALESCE(SUM(CASE 
                    WHEN pt.pizza_topping_IsDouble = 1 THEN 2 
                    WHEN pt.pizza_topping_IsDouble = 0 THEN 1 
                    ELSE 0 
                 END), 0) AS ToppingCount
FROM 
    topping t
LEFT JOIN 
    pizza_topping pt ON t.topping_TopID = pt.topping_TopID
GROUP BY 
    t.topping_TopName
ORDER BY 
    ToppingCount DESC;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- VIEW 2: ProfitByPizza
-- Description: Summarizes pizza profit by size and crust type over time.
CREATE OR REPLACE VIEW ProfitByPizza AS
SELECT 
    p.pizza_Size AS `Size`,
    p.pizza_CrustType AS `Crust`,
    SUM(p.pizza_CustPrice - p.pizza_BusPrice) AS `Profit`,
    DATE_FORMAT(p.pizza_PizzaDate, '%c/%Y') AS `OrderMonth`
FROM 
    pizza p
GROUP BY 
    `Size`, `Crust`, `OrderMonth`
ORDER BY 
    `Profit` ASC;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
-- VIEW 3: ProfitByOrderType
-- Description: Summarizes profit by order type (dine-in, pickup, delivery) and month.
CREATE OR REPLACE VIEW ProfitByOrderType AS
(
    SELECT 
        o.ordertable_OrderType AS `customerType`,
        DATE_FORMAT(o.ordertable_OrderDateTime, '%c/%Y') AS `OrderMonth`,
        SUM(o.ordertable_CustPrice) AS `TotalOrderPrice`,
        SUM(o.ordertable_BusPrice) AS `TotalOrderCost`,
        SUM(o.ordertable_CustPrice - o.ordertable_BusPrice) AS `Profit`
    FROM 
        ordertable o
    GROUP BY 
        `customerType`, `OrderMonth`

    UNION ALL
    
    SELECT 
        NULL AS `customerType`,
        "Grand Total" AS `OrderMonth`,
        SUM(o.ordertable_CustPrice) AS `TotalOrderPrice`,
        SUM(o.ordertable_BusPrice) AS `TotalOrderCost`,
        SUM(o.ordertable_CustPrice - o.ordertable_BusPrice) AS `Profit`
    FROM 
        ordertable o
)
ORDER BY 
        CASE 
            WHEN `customerType` = 'dinein' THEN 1
            WHEN `customerType` = 'pickup' THEN 2
            WHEN `customerType` = 'delivery' THEN 3
            ELSE 4
        END,
        `Profit` DESC;
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
