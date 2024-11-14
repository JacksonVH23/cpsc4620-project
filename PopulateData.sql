-- CPSC 4620 | Fall 2024
-- Professor Roger Van Scoy
-- Jackson Van Hyning & Kevin Lin

-- PopulateData.sql - Populate PizzaDB with starter Data

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * STARTER DATA * * * * * * * * * * * * * * * * * * * * * * * * * * * *
--
--                                                        TOPPINGS                                                          
-- +-------------------+----------------+---------------+-----------+-----------+------------+----------+---------+---------+
-- | Name              | Price per unit | Cost per unit | Inventory | Minimum   | Small      | Medium   | Large   | XLarge  |
-- |                   | (CustPrice)    | (BusPrice)    | (CurINVT) | (MinINVT) | (SmallAMT) | (MedAMT) | (LgAMT) | (XLAMT) |    
-- +-------------------+----------------+---------------+-----------+-----------+------------+----------+---------+---------+
-- | Pepperoni         | 1.25           | 0.2           | 100       | 50        | 2          | 2.75     | 3.5     | 4.5     |
-- | Sausage           | 1.25           | 0.15          | 100       | 50        | 2.5        | 3        | 3.5     | 4.25    |
-- | Ham               | 1.5            | 0.15          | 78        | 25        | 2          | 2.5      | 3.25    | 4       |
-- | Chicken           | 1.75           | 0.25          | 56        | 25        | 1.5        | 2        | 2.25    | 3       |
-- | Green Pepper      | 0.5            | 0.02          | 79        | 25        | 1          | 1.5      | 2       | 2.5     |
-- | Onion             | 0.5            | 0.02          | 85        | 25        | 1          | 1.5      | 2       | 2.75    |
-- | Roma Tomato       | 0.75           | 0.03          | 86        | 10        | 1          | 1.5      | 3.5     | 4.5     |
-- | Mushrooms         | 0.75           | 0.1           | 52        | 50        | 1.5        | 2        | 2.5     | 3.25    |
-- | Black Olives      | 0.6            | 0.1           | 39        | 25        | 0.75       | 1        | 1.5     | 2       |
-- | Pineapple         | 1              | 0.25          | 15        | 0         | 1          | 1.25     | 1.75    | 2       |
-- | Jalapenos         | 0.5            | 0.05          | 64        | 0         | 0.5        | 0.75     | 1.25    | 1.75    |
-- | Banana Peppers    | 0.5            | 0.05          | 36        | 0         | 0.6        | 1        | 1.3     | 1.75    |
-- | Regular Cheese    | 0.5            | 0.12          | 250       | 50        | 2          | 3.5      | 5       | 6       |
-- | Four Cheese Blend | 1              | 0.15          | 150       | 25        | 2          | 3.5      | 5       | 7       |
-- | Feta Cheese       | 1.5            | 0.18          | 75        | 0         | 1.75       | 3        | 4.5     | 5.5     |
-- | Goat Cheese       | 1.5            | 0.2           | 54        | 0         | 1.6        | 2.75     | 4       | 5       |
-- | Bacon             | 1.5            | 0.25          | 89        | 0         | 1          | 1.5      | 2       | 3       |
-- +-------------------+----------------+---------------+-----------+-----------+------------+----------+---------+---------+
--
--                          DISCOUNTS                         
-- +---------------------+----------+----------+-------------+
-- | Name                | % off    | $ off    | (IsPercent) |
-- | (DiscountName)      | (Amount) | (Amount) |             |
-- +---------------------+----------+----------+-------------+
-- | Employee            | 15%      |          | 1           |
-- | Lunch Special Medium|          | $1.00    | 0           |
-- | Lunch Special Large |          | $2.00    | 0           |
-- | Specialty Pizza     |          | $1.50    | 0           |
-- | Happy Hour          | 10%      |          | 1           |
-- | Gameday Special     | 20%      |          | 1           |
-- +---------------------+----------+----------+-------------+
--
--                     BASE PRICES                   
-- +--------+-------------+-------------+------------+
-- | Size   | Crust       | Price       | Cost       |
-- | (Size) | (CrustType) | (CustPrice) | (BusPrice) |
-- +--------+-------------+-------------+------------+
-- | Small  | Thin        | 3           | 0.5        |
-- | Small  | Original    | 3           | 0.75       |
-- | Small  | Pan         | 3.5         | 1          |
-- | Small  | Gluten-Free | 4           | 2          |
-- | Medium | Thin        | 5           | 1          |
-- | Medium | Original    | 5           | 1.5        |
-- | Medium | Pan         | 6           | 2.25       |
-- | Medium | Gluten-Free | 6.25        | 3          |
-- | Large  | Thin        | 8           | 1.25       |
-- | Large  | Original    | 8           | 2          |
-- | Large  | Pan         | 9           | 3          |
-- | Large  | Gluten-Free | 9.5         | 4          |
-- | XLarge | Thin        | 10          | 2          |
-- | XLarge | Original    | 10          | 3          |
-- | XLarge | Pan         | 11.5        | 4.5        |
-- | XLarge | Gluten-Free | 12.5        | 6          |
-- +--------+-------------+-------------+------------+
--
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

-- * * * * * * * * * * * * * POPULATE TABLES * * * * * * * * * * * *
-- Populate topping
INSERT INTO topping (
        topping_TopName,
        topping_SmallAMT,
        topping_MedAMT,
        topping_LgAMT,
        topping_XLAMT,
        topping_CustPrice,
        topping_BusPrice,
        topping_MinINVT,
        topping_CurINVT)
    VALUES
        ('Pepperoni', 2.00, 2.75, 3.50, 4.50, 1.25, 0.20, 50, 100),
        ('Sausage', 2.50, 3.00, 3.50, 4.25, 1.25, 0.15, 50, 100),
        ('Ham', 2.00, 2.50, 3.25, 4.00, 1.50, 0.15, 25, 78),
        ('Chicken', 1.50, 2.00, 2.25, 3.00, 1.75, 0.25, 25, 56),
        ('Green Pepper', 1.00, 1.50, 2.00, 2.50, 0.50, 0.02, 25, 79),
        ('Onion', 1.00, 1.50, 2.00, 2.75, 0.50, 0.02, 25, 85),
        ('Roma Tomato', 1.00, 1.50, 3.50, 4.50, 0.75, 0.03, 10, 86),
        ('Mushrooms', 1.50, 2.00, 2.50, 3.25, 0.75, 0.10, 50, 52),
        ('Black Olives', 0.75, 1.00, 1.50, 2.00, 0.60, 0.10, 25, 39),
        ('Pineapple', 1.00, 1.25, 1.75, 2.00, 1.00, 0.25, 0, 15),
        ('Jalapenos', 0.50, 0.75, 1.25, 1.75, 0.50, 0.05, 0, 64),
        ('Banana Peppers', 0.60, 1.00, 1.30, 1.75, 0.50, 0.05, 0, 36),
        ('Regular Cheese', 2.00, 3.50, 5.00, 6.00, 0.50, 0.12, 50, 250),
        ('Four Cheese Blend', 2.00, 3.50, 5.00, 7.00, 1.00, 0.15, 25, 150),
        ('Feta Cheese', 1.75, 3.00, 4.50, 5.50, 1.50, 0.18, 0, 75),
        ('Goat Cheese', 1.60, 2.75, 4.00, 5.00, 1.50, 0.20, 0, 54),
        ('Bacon', 1.00, 1.50, 2.00, 3.00, 1.50, 0.25, 0, 89);

-- Populate discount
INSERT INTO discount (
        discount_DiscountName,
        discount_Amount,
        discount_IsPercent)
    VALUES
        ('Employee', 15.00, 1),
        ('Lunch Special Medium', 1.00, 0),
        ('Lunch Special Large', 2.00, 0),
        ('Specialty Pizza', 1.50, 0),
        ('Happy Hour', 10.00, 1),
        ('Gameday Special', 20.00, 1);

-- Populate baseprice
INSERT INTO baseprice (
        baseprice_Size,
        baseprice_CrustType,
        baseprice_CustPrice,
        baseprice_BusPrice)
    VALUES
        ('Small', 'Thin', 3.00, 0.50),
        ('Small', 'Original', 3.00, 0.75),
        ('Small', 'Pan', 3.50, 1.00),
        ('Small', 'Gluten-Free', 4.00, 2.00),
        ('Medium', 'Thin', 5.00, 1.00),
        ('Medium', 'Original', 5.00, 1.50),
        ('Medium', 'Pan', 6.00, 2.25),
        ('Medium', 'Gluten-Free', 6.25, 3.00),
        ('Large', 'Thin', 8.00, 1.25),
        ('Large', 'Original', 8.00, 2.00),
        ('Large', 'Pan', 9.00, 3.00),
        ('Large', 'Gluten-Free', 9.50, 4.00),
        ('XLarge', 'Thin', 10.00, 2.00),
        ('XLarge', 'Original', 10.00, 3.00),
        ('XLarge', 'Pan', 11.50, 4.50),
        ('XLarge', 'Gluten-Free', 12.50, 6.00);
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

-- * * * * * * * * * * * * * * * * * * * INSERT ORDERS * * * * * * * * * * * * * * * * * * *
-- Order 1: "On March 5th at 12:03 pm there was a dine-in order (at table 21) for a large
--          thin crust pizza with Regular Cheese (extra), Pepperoni, and Sausage
--          (Price: $19.75, Cost: $3.68). They used the “Lunch Special Large” discount for 
--          the pizza."

-- Insert into ordertable
INSERT INTO ordertable (
        ordertable_OrderType,
        ordertable_OrderDateTime,
        ordertable_CustPrice,
        ordertable_BusPrice,
        ordertable_isComplete)
    VALUES (
        'dinein',
        '2024-03-05 12:03:00',
        19.75, 3.68,
        1);

SET @order_id = LAST_INSERT_ID();

-- Insert dine-in details
INSERT INTO dinein (
        ordertable_OrderID,
        dinein_TableNum)
    VALUES (
        @order_id,
        21);

-- Insert pizza into pizza table
INSERT INTO pizza (
        pizza_Size,
        pizza_CrustType,
        pizza_PizzaState,
        pizza_PizzaDate,
        pizza_CustPrice,
        pizza_BusPrice,
        ordertable_OrderID)
    VALUES (
        'Large',
        'Thin',
        'processing',
        '2023-03-05 12:03:00',
        19.75,
        3.68,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings
INSERT INTO pizza_topping (
        pizza_PizzaID,
        topping_TopID,
        pizza_topping_IsDouble)
    VALUES (
        @pizza_id,
        (SELECT topping_topID
            FROM topping
            WHERE topping_TopName = 'Regular Cheese'),
        1);
    
INSERT INTO pizza_topping (
        pizza_PizzaID,
        topping_TopID,
        pizza_topping_IsDouble)
    VALUES (
        @pizza_id,
        (SELECT topping_topID
            FROM topping
            WHERE topping_TopName = 'Pepperoni'),
        0);

INSERT INTO pizza_topping (
        pizza_PizzaID,
        topping_TopID,
        pizza_topping_IsDouble)
    VALUES (
        @pizza_id,
        (SELECT topping_topID
            FROM topping
            WHERE topping_TopName = 'Sausage'),
        0);

-- Apply discount to pizza
INSERT INTO pizza_discount (
        pizza_PizzaID,
        discount_DiscountID)
    VALUES (
        @pizza_id,
        (SELECT discount_DiscountID
            FROM discount
            WHERE discount_DiscountName = 'Lunch Special Large'));


-- Order 2: "On April 3rd at 12:05 pm there was a dine-in order (at table 4). They ordered
--          a medium pan pizza with Feta Cheese, Black Olives, Roma Tomatoes, Mushrooms
--          and Banana Peppers (Price: $12.85, Cost: $3.23). They used the
--          'Lunch Special Medium' and the 'Specialty Pizza' discounts for the pizza.
--          They also ordered a small original crust pizza with Regular Cheese, Chicken
--          and Banana Peppers (Price: $6.93, Cost: $1.40)."

-- Insert into ordertable
INSERT INTO ordertable (
        ordertable_OrderType,
        ordertable_OrderDateTime,
        ordertable_CustPrice,
        ordertable_BusPrice,
        ordertable_isComplete)
    VALUES (
        'dinein',
        '2024-04-03 12:05:00',
        12.85 + 6.93,  -- Total customer price for both pizzas
        3.23 + 1.40,   -- Total business cost for both pizzas
        1);

SET @order_id = LAST_INSERT_ID();

-- Insert dine-in details
INSERT INTO dinein (
        ordertable_OrderID,
        dinein_TableNum)
    VALUES (
        @order_id,
        4);

-- Insert first pizza (medium pan) into pizza table
INSERT INTO pizza (
        pizza_Size,
        pizza_CrustType,
        pizza_PizzaState,
        pizza_PizzaDate,
        pizza_CustPrice,
        pizza_BusPrice,
        ordertable_OrderID)
    VALUES (
        'Medium',
        'Pan',
        'processing',
        '2024-04-03 12:05:00',
        12.85,
        3.23,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings for first pizza
INSERT INTO pizza_topping (
        pizza_PizzaID,
        topping_TopID,
        pizza_topping_IsDouble)
    VALUES (
        @pizza_id,
        (SELECT topping_topID
            FROM topping
            WHERE topping_TopName = 'Feta Cheese'),
        0);

INSERT INTO pizza_topping (
        pizza_PizzaID,
        topping_TopID,
        pizza_topping_IsDouble)
    VALUES (
        @pizza_id,
        (SELECT topping_topID
            FROM topping
            WHERE topping_TopName = 'Black Olives'),
        0);

INSERT INTO pizza_topping (
        pizza_PizzaID,
        topping_TopID,
        pizza_topping_IsDouble)
    VALUES (
        @pizza_id,
        (SELECT topping_topID
            FROM topping
            WHERE topping_TopName = 'Roma Tomatoes'),
        0);

INSERT INTO pizza_topping (
        pizza_PizzaID,
        topping_TopID,
        pizza_topping_IsDouble)
    VALUES (
        @pizza_id,
        (SELECT topping_topID
            FROM topping
            WHERE topping_TopName = 'Mushrooms'),
        0);

INSERT INTO pizza_topping (
        pizza_PizzaID,
        topping_TopID,
        pizza_topping_IsDouble)
    VALUES (
        @pizza_id,
        (SELECT topping_topID
            FROM topping
            WHERE topping_TopName = 'Banana Peppers'),
        0);

-- Apply discounts to first pizza
INSERT INTO pizza_discount (
        pizza_PizzaID,
        discount_DiscountID)
    VALUES (
        @pizza_id,
        (SELECT discount_DiscountID
            FROM discount
            WHERE discount_DiscountName = 'Lunch Special Medium'));

INSERT INTO pizza_discount (
        pizza_PizzaID,
        discount_DiscountID)
    VALUES (
        @pizza_id,
        (SELECT discount_DiscountID
            FROM discount
            WHERE discount_DiscountName = 'Specialty Pizza'));

-- Insert second pizza (small original crust) into pizza table
INSERT INTO pizza (
        pizza_Size,
        pizza_CrustType,
        pizza_PizzaState,
        pizza_PizzaDate,
        pizza_CustPrice,
        pizza_BusPrice,
        ordertable_OrderID)
    VALUES (
        'Small',
        'Original',
        'processing',
        '2024-04-03 12:05:00',
        6.93,
        1.40,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings for second pizza
INSERT INTO pizza_topping (
        pizza_PizzaID,
        topping_TopID,
        pizza_topping_IsDouble)
    VALUES (
        @pizza_id,
        (SELECT topping_topID
            FROM topping
            WHERE topping_TopName = 'Regular Cheese'),
        0);

INSERT INTO pizza_topping (
        pizza_PizzaID,
        topping_TopID,
        pizza_topping_IsDouble)
    VALUES (
        @pizza_id,
        (SELECT topping_topID
            FROM topping
            WHERE topping_TopName = 'Chicken'),
        0);

INSERT INTO pizza_topping (
        pizza_PizzaID,
        topping_TopID,
        pizza_topping_IsDouble)
    VALUES (
        @pizza_id,
        (SELECT topping_topID
            FROM topping
            WHERE topping_TopName = 'Banana Peppers'),
        0);
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *