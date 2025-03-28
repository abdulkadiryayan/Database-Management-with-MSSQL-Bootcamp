--SORU 1: Northwind veritabanındaki tüm tabloları listeleyin.

SELECT COUNT(*) AS TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';


--SORU 2: En fazla sipariş veren müşteriyi bulun.

SELECT O.OrderID, C.CompanyName, E.FirstName, E.LastName, O.OrderDate, S.CompanyName AS Shipper
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
JOIN Employees E ON O.EmployeeID = E.EmployeeID
JOIN Shippers S ON O.ShipVia = S.ShipperID;


--SORU 3: En pahalı ürünü getirin.

SELECT SUM(OD.Quantity * OD.UnitPrice) AS ToplamTutar
FROM [Order Details] OD;


--SORU 4: En çok sipariş verilen ürünü bulun.

SELECT Country, COUNT(*) AS Sayıları
FROM Customers
GROUP BY Country;


--SORU 5: 1997 yılında verilen siparişleri getirin.

SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice = (SELECT MAX(UnitPrice) FROM Products);


--SORU 6: Hangi çalışan en çok sipariş aldı?

SELECT E.EmployeeID, E.FirstName, E.LastName, COUNT(O.OrderID) AS SiparisSayısı
FROM Employees E
LEFT JOIN Orders O ON E.EmployeeID = O.EmployeeID
GROUP BY E.EmployeeID, E.FirstName, E.LastName;


--SORU 7: Hangi tedarikçi en fazla ürün sağladı?

SELECT * FROM Orders
WHERE YEAR(OrderDate) = 1997;


--SORU 8: Hangi ülkeye en fazla sipariş gönderildi?

SELECT ProductName, UnitPrice, 
	CASE 
		WHEN UnitPrice < 20 THEN 'Ucuz' 
		WHEN UnitPrice BETWEEN 20 AND 50 THEN 'Orta'
        ELSE 'Pahalı' END AS FiyatAralığı
FROM Products;


--SORU 9: Hangi müşteriye toplamda en fazla ödeme yapılmış?

SELECT P.ProductName, SUM(OD.Quantity) AS ToplamMiktar
FROM [Order Details] OD
JOIN Products P ON OD.ProductID = P.ProductID
GROUP BY P.ProductName
HAVING SUM(OD.Quantity) = (
    SELECT MAX(ToplamMiktar)
    FROM (
        SELECT SUM(Quantity) AS ToplamMiktar
        FROM [Order Details]
        GROUP BY ProductID
    ) AS SubQuery
);


--SORU 10: Çalışanların aldığı toplam sipariş sayısını listeleyin.

CREATE VIEW ÜrünVeKategorilerView AS
SELECT P.ProductID, P.ProductName, C.CategoryName, C.Description, P.Discontinued, P.ReorderLevel, P.UnitsOnOrder, P.UnitsInStock, P.QuantityPerUnit, P.UnitPrice 
FROM Products P
JOIN Categories C ON P.CategoryID = C.CategoryID;

SELECT * FROM ÜrünVeKategorilerView;


--SORU 11: Hangi yıl en fazla sipariş verilmiş?

CREATE TABLE ProductDeleteLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,   
    ProductID INT,                         
    ProductName NVARCHAR(255),             
    DeletedAt DATETIME DEFAULT GETDATE()   
);

CREATE TRIGGER trigger_DeleteProduct
ON Products
AFTER DELETE
AS
BEGIN
    INSERT INTO ProductDeleteLog (ProductID, ProductName, DeletedAt)
    SELECT deleted.ProductID, deleted.ProductName, GETDATE()
    FROM deleted;
END;

SELECT * FROM ProductDeleteLog;


--SORU 12: Ortalama sipariş miktarını bulun.

CREATE PROCEDURE MüşteriÜlke
    @Country NVARCHAR(50)
AS
BEGIN
    SELECT * FROM Customers WHERE Country = @Country;
END;


EXEC MüşteriÜlke @Country = 'Germany';


--SORU 13: En çok satılan ilk 5 ürünü listeleyin.

SELECT P.ProductID, P.ProductName, S.CompanyName AS Supplier
FROM Products P
LEFT JOIN Suppliers S ON P.SupplierID = S.SupplierID;


--SORU 14: En düşük fiyatlı 3 ürünü bulun.

SELECT ProductName, UnitPrice, (SELECT AVG(UnitPrice) FROM Products) AS AveragePrice
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Products);


--SORU 15: En çok sipariş edilen ürün kategorisini bulun.

SELECT TOP 1 E.EmployeeID, E.FirstName, E.LastName, SUM(OD.Quantity) AS SatışMiktarı
FROM Employees E
JOIN Orders O ON E.EmployeeID = O.EmployeeID
JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY E.EmployeeID, E.FirstName, E.LastName
ORDER BY SatışMiktarı DESC;


--SORU 16: Hangi kargo şirketi en fazla sipariş taşıdı?

SELECT ProductName, UnitsInStock
FROM Products
WHERE UnitsInStock < 10;


--SORU 17: Müşteriler ve aldıkları toplam sipariş sayısını listeleyin.

SELECT C.CompanyName, COUNT(O.OrderID) AS SiparisSayısı, SUM(OD.Quantity * OD.UnitPrice) AS ToplamTutar
FROM Customers C
JOIN Orders O ON C.CustomerID = O.CustomerID
JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY C.CompanyName;


--SORU 18: Hangi müşterinin en yüksek sipariş toplamı var?

SELECT TOP 1 Country, COUNT(CustomerID) AS MüşteriSayısı
FROM Customers
GROUP BY Country
ORDER BY MüşteriSayısı DESC;


--SORU 19: En düşük sipariş toplamına sahip müşteri kimdir?

SELECT O.OrderID, COUNT(DISTINCT OD.ProductID) AS ÜrünSayısı
FROM Orders O
JOIN [Order Details] OD ON O.OrderID = OD.OrderID
GROUP BY O.OrderID;


--SORU 20: Hangi ülke en fazla müşteri içeriyor?

SELECT C.CategoryName, AVG(P.UnitPrice) AS OrtalamaFiyat
FROM Products P
JOIN Categories C ON P.CategoryID = C.CategoryID
GROUP BY C.CategoryName;


--SORU 21: En yüksek fiyatlı siparişi bulan sorgu.

SELECT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, COUNT(OrderID) AS SiparisSayisi
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month;


--SORU 22: Çalışan başına düşen ortalama sipariş sayısını bulun.

SELECT E.EmployeeID, E.FirstName, E.LastName, COUNT(DISTINCT C.CustomerID) AS MüşteriSayısı
FROM Employees E
JOIN Orders O ON E.EmployeeID = O.EmployeeID
JOIN Customers C ON O.CustomerID = C.CustomerID
GROUP BY E.EmployeeID, E.FirstName, E.LastName;


--SORU 23: Hangi müşteri en fazla farklı ürün sipariş etmiş?

SELECT * FROM Customers
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Orders);


--SORU 24:Hangi siparişte en fazla ürün çeşidi bulunuyor? 

SELECT TOP 5 OrderID, Freight
FROM Orders
ORDER BY Freight DESC;









































