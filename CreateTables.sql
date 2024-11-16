-- CPSC 4620 | Fall 2024
-- Professor Roger Van Scoy
-- Jackson Van Hyning & Kevin Lin

-- CreateTables.sql - Build tables and relationships shown in Pizzas-R-Us ERD

CREATE SCHEMA IF NOT EXISTS PizzaDB;
USE PizzaDB;

-- * * * * * * * * * * * * * Tables with no FKs * * * * * * * * * * * * * 
CREATE TABLE baseprice (
    baseprice_Size VARCHAR(30) NOT NULL,
    baseprice_CrustType VARCHAR(30) NOT NULL,
    baseprice_CustPrice DECIMAL(5, 2) NOT NULL,
    baseprice_BusPrice DECIMAL (5, 2) NOT NULL,
    -- Primary Key(s):
    PRIMARY KEY (baseprice_Size, baseprice_CrustType),
    -- Add index on `baseprice_CrustType` for FK referencing
    INDEX idx_baseprice_CrustType (baseprice_CrustType)
);

CREATE TABLE topping (
    topping_topID INT AUTO_INCREMENT,
    topping_TopName VARCHAR(30) NOT NULL,
    topping_SmallAMT DECIMAL(5, 2) NOT NULL,
    topping_MedAMT DECIMAL(5, 2) NOT NULL,
    topping_LgAMT DECIMAL(5, 2) NOT NULL,
    topping_XLAMT DECIMAL(5, 2) NOT NULL,
    topping_CustPrice DECIMAL(5, 2) NOT NULL,
    topping_BusPrice DECIMAL(5, 2) NOT NULL,
    topping_MinINVT INT NOT NULL,
    topping_CurINVT INT NOT NULL,
    -- Primary Key(s):
    PRIMARY KEY (topping_TopID)
);

CREATE TABLE discount (
    discount_DiscountID INT AUTO_INCREMENT NOT NULL,
    discount_DiscountName VARCHAR(30) NOT NULL,
    discount_Amount DECIMAL(5, 2) NOT NULL,
    discount_IsPercent TINYINT NOT NULL,
    -- Primary Key(s):
    PRIMARY KEY (discount_DiscountID)
);

CREATE TABLE customer (
    customer_CustID INT AUTO_INCREMENT NOT NULL,
    customer_FName VARCHAR(30) NOT NULL,
    customer_LName VARCHAR(30) NOT NULL,
    customer_PhoneNum VARCHAR(30) NOT NULL,
    -- Primary Key(s):
    PRIMARY KEY (customer_CustID)
);
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

-- * * * * * Tables with FKs that are referenced by other tables * * * * *
-- NOTE: pizza references ordertable, so
--       ordertable must be created first
CREATE TABLE ordertable (
    ordertable_OrderID INT AUTO_INCREMENT NOT NULL,
    customer_CustID INT,
    ordertable_OrderType VARCHAR(30) NOT NULL,
    ordertable_OrderDateTime DATETIME NOT NULL,
    ordertable_CustPrice DECIMAL(5, 2) NOT NULL,
    ordertable_BusPrice DECIMAL(5, 2) NOT NULL,
    ordertable_isComplete TINYINT(1) DEFAULT 0,
    -- Primary Key(s):
    PRIMARY KEY (ordertable_OrderID),
    -- Foreign Key(s):
    CONSTRAINT ordertable_fk_CustID
        FOREIGN KEY (customer_CustID)
        REFERENCES customer(customer_CustID)
);

CREATE TABLE pizza (
    pizza_PizzaID INT AUTO_INCREMENT,
    pizza_Size VARCHAR(30), -- NOTE: Why not baseprice_Size?
    pizza_CrustType VARCHAR(30), -- NOTE: Why not baseprice_CrustType?
    pizza_PizzaState VARCHAR(30),
    pizza_PizzaDate DATETIME,
    pizza_CustPrice DECIMAL(5, 2),
    pizza_BusPrice DECIMAL (5, 2),
    ordertable_OrderID INT,
    -- Primary Key(s):
    PRIMARY KEY (pizza_PizzaID),
    -- Foreign Key(s):
    CONSTRAINT pizza_fk_Size
        FOREIGN KEY (pizza_Size)
        REFERENCES baseprice(baseprice_Size),
    CONSTRAINT pizza_fk_CrustType
        FOREIGN KEY (pizza_CrustType)
        REFERENCES baseprice(baseprice_CrustType),
    CONSTRAINT pizza_fk_OrderID
        FOREIGN KEY (ordertable_OrderID)
        REFERENCES ordertable(ordertable_OrderID)
);
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

-- * * * * * * * * * * * * * * Bridge tables * * * * * * * * * * * * * * *
-- Bridge table for the `pizza` and `topping` tables
CREATE TABLE pizza_topping (
    pizza_PizzaID INT NOT NULL,
    topping_TopID INT NOT NULL,
    pizza_topping_IsDouble INT NOT NULL,
    -- Primary Key(s):
    PRIMARY KEY(pizza_PizzaID, topping_TopID),
    -- Foreign Key(s):
    CONSTRAINT pizza_topping_fk_PizzaID
        FOREIGN KEY (pizza_PizzaID)
        REFERENCES pizza(pizza_PizzaID),
    CONSTRAINT pizza_topping_fk_TopID
        FOREIGN KEY (topping_TopID)
        REFERENCES topping(topping_TopID)
);

-- Bridge table for the `pizza` and `discount` tables
CREATE TABLE pizza_discount (
    pizza_PizzaID INT,
    discount_DiscountID INT,
    -- Primary Key(s):
    PRIMARY KEY (pizza_PizzaID, discount_DiscountID),
    -- Foreign Key(s):
    CONSTRAINT pizza_discount_fk_PizzaID
        FOREIGN KEY (pizza_PizzaID)
        REFERENCES pizza(pizza_PizzaID),
    CONSTRAINT pizza_discount_fk_DiscountID
        FOREIGN KEY (discount_DiscountID)
        REFERENCES discount(discount_DiscountID)
);

-- Bridge table for the `order` and `discount` tables
CREATE TABLE order_discount (
    ordertable_OrderID INT,
    discount_DiscountID INT,
    -- Primary Key(s):
    PRIMARY KEY (ordertable_OrderID, discount_DiscountID),
    -- Foreign Key(s):
    CONSTRAINT order_discount_fk_OrderID
        FOREIGN KEY (ordertable_OrderID)
        REFERENCES ordertable(ordertable_OrderID),
    CONSTRAINT order_discount_fk_DiscountID
        FOREIGN KEY (discount_DiscountID)
        REFERENCES discount(discount_DiscountID)
);
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

-- * * * * * * * * * * * * * * Subtype tables * * * * * * * * * * * * * *
-- Used to represent the three subtypes ['pickup', 'delivery', 'dinein']
-- for the supertype 'order'
CREATE TABLE pickup (
    ordertable_OrderID INT NOT NULL,
    pickup_IsPickedUp TINYINT NOT NULL DEFAULT 0,
    -- Primary Key(s):
    PRIMARY KEY (ordertable_OrderID),
    -- Foreign Key(s):
    CONSTRAINT pickup_fk_OrderID
        FOREIGN KEY (ordertable_OrderID)
        REFERENCES ordertable(ordertable_OrderID)
);

CREATE TABLE delivery (
    ordertable_OrderID INT NOT NULL,
    delivery_HouseNum INT NOT NULL,
    delivery_Street VARCHAR(30) NOT NULL,
    delivery_City VARCHAR(30) NOT NULL,
    delivery_State VARCHAR(2) NOT NULL,
    delivery_Zip INT NOT NULL,
    delivery_isDelivered TINYINT NOT NULL DEFAULT 0,
    -- Primary Key(s):
    PRIMARY KEY (ordertable_OrderID),
    -- Foreign Key(s):
    CONSTRAINT delivery_fk_OrderID
        FOREIGN KEY (ordertable_OrderID)
        REFERENCES ordertable(ordertable_OrderID)
);

CREATE TABLE dinein (
    ordertable_OrderID INT NOT NULL,
    dinein_TableNum INT NOT NULL,
    -- Primary Key(s):
    PRIMARY KEY (ordertable_OrderID),
    -- Foreign Key(s):
    CONSTRAINT dinein_fk_OrderID
    FOREIGN KEY (ordertable_OrderID)
    REFERENCES ordertable(ordertable_OrderID)
);
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *