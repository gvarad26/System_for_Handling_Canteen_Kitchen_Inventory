# System_for_Handling_Canteen_Kitchen_Inventory

# Order Management System - Short README

## Overview
This system manages orders, suppliers, and items, ensuring data consistency and automation through triggers and packages.

## Key Tables
1. **Orders**: Stores order details, including quantity, order date, and priority.
2. **Suppliers**: Contains supplier information such as name and location.
3. **Items**: Maintains item details like name, price, and last order date.

## Triggers
1. **BeforePlaceOrder**: Sets order priority based on quantity.
2. **AfterPlaceOrder**: Updates the last order date in `Items`.
3. **BeforeUpdateOrderQuantity**: Validates non-negative quantities.
4. **AfterUpdateOrderQuantity**: Updates total ordered quantity in `Orders`.

## Package: TransactionPackage
1. **IncreaseItemPrice**: Adjusts item price by a percentage.
2. **CalculateOrderTotal**: Computes total order value based on item and quantity.

## Usage
- Retrieve data:
  ```sql
  SELECT * FROM Items;
  SELECT * FROM Suppliers;
  SELECT * FROM Orders;
  ```
- Call procedures:
  ```sql
  EXEC TransactionPackage.IncreaseItemPrice('Rice', 10);
  SELECT TransactionPackage.CalculateOrderTotal(10, 'Rice') FROM DUAL;
  ```

## Notes
- Use `COMMIT` to save changes.
- Follow foreign key constraints for data integrity.

For detailed documentation, refer to the extended README.

