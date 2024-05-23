CREATE DATABASE PharmacyDBDemo;
GO

USE PharmacyDBDemo;
GO

-- Address Table
CREATE TABLE Address (
    AddressID INT PRIMARY KEY,
    Street VARCHAR(255) NOT NULL,
    City VARCHAR(255) NOT NULL,
    State CHAR(2) NOT NULL,
    ZipCode CHAR(10) NOT NULL,
   -- PatientID INT,
    --CONSTRAINT FK_Address_Patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
);
GO

-- Patient Table
CREATE TABLE Patient (
    PatientID INT PRIMARY KEY,
    AddressID INT,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email VARCHAR(255),
    ContactNumber VARCHAR(20),
    PreviousPurchase BIT NOT NULL,
	BirthDate DATE,
    CONSTRAINT FK_Patient_Address FOREIGN KEY (AddressID) REFERENCES Address(AddressID)
);
GO

-- CHECK constraint to ensure valid email format (simplified regex pattern) 1
ALTER TABLE Patient
ADD CONSTRAINT CHK_Patient_Email CHECK (Email LIKE '%_@__%.__%');
GO

-- Physician Table
CREATE TABLE Physician (
    PhysicianID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Specialty VARCHAR(255),
    PhoneNumber VARCHAR(20),
    VisitingHospital VARCHAR(255)
);
GO

-- Prescription Table
CREATE TABLE Prescription (
    PrescriptionID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    PhysicianID INT NOT NULL,
    DateIssued DATE NOT NULL,
    Dosage VARCHAR(255) NOT NULL,
    CONSTRAINT FK_Prescription_Patient FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT FK_Prescription_Physician FOREIGN KEY (PhysicianID) REFERENCES Physician(PhysicianID)
);
GO

-- CHECK constraint to ensure the Dosage is not empty2
ALTER TABLE Prescription
ADD CONSTRAINT CHK_Prescription_Dosage CHECK (Dosage <> '');
GO

-- MedicationItem Table
CREATE TABLE MedicationItem (
    MedicationItemID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Description TEXT,
    SideEffects TEXT,
    ExpiryDate DATE NOT NULL
);
GO

-- CHECK constraint to ensure the ExpiryDate is in the future3
ALTER TABLE MedicationItem
ADD CONSTRAINT CHK_MedicationItem_ExpiryDate CHECK (ExpiryDate > GETDATE());
GO

-- Pharmacy Table
CREATE TABLE Pharmacy (
    PharmacyID INT PRIMARY KEY,
    ShopName VARCHAR(255) NOT NULL,
    ShopStreet VARCHAR(255) NOT NULL,
    ShopCity VARCHAR(255) NOT NULL,
    ShopState CHAR(2) NOT NULL,
    ShopZipCode CHAR(10) NOT NULL,
    PhoneNumber VARCHAR(20)
);
GO

-- Inventory Table
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY,
    PharmacyID INT NOT NULL,
    MedicationItemID INT NOT NULL,
    Quantity INT NOT NULL,
    CONSTRAINT FK_Inventory_Pharmacy FOREIGN KEY (PharmacyID) REFERENCES Pharmacy(PharmacyID),
    CONSTRAINT FK_Inventory_MedicationItem FOREIGN KEY (MedicationItemID) REFERENCES MedicationItem(MedicationItemID)
);
GO

-- CHECK constraint to ensure Quantity is not negative4
ALTER TABLE Inventory
ADD CONSTRAINT CHK_Inventory_Quantity CHECK (Quantity >= 0);
GO

-- Order Table
CREATE TABLE [Order] (
    OrderID INT PRIMARY KEY,
    PharmacyID INT NOT NULL,
    PrescriptionID INT NOT NULL,
    OrderDate DATE NOT NULL,
    DeliveryDate DATE,
    TotalPrice DECIMAL(10, 2), -- Assuming this is calculated elsewhere and not a computed column here
    CONSTRAINT FK_Order_Pharmacy FOREIGN KEY (PharmacyID) REFERENCES Pharmacy(PharmacyID),
    CONSTRAINT FK_Order_Prescription FOREIGN KEY (PrescriptionID) REFERENCES Prescription(PrescriptionID)
);
GO

-- OrderItem Table
CREATE TABLE OrderItem (
    OrderItemID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    MedicationItemID INT NOT NULL,
    OrderQuantity INT NOT NULL,
    Dosage VARCHAR(255),
    CONSTRAINT FK_OrderItem_Order FOREIGN KEY (OrderID) REFERENCES [Order](OrderID),
    CONSTRAINT FK_OrderItem_MedicationItem FOREIGN KEY (MedicationItemID) REFERENCES MedicationItem(MedicationItemID)
);
GO

-- DeliveryPerson Table
CREATE TABLE DeliveryPerson (
    DeliveryPersonID INT PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email VARCHAR(255),
    ContactNumber VARCHAR(20)
);
GO

-- Delivery Table
CREATE TABLE Delivery (
    DeliveryID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    DeliveryPersonID INT NOT NULL,
    DeliveryDate DATE NOT NULL,
    EstimatedDeliveryDate DATE NOT NULL,
    CONSTRAINT FK_Delivery_Order FOREIGN KEY (OrderID) REFERENCES [Order](OrderID),
    CONSTRAINT FK_Delivery_DeliveryPerson FOREIGN KEY (DeliveryPersonID) REFERENCES DeliveryPerson(DeliveryPersonID)
);
GO

-- CHECK constraint to ensure the EstimatedDeliveryDate is after the OrderDate5
ALTER TABLE Delivery
ADD CONSTRAINT CHK_Delivery_Dates CHECK (EstimatedDeliveryDate >= DeliveryDate);
GO

-- Supplier Table
CREATE TABLE Supplier (
    SupplierID INT PRIMARY KEY,
    SupplierFirstName VARCHAR(255) NOT NULL,
    SupplierLastName VARCHAR(255) NOT NULL,
    ContactNumber VARCHAR(20),
    SupplierEmail VARCHAR(255),
    SupplierStreet VARCHAR(255) NOT NULL,
    SupplierCity VARCHAR(255) NOT NULL,
    SupplierState CHAR(2) NOT NULL,
    SupplierZipCode CHAR(10) NOT NULL
);
GO

-- SupplyRecord Table
CREATE TABLE SupplyRecord (
    SupplyRecordID INT PRIMARY KEY,
    SupplierID INT NOT NULL,
    PharmacyID INT NOT NULL,
    MedicationItemID INT NOT NULL,
    SupplyDate DATE NOT NULL,
    QuantitySupplied INT NOT NULL,
    CONSTRAINT FK_SupplyRecord_Supplier FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
    CONSTRAINT FK_SupplyRecord_Pharmacy FOREIGN KEY (PharmacyID) REFERENCES Pharmacy(PharmacyID),
    CONSTRAINT FK_SupplyRecord_MedicationItem FOREIGN KEY (MedicationItemID) REFERENCES MedicationItem(MedicationItemID)
);
GO

-- CHECK constraint to ensure QuantitySupplied is positive6
ALTER TABLE SupplyRecord
ADD CONSTRAINT CHK_SupplyRecord_QuantitySupplied CHECK (QuantitySupplied > 0);
GO

-- Transaction Table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    TransactionDate DATE NOT NULL,
    PaymentMethod VARCHAR(50) NOT NULL,
    CONSTRAINT FK_Transaction_Order FOREIGN KEY (OrderID) REFERENCES [Order](OrderID)
);
GO

-- CHECK constraint to ensure Amount is positive7
ALTER TABLE Transactions
ADD CONSTRAINT CHK_Transaction_Amount CHECK (Amount > 0);
GO

-----------------------------------Views-----------------------------------------------------------------------

-- View for Patient Addresses
GO
CREATE VIEW ViewPatientAddresses AS
SELECT p.PatientID, p.FirstName, p.LastName, a.Street, a.City, a.State, a.ZipCode
FROM Patient p
JOIN Address a ON p.AddressID = a.AddressID;


-- View for Medication Details
GO
CREATE VIEW ViewMedicationDetails AS
SELECT m.MedicationItemID, m.Name, m.Description, m.SideEffects, m.ExpiryDate
FROM MedicationItem m;


-- View for Supplier Information
GO
CREATE VIEW ViewSupplierInformation AS
SELECT s.SupplierID, s.SupplierFirstName, s.SupplierLastName, s.SupplierEmail
FROM Supplier s;

-- View for Prescription Details
GO
CREATE VIEW ViewPrescriptionDetails AS
SELECT pr.PrescriptionID, pa.FirstName + ' ' + pa.LastName AS PatientName, ph.Name AS PhysicianName, pr.DateIssued, pr.Dosage
FROM Prescription pr
JOIN Patient pa ON pr.PatientID = pa.PatientID
JOIN Physician ph ON pr.PhysicianID = ph.PhysicianID;

---------------------------------Stored Procedures-------------------------------------------------------------

-- Stored Procedure to get patient information
GO
CREATE PROCEDURE GetPatientInfo
    @PatientID INT,
    @PatientInfo NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SELECT @PatientInfo = CONCAT(FirstName, ' ', LastName, ', Email: ', Email)
    FROM Patient
    WHERE PatientID = @PatientID;
END;
select * from patient
DECLARE @PatientInfoOutput NVARCHAR(MAX);
EXEC GetPatientInfo @PatientID = 2019, @PatientInfo = @PatientInfoOutput OUTPUT;
SELECT @PatientInfoOutput AS PatientInfo;



-- Stored Procedure to update reduced inventory
GO
CREATE PROCEDURE UpdateInventory
    @PharmacyID INT,
    @MedicationItemID INT,
    @Quantity INT
AS
BEGIN
    UPDATE Inventory
    SET Quantity = Quantity - @Quantity
    WHERE PharmacyID = @PharmacyID AND MedicationItemID = @MedicationItemID;
END;

EXEC UpdateInventory @PharmacyID = 2000, @MedicationItemID = 2000, @Quantity = 10;

-- Stored Procedure to update reduced inventory
GO
CREATE PROCEDURE UpdateNewInventory
    @PharmacyID INT,
    @MedicationItemID INT,
    @Quantity INT
AS
BEGIN
    UPDATE Inventory
    SET Quantity = Quantity + @Quantity
    WHERE PharmacyID = @PharmacyID AND MedicationItemID = @MedicationItemID;
END;

EXEC UpdateInventory @PharmacyID = 2000, @MedicationItemID = 2000, @Quantity = 10;


-- Stored Procedure to get supplier contact details
GO
CREATE PROCEDURE GetSupplierContact
    @SupplierID INT,
    @ContactDetails NVARCHAR(MAX) OUTPUT
AS
BEGIN
    SELECT @ContactDetails = CONCAT(SupplierFirstName, ' ', SupplierLastName, ', Email: ', SupplierEmail)
    FROM Supplier
    WHERE SupplierID = @SupplierID;
END;

DECLARE @SupplierContactOutput NVARCHAR(MAX);
EXEC GetSupplierContact @SupplierID = 1, @ContactDetails = @SupplierContactOutput OUTPUT;
SELECT @SupplierContactOutput AS ContactDetail




---------------------------------------User Defined Functions -----------------------------------------------
--1)User Defined Function to calculate medicine Supply Value
GO
CREATE FUNCTION CalculatedSupplyValues (@QuantitySupplied INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @UnitPrice DECIMAL(10, 2) = 10.00; -- Assuming a fixed unit price
    RETURN @QuantitySupplied * @UnitPrice;
END;
GO

ALTER TABLE SupplyRecord
ADD TotalValue AS dbo.CalculatedSupplyValues(QuantitySupplied);
GO

--2)User Defined Function to get Order Duration 

CREATE FUNCTION GetOrderDuration (@OrderDate DATE, @DeliveryDate DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(DAY, @OrderDate, @DeliveryDate);
END;
GO

ALTER TABLE [Order]
ADD OrderDuration AS dbo.GetOrderDuration(OrderDate, DeliveryDate);
GO

---3)User Defined Function to get Full address of the Suplier

CREATE FUNCTION GetSupplierFullAddress (
    @Street VARCHAR(255),
    @City VARCHAR(255),
    @State CHAR(2),
    @ZipCode CHAR(10)
)
RETURNS VARCHAR(322)
AS
BEGIN
    RETURN CONCAT(@Street, ', ', @City, ', ', @State, ' ', @ZipCode);
END;
GO

ALTER TABLE Supplier
ADD FullAddress AS dbo.GetSupplierFullAddress(SupplierStreet, SupplierCity, SupplierState, SupplierZipCode);
GO
--4)User Defined Function for calculating the age of the patient 

CREATE FUNCTION CalculatePatientAge (@BirthDate DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @BirthDate, GETDATE()) - CASE
        WHEN (MONTH(@BirthDate) > MONTH(GETDATE())) OR (MONTH(@BirthDate) = MONTH(GETDATE()) AND DAY(@BirthDate) > DAY(GETDATE()))
        THEN 1
        ELSE 0
    END;
END;
GO

ALTER TABLE Patient
ADD Age AS dbo.CalculatePatientAge(BirthDate);
GO

-- 5)User Defined Function to calculate full name
GO
CREATE FUNCTION GetFullNames (@FirstName VARCHAR(255), @LastName VARCHAR(255))
RETURNS VARCHAR(510)
AS
BEGIN
    RETURN CONCAT(@FirstName, ' ', @LastName);
END;
GO -- This was missing, causing the "Incorrect syntax near the keyword 'ALTER'" error

ALTER TABLE Patient
ADD P_FullNames AS dbo.GetFullNames(FirstName, LastName);
GO

------------------------------------Triggers---------------------

CREATE TABLE PrescriptionAudit (
    AuditID INT PRIMARY KEY IDENTITY(1,1), 
    PrescriptionID INT,
    Changes VARCHAR(255),
    ChangeDate DATETIME
);
GO
---trigger to track dosage changes         
CREATE TRIGGER trgAfterUpdatePrescription
ON Prescription
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO PrescriptionAudit (PrescriptionID, Changes, ChangeDate)
    SELECT i.PrescriptionID, 'Dosage updated', GETDATE()
    FROM inserted i
    INNER JOIN deleted d ON d.PrescriptionID = i.PrescriptionID
    WHERE d.Dosage <> i.Dosage;
END;
GO

UPDATE Prescription
SET Dosage = '1 new daily'
WHERE PrescriptionID = 2000;

select* from PrescriptionAudit

-----trigger to alert when the inventory is below 10 
GO
CREATE TRIGGER trgCheckInventory
ON Inventory
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted WHERE Quantity < 10)
    BEGIN
        RAISERROR ('Inventory level is below 10!', 16, 1);
    END
END;
GO

UPDATE Inventory
SET Quantity = 15 -- This value is less than 10 and should trigger the trgCheckInventory
WHERE InventoryID = 2002;

-------------------------Column Data Encryption------------------------
--Modify the tables to add varbinary columns for the encrypted data
ALTER TABLE Patient ADD EmailEncrypted VARBINARY(400);
ALTER TABLE Physician ADD PhoneNumberEncrypted VARBINARY(400);
ALTER TABLE DeliveryPerson ADD ContactNumberEncrypted VARBINARY(400);
ALTER TABLE Supplier ADD SupplierEmailEncrypted VARBINARY(400);
GO

---create the masterKey and certificate 


CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'yourStrongPasswordHere';
GO

CREATE CERTIFICATE PharmacyDBDemoCertificate WITH SUBJECT = 'PharmacyDBDemo Encryption';
GO

CREATE SYMMETRIC KEY PharmacyDBDemoSymmetricKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE PharmacyDBDemoCertificate;
GO

----------encrypt the data
-- Open the symmetric key
OPEN SYMMETRIC KEY PharmacyDBDemoSymmetricKey
   DECRYPTION BY CERTIFICATE PharmacyDBDemoCertificate;

-- Encrypt the data
UPDATE Patient SET EmailEncrypted = EncryptByKey(Key_GUID('PharmacyDBDemoSymmetricKey'), CONVERT(VARBINARY, Email));
UPDATE Physician SET PhoneNumberEncrypted = EncryptByKey(Key_GUID('PharmacyDBDemoSymmetricKey'), CONVERT(VARBINARY, PhoneNumber));
UPDATE DeliveryPerson SET ContactNumberEncrypted = EncryptByKey(Key_GUID('PharmacyDBDemoSymmetricKey'), CONVERT(VARBINARY, ContactNumber));
UPDATE Supplier SET SupplierEmailEncrypted = EncryptByKey(Key_GUID('PharmacyDBDemoSymmetricKey'), CONVERT(VARBINARY, SupplierEmail));

-- Close the symmetric key
CLOSE SYMMETRIC KEY PharmacyDBDemoSymmetricKey;
GO
--------------------------------------------------------Non Clustered Indexex------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_Patient_AddressID ON Patient (AddressID);
GO

CREATE NONCLUSTERED INDEX IX_Order_PharmacyID_PrescriptionID ON [Order] (PharmacyID, PrescriptionID);
GO

CREATE NONCLUSTERED INDEX IX_Inventory_MedicationItemID ON Inventory (MedicationItemID);
GO

CREATE NONCLUSTERED INDEX IX_SupplyRecord_PharmacyID_MedicationItemID ON SupplyRecord (PharmacyID, MedicationItemID);
GO

---Verify the existence of the non-clustered indexes
SELECT 
    i.name AS IndexName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.type_desc AS IndexType
FROM 
    sys.indexes i
WHERE 
    i.type_desc = 'NONCLUSTERED'
    AND OBJECT_NAME(i.object_id) IN ('Patient', 'Order', 'Inventory', 'SupplyRecord');

---Measure the performance of queries with and without the non-clustered indexes

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Run a query that would benefit from the non-clustered index
SELECT * FROM Patient WHERE AddressID = 2000;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

