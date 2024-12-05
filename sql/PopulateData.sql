-- CPSC 4620 | Fall 2024
-- Professor Roger Van Scoy
-- Jackson Van Hyning & Kevin Lin

-- PopulateData.sql - Populate PizzaDB with starter Data\

USE PizzaDB;

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
        ('Roma Tomato', 2.00, 3.00, 3.50, 4.50, 0.75, 0.03, 10, 86),
        ('Mushrooms', 1.50, 2.00, 2.50, 3.00, 0.75, 0.10, 50, 52),
        ('Black Olives', 0.75, 1.00, 1.50, 2.00, 0.60, 0.10, 25, 39),
        ('Pineapple', 1.00, 1.25, 1.75, 2.00, 1.00, 0.25, 0, 15),
        ('Jalapenos', 0.50, 0.75, 1.25, 1.75, 0.50, 0.05, 0, 64),
        ('Banana Peppers', 0.60, 1.00, 1.30, 1.75, 0.50, 0.05, 0, 36),
        ('Regular Cheese', 2.00, 3.50, 5.00, 7.00, 0.50, 0.12, 50, 250),
        ('Four Cheese Blend', 2.00, 3.50, 5.00, 7.00, 1.00, 0.15, 25, 150),
        ('Feta Cheese', 1.75, 3.00, 4.00, 5.50, 1.50, 0.18, 0, 75),
        ('Goat Cheese', 1.60, 2.75, 4.00, 5.50, 1.50, 0.20, 0, 54),
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
INSERT INTO dinein (ordertable_OrderID, dinein_TableNum)
    VALUES (@order_id, 21);

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
        'completed',
        '2024-03-05 12:03:00',
        19.75,
        3.68,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Regular Cheese'), 1),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Pepperoni'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Sausage'), 0);

-- Apply discount to pizza
INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
    VALUES (@pizza_id, (SELECT discount_DiscountID FROM discount WHERE discount_DiscountName = 'Lunch Special Large'));


-- Order 2: "On April 3rd at 12:05 pm there was a dine-in order (at table 4). They ordered
--          a medium pan pizza with Feta Cheese, Black Olives, Roma Tomatoes, Mushrooms
--          and Banana Peppers (Price: $12.85, Cost: $3.23). They used the
--          'Lunch Special Medium' and the 'Specialty pizza' discounts for the pizza.
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
INSERT INTO dinein (ordertable_OrderID, dinein_TableNum)
    VALUES (@order_id, 4);

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
        'completed',
        '2024-04-03 12:05:00',
        12.85,
        3.23,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings for first pizza
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Feta Cheese'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Black Olives'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Roma Tomato'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Mushrooms'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Banana Peppers'), 0);

-- Apply discounts to first pizza
INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
        VALUES (@pizza_id, (SELECT discount_DiscountID FROM discount WHERE discount_DiscountName = 'Specialty pizza'));

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
        'completed',
        '2024-04-03 12:05:00',
        6.93,
        1.40,
        @order_id);

-- Apply "Lunch Special Medium" discount to the entire order
INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
    VALUES (@order_id, (SELECT discount_DiscountID FROM discount WHERE discount_DiscountName = 'Lunch Special Medium'));

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings for second pizza
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Regular Cheese'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Chicken'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Banana Peppers'), 0);




-- Order 3: "On March 3rd at 9:30 pm Andrew Wilkes-Krier placed an order for pickup of
--          6 large original crust pizzas with Regular Cheese and Pepperoni
--          (Price: $14.88, Cost: $3.30 each). Andrew’s phone number is 864-254-5861."

SET @customer_id = (
    SELECT customer_CustID
    FROM customer
    WHERE customer_FName = 'Andrew'
      AND customer_LName = 'Wilkes-Krier'
      AND customer_PhoneNum = '8642545861'
);

-- If the customer doesn't exist, insert them and get the ID
INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum)
    SELECT
        'Andrew',
        'Wilkes-Krier',
        '8642545861'
    WHERE @customer_id IS NULL;

-- Update the variable to the new ID if a row was inserted
SET @customer_id = COALESCE(@customer_id, LAST_INSERT_ID());

-- Insert pickup order
INSERT INTO ordertable (
        customer_CustID,
        ordertable_OrderType,
        ordertable_OrderDateTime,
        ordertable_CustPrice,
        ordertable_BusPrice,
        ordertable_isComplete)
    VALUES (
        @customer_id,
        'pickup',
        '2024-03-03 21:30:00',
        6 * 14.88, -- Total customer price for all pizzas
        6 * 3.30,  -- Total business cost for all pizzas
        1);

SET @order_id = LAST_INSERT_ID();

-- Insert pickup details
INSERT INTO pickup (
        ordertable_OrderID,
        pickup_IsPickedUp)
    VALUES (
        @order_id,
        1);

-- Use the stored procedure to insert 6 pizzas with Regular Cheese and Pepperoni toppings
CALL InsertPizzaWithToppings(
    6,         -- Number of pizzas
    14.88,     -- Customer price per pizza
    3.30,      -- Business cost per pizza
    @order_id  -- Order ID to associate pizzas with
);


-- Order 4: "On April 20th at 7:11 pm there was a delivery order made by Andrew
--          Wilkes-Krier for 1 xlarge pepperoni and Sausage pizza
--          (Price: $27.94, Cost: $9.19), one xlarge pizza with Ham (extra) and Pineapple
--          (extra) pizza (Price: $31.50, Cost: $6.25), and one xlarge Chicken and Bacon
--          pizza (Price: $26.75, Cost: $8.18). All the pizzas have the Four Cheese Blend
--          on it and are original crust. The order has the “Gameday Special” discount
--          applied to it, and the ham and pineapple pizza has the “Specialty pizza”
--          discount applied to it. The pizzas were delivered to 115 Party Blvd, Anderson
--          SC 29621. His phone number is the same as before."

SET @customer_id = (
    SELECT customer_CustID
    FROM customer
    WHERE customer_FName = 'Andrew'
      AND customer_LName = 'Wilkes-Krier'
      AND customer_PhoneNum = '8642545861'
);

-- If the customer doesn't exist, insert them and get the ID
INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum)
    SELECT
        'Andrew',
        'Wilkes-Krier',
        '8642545861'
    WHERE @customer_id IS NULL;

-- Update the variable to the new ID if a row was inserted
SET @customer_id = COALESCE(@customer_id, LAST_INSERT_ID());

-- Insert delivery order
INSERT INTO ordertable (
        customer_CustID,
        ordertable_OrderType,
        ordertable_OrderDateTime,
        ordertable_CustPrice,
        ordertable_BusPrice,
        ordertable_isComplete)
    VALUES (
        @customer_id,
        'delivery',
        '2024-04-20 19:11:00',
        68.95, -- Total customer price for all pizzas
        9.19 + 6.25 + 8.18,    -- Total business cost for all pizzas
        1);

SET @order_id = LAST_INSERT_ID();

-- Insert delivery details
INSERT INTO delivery (
        ordertable_OrderID,
        delivery_HouseNum,
        delivery_Street,
        delivery_City,
        delivery_State,
        delivery_Zip,
        delivery_isDelivered)
    VALUES (
        @order_id,
        115,
        'Party Blvd',
        'Anderson',
        'SC',
        29621,
        1);

-- Insert first pizza (Xlarge original crust with Pepperoni and Sausage)
INSERT INTO pizza (
        pizza_Size,
        pizza_CrustType,
        pizza_PizzaState,
        pizza_PizzaDate,
        pizza_CustPrice,
        pizza_BusPrice,
        ordertable_OrderID)
    VALUES (
        'XLarge',
        'Original',
        'completed',
        '2024-04-20 19:11:00',
        27.94,
        9.19,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings for first pizza
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Four Cheese Blend'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Pepperoni'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Sausage'), 0);

-- Insert second pizza (Xlarge original crust with Ham (double) and Pineapple (double))
INSERT INTO pizza (
        pizza_Size,
        pizza_CrustType,
        pizza_PizzaState,
        pizza_PizzaDate,
        pizza_CustPrice,
        pizza_BusPrice,
        ordertable_OrderID)
    VALUES (
        'XLarge',
        'Original',
        'completed',
        '2024-04-20 19:11:00',
        31.50,
        6.25,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings for second pizza
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Four Cheese Blend'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Ham'), 1),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Pineapple'), 1);

-- Apply "Specialty pizza" discount to second pizza
INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
    VALUES (@pizza_id, (SELECT discount_DiscountID FROM discount WHERE discount_DiscountName = 'Specialty pizza'));

-- Insert third pizza (Xlarge original crust with Chicken and Bacon)
INSERT INTO pizza (
        pizza_Size,
        pizza_CrustType,
        pizza_PizzaState,
        pizza_PizzaDate,
        pizza_CustPrice,
        pizza_BusPrice,
        ordertable_OrderID)
    VALUES (
        'XLarge',
        'Original',
        'completed',
        '2024-04-20 19:11:00',
        26.75,
        8.18,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings for third pizza
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Four Cheese Blend'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Chicken'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Bacon'), 0);

-- Apply "Gameday Special" discount to the entire order
INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
    VALUES (@order_id, (SELECT discount_DiscountID FROM discount WHERE discount_DiscountName = 'Gameday Special'));


-- Order 5: "On March 2nd at 5:30 pm Matt Engers placed an order for pickup for an
--          xlarge pizza with Green Pepper, Onion, Roma Tomatoes, Mushrooms, and
--          Black Olives on it. He wants the Goat Cheese on it, and a Gluten Free
--          Crust (Price: $27.45, Cost: $7.88). The “Specialty pizza” discount is
--          applied to the pizza. Matt’s phone number is 864-474-9953."

-- Check if the customer exists, if not, insert customer details
SET @customer_id = (
    SELECT customer_CustID
    FROM customer
    WHERE customer_FName = 'Matt'
      AND customer_LName = 'Engers'
      AND customer_PhoneNum = '8644749953'
);

-- If the customer doesn't exist, insert them and get the ID
INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum)
    SELECT
        'Matt',
        'Engers',
        '8644749953'
    WHERE @customer_id IS NULL;

-- Update the variable to the new ID if a row was inserted
SET @customer_id = COALESCE(@customer_id, LAST_INSERT_ID());

-- Insert pickup order
INSERT INTO ordertable (
        customer_CustID,
        ordertable_OrderType,
        ordertable_OrderDateTime,
        ordertable_CustPrice,
        ordertable_BusPrice,
        ordertable_isComplete)
    VALUES (
        @customer_id,
        'pickup',
        '2024-03-02 17:30:00',
        27.45, -- Customer price for the pizza
        7.88,  -- Business cost for the pizza
        1);

SET @order_id = LAST_INSERT_ID();

-- Insert pickup details
INSERT INTO pickup (
        ordertable_OrderID,
        pickup_IsPickedUp)
    VALUES (
        @order_id,
        1);

-- Insert the pizza (Xlarge gluten-free crust with specified toppings)
INSERT INTO pizza (
        pizza_Size,
        pizza_CrustType,
        pizza_PizzaState,
        pizza_PizzaDate,
        pizza_CustPrice,
        pizza_BusPrice,
        ordertable_OrderID)
    VALUES (
        'XLarge',
        'Gluten-Free',
        'completed',
        '2024-03-02 17:30:00',
        27.45,
        7.88,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings for the pizza
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Goat Cheese'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Green Pepper'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Onion'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Roma Tomato'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Mushrooms'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Black Olives'), 0);

-- Apply "Specialty pizza" discount to the pizza
INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
    VALUES (@pizza_id, (SELECT discount_DiscountID FROM discount WHERE discount_DiscountName = 'Specialty pizza'));


-- Order 6: "On March 2nd at 6:17 pm Frank Turner places an order for delivery of one
--          large pizza with Chicken, Green Peppers, Onions, and Mushrooms. He wants
--          the Four Cheese Blend (extra) and thin crust (Price: $25.81, Cost: $4.24).
--          The pizza was delivered to 6745 Wessex St Anderson SC 29621. Frank’s phone
--          number is 864-232-8944."

-- Check if the customer exists, if not, insert customer details
SET @customer_id = (
    SELECT customer_CustID
    FROM customer
    WHERE customer_FName = 'Frank'
      AND customer_LName = 'Turner'
      AND customer_PhoneNum = '8642328944'
);

-- If the customer doesn't exist, insert them and get the ID
INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum)
    SELECT
        'Frank',
        'Turner',
        '8642328944'
    WHERE @customer_id IS NULL;

-- Update the variable to the new ID if a row was inserted
SET @customer_id = COALESCE(@customer_id, LAST_INSERT_ID());

-- Insert delivery order
INSERT INTO ordertable (
        customer_CustID,
        ordertable_OrderType,
        ordertable_OrderDateTime,
        ordertable_CustPrice,
        ordertable_BusPrice,
        ordertable_isComplete)
    VALUES (
        @customer_id,
        'delivery',
        '2024-03-02 18:17:00',
        25.81, -- Customer price for the pizza
        4.24,  -- Business cost for the pizza
        1);

SET @order_id = LAST_INSERT_ID();

-- Insert delivery details
INSERT INTO delivery (
        ordertable_OrderID,
        delivery_HouseNum,
        delivery_Street,
        delivery_City,
        delivery_State,
        delivery_Zip,
        delivery_isDelivered)
    VALUES (
        @order_id,
        6745,
        'Wessex St',
        'Anderson',
        'SC',
        29621,
        1);

-- Insert the pizza (large thin crust with specified toppings)
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
        'completed',
        '2024-03-02 18:17:00',
        25.81,
        4.24,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings for the pizza
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Four Cheese Blend'), 1),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Chicken'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Green Pepper'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Onion'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Mushrooms'), 0);


-- Order 7: "On April 13th at 8:32 pm Milo Auckerman ordered two large thin crust pizzas.
--          One had the Four Cheese Blend on it (extra) (Price: $18.00, Cost: $2.75),
--          the other was Regular Cheese and Pepperoni (extra) (Price: $19.25, Cost: $3.25).
--          He used the “Employee” discount on his order. He had them delivered to 8879
--          Suburban Home, Anderson, SC 29621. His phone number is 864-878-5679."

-- Check if the customer exists, if not, insert customer details
SET @customer_id = (
    SELECT customer_CustID
    FROM customer
    WHERE customer_FName = 'Milo'
      AND customer_LName = 'Auckerman'
      AND customer_PhoneNum = '8648785679'
);

-- If the customer doesn't exist, insert them and get the ID
INSERT INTO customer (customer_FName, customer_LName, customer_PhoneNum)
    SELECT
        'Milo',
        'Auckerman',
        '8648785679'
    WHERE @customer_id IS NULL;

-- Update the variable to the new ID if a row was inserted
SET @customer_id = COALESCE(@customer_id, LAST_INSERT_ID());

-- Insert delivery order
INSERT INTO ordertable (
        customer_CustID,
        ordertable_OrderType,
        ordertable_OrderDateTime,
        ordertable_CustPrice,
        ordertable_BusPrice,
        ordertable_isComplete)
    VALUES (
        @customer_id,
        'delivery',
        '2024-04-13 20:32:00',
        31.66,
        2.75 + 3.25,
        1);

SET @order_id = LAST_INSERT_ID();

-- Insert delivery details
INSERT INTO delivery (
        ordertable_OrderID,
        delivery_HouseNum,
        delivery_Street,
        delivery_City,
        delivery_State,
        delivery_Zip,
        delivery_isDelivered)
    VALUES (
        @order_id,
        8879,
        'Suburban',
        'Anderson',
        'SC',
        29621,
        1);

-- Insert first pizza (large thin crust with Four Cheese Blend (extra))
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
        'completed',
        '2024-04-13 20:32:00',
        18.00,
        2.75,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings for first pizza
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Four Cheese Blend'), 1);

-- Insert second pizza (large thin crust with Regular Cheese and Pepperoni (extra))
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
        'completed',
        '2024-04-13 20:32:00',
        19.25,
        3.25,
        @order_id);

SET @pizza_id = LAST_INSERT_ID();

-- Insert toppings for second pizza
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Regular Cheese'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Pepperoni'), 1);

-- Apply "Employee" discount to the entire order
INSERT INTO order_discount (ordertable_OrderID, discount_DiscountID)
    VALUES (@order_id, (SELECT discount_DiscountID FROM discount WHERE discount_DiscountName = 'Employee'));

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *