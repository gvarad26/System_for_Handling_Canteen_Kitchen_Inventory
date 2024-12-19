CREATE TABLE Orders (OrderID INT PRIMARY KEY,ItemID INT,Quantity INT,OrderDate DATE,TotalOrderedQuantity INT DEFAULT 0,OrderPriority VARCHAR2(50) DEFAULT 'Normal');


INSERT INTO Orders (OrderID, ItemID, Quantity, OrderDate) VALUES (1, 1, 10,to_date('15-01-2023','dd-mm-yyyy'));
INSERT INTO Orders (OrderID, ItemID, Quantity, OrderDate) VALUES (2, 2, 5, to_date('16-01-2023','dd-mm-yyyy'));
INSERT INTO Orders (OrderID, ItemID, Quantity, OrderDate) VALUES (3, 1, 20,to_date('16-01-2023','dd-mm-yyyy'));
INSERT INTO Orders (OrderID, ItemID, Quantity, OrderDate) VALUES (4, 3, 15,to_date('17-01-2023','dd-mm-yyyy'));
INSERT INTO Orders (OrderID, ItemID, Quantity, OrderDate) VALUES (5, 4, 30,to_date('18-01-2023','dd-mm-yyyy'));

    UPDATE Orders
    SET TotalOrderedQuantity = Quantity;
    
    -- Commit the changes
    COMMIT;
-- Add a new column to the Orders table


CREATE TABLE Suppliers (SupplierID INT PRIMARY KEY, SName VARCHAR(255) NOT NULL,Contact NUMBER,SLocation VARCHAR(255));

INSERT INTO Suppliers (SupplierID, SName, Contact, SLocation) VALUES (1, 'ABC Supplier',7055671231 , '123 Main St India');
INSERT INTO Suppliers (SupplierID, SName, Contact, SLocation) VALUES (2, 'XYZ Foods',7086586453 , '456 Oak St Pakistan' );
INSERT INTO Suppliers (SupplierID, SName, Contact, SLocation) VALUES (3, 'Fresh Produce Co.',9897671542 ,'789 Elm St Bangladesh' );
INSERT INTO Suppliers (SupplierID, SName, Contact, SLocation) VALUES (4, 'Golden Grains Inc.',9867192451 ,'101 Maple Ave Sri Lanka' );
INSERT INTO Suppliers (SupplierID, SName, Contact, SLocation) VALUES (5, 'Fishermans Catch',9923556712 , '222 Harbor Dr Nepal');



CREATE TABLE Items (ItemID INT PRIMARY KEY,ItemName VARCHAR(255),Veg_Nonveg VARCHAR(255),UnitPrice DECIMAL(10, 2),SupplierID INT REFERENCES Suppliers(SupplierID),LastOrderDate DATE);

INSERT INTO Items (ItemID, ItemName, Veg_Nonveg, UnitPrice,SupplierID) VALUES (1, 'Rice', 'Veg', 15,4);
INSERT INTO Items (ItemID, ItemName, Veg_Nonveg, UnitPrice,SupplierID) VALUES (2, 'Chicken', 'Non-Veg', 50,2);
INSERT INTO Items (ItemID, ItemName, Veg_Nonveg, UnitPrice,SupplierID) VALUES (3, 'Vegetables', 'Veg', 20,1);
INSERT INTO Items (ItemID, ItemName, Veg_Nonveg, UnitPrice,SupplierID) VALUES (4, 'Soda', 'Veg', 10,5);
INSERT INTO Items (ItemID, ItemName, Veg_Nonveg, UnitPrice,SupplierID) VALUES (5, 'Ice Cream', 'Veg', 30,3);

UPDATE Items I
SET LastOrderDate = (
    SELECT MAX(O.OrderDate)
    FROM Orders O
    WHERE O.ItemID = I.ItemID
);

-- Commit the changes
COMMIT;


SELECT *FROM Items;
SELECT *FROM Suppliers; 

SELECT *FROM Orders;  
  
CREATE OR REPLACE TRIGGER BeforePlaceOrder
BEFORE INSERT ON Orders
FOR EACH ROW
DECLARE
    v_OrderPriority VARCHAR2(50);
BEGIN
    -- Determine the order priority based on the quantity being ordered
    IF :NEW.Quantity > 50 THEN
        v_OrderPriority := 'High';
    ELSE
        v_OrderPriority := 'Normal';
    END IF;

    -- Update the OrderPriority column in the Items table
    UPDATE Orders
    SET OrderPriority = v_OrderPriority
    WHERE OrderID = :NEW.OrderID;

    -- You can add other checks or logic before placing the order
END BeforePlaceOrder;
/




CREATE OR REPLACE TRIGGER AfterPlaceOrder
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    -- Update the last order date for the corresponding item after placing the order
    UPDATE Items
    SET LastOrderDate = :NEW.OrderDate
    WHERE ItemID = :NEW.ItemID;

    -- You can add other logic after placing the order
END AfterPlaceOrder;




   -- Before and after triggers for updating order quantity
  CREATE OR REPLACE TRIGGER BeforeUpdateOrderQuantity
  BEFORE UPDATE OF Quantity ON Orders
  FOR EACH ROW
  BEGIN
    -- Check if the updated quantity is valid (e.g., non-negative)
    IF :NEW.Quantity < 0 THEN
      RAISE_APPLICATION_ERROR(-20004, 'Invalid order quantity.');
    END IF;

    -- You can add other checks or logic before updating order quantity
  END BeforeUpdateOrderQuantity;





  CREATE OR REPLACE TRIGGER AfterUpdateOrderQuantity
  AFTER UPDATE OF Quantity ON Orders
  FOR EACH ROW
  BEGIN
    -- Update the TotalOrderedQuantity in the Orders table
    UPDATE Orders
    SET TotalOrderedQuantity = TotalOrderedQuantity + :NEW.Quantity
    WHERE OrderID = :NEW.OrderID;

    -- You can add other logic after updating order quantity
  END AfterUpdateOrderQuantity;
/




-- Create or replace package
CREATE OR REPLACE PACKAGE TransactionPackage AS
  -- Procedure to place an order
  PROCEDURE IncreaseItemPrice (p_ItemIdentifier IN VARCHAR2, p_Percentage IN NUMBER);

  -- Function to calculate the total value of an order
  FUNCTION  CalculateOrderTotal(p_Quantity IN INT,p_ItemName IN VARCHAR2) RETURN DECIMAL;
  END TransactionPackage;
  
  
  
  
-- Create or replace package body
CREATE OR REPLACE PACKAGE BODY TransactionPackage AS
PROCEDURE IncreaseItemPrice (p_ItemIdentifier IN VARCHAR2, p_Percentage IN NUMBER)  
AS
    v_ItemID INT;
    v_CurrentUnitPrice DECIMAL(10, 2);
    v_NewUnitPrice DECIMAL(10, 2);
BEGIN
    -- Identify the item ID based on the provided name or ID
    SELECT ItemID, UnitPrice
    INTO v_ItemID, v_CurrentUnitPrice
    FROM Items
    WHERE ItemName = p_ItemIdentifier OR ItemID = TO_NUMBER(p_ItemIdentifier);

    -- Check if the item is found
    IF v_ItemID IS NOT NULL THEN
        -- Calculate the new unit price based on the raised percentage
        v_NewUnitPrice := v_CurrentUnitPrice + (v_CurrentUnitPrice * (p_Percentage / 100));

        -- Update the UnitPrice in the Items table
        UPDATE Items
        SET UnitPrice = v_NewUnitPrice
        WHERE ItemID = v_ItemID;

        DBMS_OUTPUT.PUT_LINE('Item price updated successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Item not found.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END IncreaseItemPrice;



  -- Function to calculate the total value of an order
 FUNCTION CalculateOrderTotal(p_Quantity IN INT,p_ItemName IN VARCHAR2) RETURN DECIMAL
IS
    v_TotalValue DECIMAL := 0;
BEGIN
    SELECT SUM(p_Quantity * UnitPrice)
    INTO v_TotalValue
    FROM Orders O
    JOIN Items I ON O.ItemID = I.ItemID
    WHERE I.ItemName = p_ItemName;

    IF v_TotalValue IS NULL THEN
        RAISE_APPLICATION_ERROR(-20983, 'Item not found or insufficient stock for the selected item.');
    END IF;

    RETURN v_TotalValue;

EXCEPTION
    WHEN OTHERS THEN
        -- Handle exceptions
        DBMS_OUTPUT.PUT_LINE('Error calculating order total: ' || SQLERRM);
        RETURN -1;
END CalculateOrderTotal;

END TransactionPackage;
/





