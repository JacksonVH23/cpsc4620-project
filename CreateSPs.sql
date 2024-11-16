-- CPSC 4620 | Fall 2024
-- Professor Roger Van Scoy
-- Jackson Van Hyning & Kevin Lin

-- CreateSPs.sql - Define stored procedures, triggers and functions

USE PizzaDB;

DELIMITER //

CREATE PROCEDURE InsertPizzaWithToppings(IN pizza_qty INT, IN cust_price DECIMAL(10, 2), IN bus_cost DECIMAL(10, 2), IN order_id INT)
BEGIN
    DECLARE pizza_id INT;

    WHILE pizza_qty > 0 DO

        -- Insert pizza details
        INSERT INTO pizza (
                pizza_Size,
                pizza_CrustType,
                pizza_PizzaState,
                pizza_PizzaDate,
                pizza_CustPrice,
                pizza_BusPrice,
                ordertable_OrderID
            )
            VALUES (
                'Large',
                'Original',
                'completed',
                '2024-03-03 21:30:00',
                cust_price,
                bus_cost,
                order_id
            );

        SET pizza_id = LAST_INSERT_ID();

        -- Insert toppings for each pizza
        INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
            VALUES (pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Regular Cheese'), 0),
                   (pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Pepperoni'), 0);

        SET pizza_qty = pizza_qty - 1;

    END WHILE;

END //

DELIMITER ;
