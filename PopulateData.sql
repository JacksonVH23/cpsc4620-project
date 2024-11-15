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
        'processing',
        '2023-03-05 12:03:00',
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
        'processing',
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
    VALUES (@pizza_id, (SELECT discount_DiscountID FROM discount WHERE discount_DiscountName = 'Lunch Special Medium')),
           (@pizza_id, (SELECT discount_DiscountID FROM discount WHERE discount_DiscountName = 'Specialty Pizza'));

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
INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
    VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Regular Cheese'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Chicken'), 0),
           (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Banana Peppers'), 0);


-- Order 3: "On March 3rd at 9:30 pm Andrew Wilkes-Krier placed an order for pickup of
--          6 large original crust pizzas with Regular Cheese and Pepperoni
--          (Price: $14.88, Cost: $3.30 each). Andrew’s phone number is 864-254-5861."

-- Insert customer details
INSERT INTO customer (
        customer_FName,
        customer_LName,
        customer_PhoneNum)
    VALUES (
        'Andrew',
        'Wilkes-Krier',
        '864-254-5861');

SET @customer_id = LAST_INSERT_ID();

-- Insert order for pickup
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
        14.88 * 6,      -- Total customer price for six pizzas
        3.30 * 6,       -- Total business cost for six pizzas
        1);

SET @order_id = LAST_INSERT_ID();

-- Insert pickup details
INSERT INTO pickup (ordertable_OrderID, pickup_IsPickedUp)
    VALUES (@order_id, 1);

-- Insert each pizza (6 large original crust pizzas with same toppings)
SET @cust_price = 14.88;
SET @bus_cost = 3.30;

WHILE @pizza_qty > 0 DO

    -- Insert pizza details
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
            'Original',
            'delivered',
            '2024-03-03 21:30:00',
            @cust_price,
            @bus_cost,
            @order_id);

    SET @pizza_id = LAST_INSERT_ID();

    -- Insert toppings for each pizza
    INSERT INTO pizza_topping (pizza_PizzaID, topping_TopID, pizza_topping_IsDouble)
        VALUES (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Regular Cheese'), 0),
               (@pizza_id, (SELECT topping_topID FROM topping WHERE topping_TopName = 'Pepperoni'), 0);

    SET @pizza_qty = @pizza_qty - 1;

END WHILE;


-- Order 4: "On April 20th at 7:11 pm there was a delivery order made by Andrew
--          Wilkes-Krier for 1 xlarge pepperoni and Sausage pizza
--          (Price: $27.94, Cost: $9.19), one xlarge pizza with Ham (extra) and Pineapple
--          (extra) pizza (Price: $31.50, Cost: $6.25), and one xlarge Chicken and Bacon
--          pizza (Price: $26.75, Cost: $8.18). All the pizzas have the Four Cheese Blend
--          on it and are original crust. The order has the “Gameday Special” discount
--          applied to it, and the ham and pineapple pizza has the “Specialty Pizza”
--          discount applied to it. The pizzas were delivered to 115 Party Blvd, Anderson
--          SC 29621. His phone number is the same as before."

-- Check if the customer exists, if not, insert customer details
SET @customer_id = (
    SELECT customer_CustID
        FROM customer
        WHERE customer_FName = 'Andrew'
        AND customer_LName = 'Wilkes-Krier'
        AND customer_PhoneNum = '864-254-5861');

IF @customer_id IS NULL THEN
    INSERT INTO customer (
            customer_FName,
            customer_LName,
            customer_PhoneNum)
        VALUES (
            'Andrew',
            'Wilkes-Krier',
            '864-254-5861');

    SET @customer_id = LAST_INSERT_ID();
END IF;

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
        27.94 + 31.50 + 26.75, -- Total customer price for all pizzas
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

-- Insert first pizza (x-large original crust with Pepperoni and Sausage)
INSERT INTO pizza (
        pizza_Size,
        pizza_CrustType,
        pizza_PizzaState,
        pizza_PizzaDate,
        pizza_CustPrice,
        pizza_BusPrice,
        ordertable_OrderID)
    VALUES (
        'X-Large',
        'Original',
        'delivered',
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

-- Insert second pizza (x-large original crust with Ham (double) and Pineapple (double))
INSERT INTO pizza (
        pizza_Size,
        pizza_CrustType,
        pizza_PizzaState,
        pizza_PizzaDate,
        pizza_CustPrice,
        pizza_BusPrice,
        ordertable_OrderID)
    VALUES (
        'X-Large',
        'Original',
        'delivered',
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

-- Apply "Specialty Pizza" discount to second pizza
INSERT INTO pizza_discount (pizza_PizzaID, discount_DiscountID)
    VALUES (@pizza_id, (SELECT discount_DiscountID FROM discount WHERE discount_DiscountName = 'Specialty Pizza'));

-- Insert third pizza (x-large original crust with Chicken and Bacon)
INSERT INTO pizza (
        pizza_Size,
        pizza_CrustType,
        pizza_PizzaState,
        pizza_PizzaDate,
        pizza_CustPrice,
        pizza_BusPrice,
        ordertable_OrderID)
    VALUES (
        'X-Large',
        'Original',
        'delivered',
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

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *