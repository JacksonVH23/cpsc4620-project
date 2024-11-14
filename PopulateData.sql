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

-- * * * * * * * * * * * * * * * INSERT ORDERS * * * * * * * * * * * * * * *
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *