
/* MSIS618, Project Deliverable 3 - Database */
/* Group 4 */

/****************** ITEM 1: CREATE DATABASE ******************/
CREATE SCHEMA IF NOT EXISTS `DrugSecure` ;
USE `DrugSecure`;

Create Table `Storage`
(
Facility_ID Int NOT NULL AUTO_INCREMENT,
FacilityName Varchar(25) NOT NULL,
Facility_Address Varchar(50) NULL,
Facility_City Varchar(25) NULL,
Facility_State Varchar(25) NULL,
Facility_Zipcode Varchar(10) NULL,
Facility_Size Int NULL,
CONSTRAINT StoragePK PRIMARY KEY(Facility_ID),
CONSTRAINT StorageAK1 UNIQUE(FacilityName));

Create Table Drug
(
Drug_ID Int NOT NULL AUTO_INCREMENT,
Drug_Description Varchar(50) NOT NULL,
Drug_Type Varchar(25) NULL,
Shelf_Duration Int NULL, /* Number of Days */
Storage_Size Int NULL, /* Number of Pallets */
CONSTRAINT DrugPK PRIMARY KEY(Drug_ID),
CONSTRAINT DrugAK1 UNIQUE(Drug_Description));

Create Table Batch
(
Batch_ID Int NOT NULL AUTO_INCREMENT,
Drug_ID Int NOT NULL,
Original_Quantity Int NOT NULL,
Available_Quantity Int NULL,
Create_Date DATETIME NOT NULL,
Expiration_Date DATE NOT NULL,
CONSTRAINT BatchPK PRIMARY KEY(Batch_ID),
CONSTRAINT BatchFK FOREIGN KEY(Drug_ID)
REFERENCES DRUG(Drug_ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION,
CONSTRAINT Batch_Create_Check CHECK(Create_Date Between '1900-01-01 00:00:01' AND '2999-12-31 23:59:59'),
CONSTRAINT Batch_Expiration_Check1 CHECK(Expiration_Date Between '1900-01-01' AND '2999-12-31'),
CONSTRAINT Batch_Expiration_Check2 CHECK(Expiration_Date >= CAST(Create_Date AS DATE))
);

Create Table Health_Center
(
HC_ID Int NOT NULL AUTO_INCREMENT,
HC_Description Varchar(50) NOT NULL,
HC_Type Varchar(25) NULL,
HC_Address Varchar(50) NULL,
HC_City Varchar(25) NULL,
HC_State Varchar(25) NULL,
HC_Zipcode Varchar(10) NULL,
CONSTRAINT HC_PK PRIMARY KEY(HC_ID),
CONSTRAINT HC_AK1 UNIQUE(HC_Description),
CONSTRAINT HC_Type_Check CHECK (HC_Type IN ('Hospital', 'Health Center')));

Create Table Distribution_Center
(
Distribution_ID Int NOT NULL AUTO_INCREMENT,
Distribution_Description Varchar(50) NOT NULL,
Distribution_Address Varchar(50) NULL,
Distribution_City Varchar(25) NULL,
Distribution_State Varchar(25) NULL,
Distribution_Zipcode Varchar(10) NULL,
Facility_Distance Double NULL, /* In miles */
Facility_Duration Int NULL, /* In days */
Facility_Rush_Duration Int NULL, /* In days */
CONSTRAINT Distribution_PK PRIMARY KEY(Distribution_ID),
CONSTRAINT Distribution_AK1 UNIQUE(Distribution_Description)
);

Create Table D_H_Relationship
(
D_H_Relationship_ID Int NOT NULL AUTO_INCREMENT,
Distribution_ID Int NOT NULL,
HC_ID Int NOT NULL,
Distance Double NULL, /* In miles */
Duration Int NULL, /* In days */
RushDuration Int NULL, /* In days */
Fee Double NOT NULL, /* USD($) */
Rush_Fee Double NULL, /* USD($) */
Relationship_Start_Date DATE NULL,
Relationship_End_Date DATE NULL,
CONSTRAINT D_H_PK PRIMARY KEY(D_H_Relationship_ID),
CONSTRAINT D_H_FK1 FOREIGN KEY(Distribution_ID)
REFERENCES Distribution_Center(Distribution_ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION,
CONSTRAINT D_H_FK2 FOREIGN KEY(HC_ID)
REFERENCES Health_Center(HC_ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION,
CONSTRAINT D_H_RushDuration_Check CHECK(RushDuration <= Duration),
CONSTRAINT D_H_RelationshipStart_Check CHECK(Relationship_Start_Date BETWEEN '1900-01-01' AND '2999-12-31'),
CONSTRAINT D_H_RelationshipEnd_Check CHECK(Relationship_End_Date BETWEEN '1900-01-01' AND '2999-12-31'),
CONSTRAINT D_H_Relationship_Check CHECK(Relationship_End_Date >= Relationship_Start_Date)
);

Create Table Order_Type
(
Order_Type_ID Int NOT NULL AUTO_INCREMENT,
Order_Type_Description Varchar(25) NULL,
RushOrder Varchar(25) NULL,
CONSTRAINT Order_Type_PK PRIMARY KEY(Order_Type_ID),
CONSTRAINT Order_Type_Description_Check CHECK (Order_Type_Description IN ('Order', 'Reorder', 'Refill')),
CONSTRAINT Order_Type_Rush_Check CHECK (RushOrder IN ('Standard', 'Rush')));

Create Table `Order`
(
Order_ID Int NOT NULL AUTO_INCREMENT,
Drug_ID Int NOT NULL,
Batch_ID Int NOT NULL,
Facility_ID Int NOT NULL,
D_H_Relationship_ID Int NOT NULL,
Order_Type_ID Int NOT NULL,
Quantity Int NOT NULL,
Used_Quantity Int NOT NULL,
Cost Double NOT NULL, /* USD($) */
Size Int NULL, /* Number of pallets */
Order_Date DATE NOT NULL,
Delivery_By_Date DATE NULL,
DC_Delivery_Date DATE NULL,
HC_Delivery_Date DATE NULL,
CONSTRAINT Order_PK PRIMARY KEY(Order_ID),
CONSTRAINT Order_Drug_FK FOREIGN KEY(Drug_ID)
REFERENCES Drug(Drug_ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION,
CONSTRAINT Order_Batch_FK FOREIGN KEY(Batch_ID)
REFERENCES Batch(Batch_ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION,
CONSTRAINT Order_Storage_FK FOREIGN KEY(Facility_ID)
REFERENCES `Storage`(Facility_ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION,
CONSTRAINT Order_Relationship_FK FOREIGN KEY(D_H_Relationship_ID)
REFERENCES D_H_Relationship(D_H_Relationship_ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION,
CONSTRAINT Order_OrderType_FK FOREIGN KEY(Order_Type_ID)
REFERENCES Order_Type(Order_Type_ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION,
-- CONSTRAINT Order_Quantity_Check CHECK(Quantity <= 
-- (SELECT Available_Quantity FROM Batch WHERE (`Order`.BatchID = Batch.BatchID))),
CONSTRAINT Order_OrderDate_Check CHECK(Order_Date BETWEEN '1900-01-01' AND '2999-12-31'),
CONSTRAINT Order_Delivery_By_Check1 CHECK(Delivery_By_Date BETWEEN '1900-01-01' AND '2999-12-31'),
CONSTRAINT Order_Delivery_By_Check2 CHECK(Delivery_By_Date >= Order_Date),
CONSTRAINT Order_DC_Delivery_Check1 CHECK(DC_Delivery_Date BETWEEN '1900-01-01' AND '2999-12-31'),
CONSTRAINT Order_DC_Delivery_Check2 CHECK(DC_Delivery_Date >= Order_Date),
CONSTRAINT Order_HC_Delivery_Check1 CHECK(HC_Delivery_Date BETWEEN '1900-01-01' AND '2999-12-31'),
CONSTRAINT Order_HC_Delivery_Check2 CHECK(HC_Delivery_Date >= DC_Delivery_Date)
);

Create Table Health_Records
(
HealthRecords_ID Int NOT NULL AUTO_INCREMENT,
Treatment_Description Varchar(50) NOT NULL,
PatientNumber Int NOT NULL,
HC_ID Int NOT NULL,
Dosage Varchar(50) NOT NULL, /* Prescription Details */
Consumption_Duration Int NULL, /* In Days */
Visit_Date DATE NOT NULL,
CONSTRAINT Health_Records_PK PRIMARY KEY(HealthRecords_ID),
CONSTRAINT Health_Records_FK FOREIGN KEY (HC_ID)
REFERENCES Health_Center(HC_ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION,
CONSTRAINT Health_Records_AK1 UNIQUE(HC_ID, PatientNumber, Visit_Date)
);

Create Table Prescription
(
Prescription_ID Int NOT NULL AUTO_INCREMENT,
Drug_ID Int NOT NULL,
HealthRecords_ID Int NOT NULL,
CONSTRAINT Prescription_PK PRIMARY KEY(Prescription_ID, Drug_ID),
CONSTRAINT Prescription_FK FOREIGN KEY (HealthRecords_ID)
REFERENCES Health_Records(HealthRecords_ID)
ON UPDATE NO ACTION
ON DELETE NO ACTION);




INSERT INTO STORAGE
(Facility_ID, FacilityName, Facility_Address, Facility_City, Facility_State, Facility_ZipCode, Facility_Size)
	VALUES (001, 'AriseHelp', '16 Digital Way', 'Maynard', 'Massachusetts', '01745', '39902');

INSERT INTO ORDER_TYPE
(Order_Type_ID, Order_Type_Description, RushOrder)
	VALUES (1020, 'Order', 'Standard'),
			(1120, 'Reorder', 'Standard'),
            (1220, 'Refill', 'Standard'),
            (1320, 'Order', 'Rush'),
			(1420, 'Reorder', 'Rush'),
            (1520, 'Refill', 'Rush');
            
INSERT INTO DISTRIBUTION_CENTER
(Distribution_ID, Distribution_Description, Distribution_Address, Distribution_City, Distribution_State, Distribution_ZipCode, Facility_Distance, Facility_Duration, Facility_Rush_Duration)
	VALUES (4010, 'Distribution_A', '1550 Main St', 'Woburn', 'Massachusetts', '01801', 34, 7, 1),
			(4110, 'Distribution_B', '50 Grove St',	'Newton', 'Massachusetts', '01801',	28,	7, 1),
			(4210, 'Distribution_D', '1550 Main St', 'Woburn', 'Massachusetts', '01801', 34, 7, 1),
			(4310, 'Distribution_C', '2 Castle Ave', 'Peabody', 'Massachusetts', '01923', 16, 7, 1),
			(4410, 'Distribution_G', '49 Orne St', 'Malden', 'Massachusetts', '01981', 61, 7, 1),
			(4510, 'Distribution E', '2 Bringham Cr', 'Natick', 'Massachusetts', '01943', 68, 7, 1),
			(4610, 'Distribution F', '4 Arc street', 'Dorchester', 'Massachusetts', '01428', 30, 7, 1),
            (4710, 'Distribution_H', '50 Bummer Dr', 'Marlborough', 'Massachusetts', '01701', 84, 7, 1),
            (4810, 'Distribution_I', '21 Kendall Sq', 'Cambridge', 'Massachusetts', '01811', 90, 7, 1),
            (4910, 'Distribution_J', '80 Hillcrest Dr', 'Acton', 'Massachusetts', '01725', 4, 7, 1);
            
INSERT INTO DRUG
(Drug_ID, Drug_Description, Drug_Type, Shelf_Duration, Storage_Size)
	VALUES (900600, 'Drug A', 'pill', 365, 10),
			(900601, 'Drug B', 'liquid', 90, 20),
			(900602, 'Drug C', 'tablet', 365, 13),
			(900603, 'Drug D', 'cream', 365, 15),
			(900604, 'Drug E', 'pill', 365, 25),
			(900605, 'Drug F', 'liquid', 90, 40),
			(900606, 'Drug G', 'tablet', 365, 30),
			(900607, 'Drug H', 'cream', 365, 15),
            (900608, 'Drug I', 'pill', 365, 10),
			(900609, 'Drug J', 'powder', 180, 5),
			(900610, 'Drug K', 'liquid', 120, 20),
			(900611, 'Drug L', 'tablet', 150, 13),
			(900612, 'Drug M', 'cream', 270, 15),
			(900617, 'Drug N', 'pill', 270, 25),
			(900613, 'Drug O', 'liquid', 210, 40),
			(900614, 'Drug P', 'tablet', 210, 30),
			(900615, 'Drug Q', 'cream', 365, 15),
            (900916, 'Drug R', 'pill', 365, 10);            



            
INSERT INTO HEALTH_CENTER
(HC_ID, HC_Description, HC_Type, HC_Address, HC_City, HC_State, HC_ZipCode)
VALUES (300, 'Health Center A', 'Health center', '14 Commercial St' , 'Adams', 'MA', '01220'),
		(301, 'Hospital A', 'Hospital', '61 Park Dr', 'Boston', 'MA', '02215'),
		(302, 'Health Center B', 'Health center', '53 Hill Rd', 'Belmont', 'MA', '02478'),
		(303, 'Health Center C', 'Health center', '1 Longfellow St', 'Buzzards Bay', 'MA', '02532'),
		(304, 'Hospital B', 'Hospital', '183 Centre St', 'Dorchester', 'MA', '02124'),
		(305, 'Hospital C', 'Hospital', '1 Sayward St', 'Dorchester', 'MA', '02125'),
        (306, 'Health Center D', 'Health center', '10 Sherban Cir' , 'Wellseley', 'MA', '01225'),
		(307, 'Hospital D', 'Hospital', '6 Princess Dr', 'Newton', 'MA', '02415'),
		(308, 'Health Center E', 'Health center', '5 Gioconda ', 'Chestnut Hill', 'MA', '02458'),
		(309, 'Hospital E', 'Hospital', '1 Longfellow Brigde', 'Cambridge', 'MA', '02512'),
        (310, 'Health Center F', 'Health center', '14 Dummer Hill' , 'Adams', 'MA', '01220'),
		(311, 'Hospital G', 'Hospital', '21 Kenmore Sq', 'Boston', 'MA', '02215'),
		(312, 'Health Center J', 'Health center', '39 School St', 'Belmont', 'MA', '02478'),
		(313, 'Health Center K', 'Health center', '34 Andover St', 'Buzzards Bay', 'MA', '02532'),
		(314, 'Hospital L', 'Hospital', '19 Salem Dr', 'Dorchester', 'MA', '02124'),
		(315, 'Hospital M', 'Hospital', '5 Ballardvale Rd', 'Dorchester', 'MA', '02125'),
        (316, 'Health Center N', 'Health center', '70 Carriage Dr' , 'Wellseley', 'MA', '01225'),
		(317, 'Hospital O', 'Hospital', '17 Chadwick', 'Newton', 'MA', '02415'),
		(318, 'Health Center P', 'Health center', '284 Great Rd ', 'Chestnut Hill', 'MA', '02458'),
		(319, 'Hospital R', 'Hospital', '100 PowderMill Rd', 'Cambridge', 'MA', '02512');
            

INSERT INTO HEALTH_RECORDS
(HealthRecords_ID, Treatment_Description, PatientNumber, HC_ID, Dosage, Consumption_Duration, Visit_Date)
	VALUES (800, 'cold', 10090, 300, '0.5mg 3 times per day', 3, '2022-5-10'),
			(801, 'fever', 10091, 301, '0.8mg 2 times per day', 3, '2022-12-6'),
			(802, 'cough', 10092, 302, '1mg once per day', 5, '2022-3-3'),
			(803, 'Asthma',10093, 303, '10ml once per day', 7, '2022-7-5'),
			(804, 'Highbloodpressure', 10094, 304, '0.4mg once per day', 30, '2022-11-25'),
			(805, 'diarrhea', 10095, 305, '5ml 2 times per day', 5, '2022-5-26'),
            (806, 'Diabetes', 10096, 306, '0.5mg 3 times per day', 14, '2022-10-5'),
			(807, 'Pneumonia', 10097, 307, '0.8mg 2 times per day', 10, '2022-12-6'),
			(808, 'Hernia', 10098, 308, '1mg once per day', 15, '2022-7-7'),
			(809, 'Aneamia', 10099, 309, '10ml once per day', 30, '2022-09-06'), 
            (810, 'cold', 10100,  308, '0.5mg 3 times per day', 3, '2022-5-13'),
			(811, 'fever', 10101, 309, '0.8mg 2 times per day', 3, '2022-12-10'),
			(812, 'cough', 10102, 310, '1mg once per day', 5, '2022-3-9'),
			(813, 'Asthma', 10103, 311, '10ml once per day', 7, '2022-8-5'),
			(814, 'Pneumonia', 10104, 312, '0.8mg 2 times per day', 10, '2022-07-6'),
			(815, 'Hernia', 10105, 313, '1mg once per day', 15, '2022-02-7'),
			(816, 'Aneamia', 10106, 314, '10ml once per day', 30, '2022-01-06'),
            (817, 'cold', 10107, 315, '0.5mg 3 times per day', 3, '2022-5-15'),
			(818, 'fever', 10108, 316, '0.8mg 2 times per day', 3, '2022-12-6'),
            (819, 'cold', 10109, 317, '0.5mg 3 times per day', 3, '2022-5-10'),
			(820, 'cold', 10110, 318, '0.5mg 3 times per day', 3, '2022-5-10'),
			(821, 'diarrhea', 10111, 319, '5ml 2 times per day', 5, '2022-5-26'),
            (822, 'cough', 10112, 319, '1mg once per day', 5, '2022-3-3'),
            (823, 'fever',10113, 317, '0.8mg 2 times per day', 3, '2022-12-6');
            
            
INSERT INTO D_H_RELATIONSHIP
(D_H_Relationship_ID, Distribution_ID, HC_ID, Distance, Duration, RushDuration, Fee, Rush_Fee, Relationship_Start_Date, Relationship_End_Date)
	VALUES (8001, 4010, 300, 4, 6, 1, 2500, 3750, '2020-01-01', '2999-01-01'),
			(8002, 4110, 301, 4, 6, 1, 2500, 3750, '2019-01-01', '2999-12-31'),
			(8003, 4210, 302, 4, 6, 1, 2500, 3750, '2018-01-01', '2999-12-31'),
			(8004, 4310, 303, 4, 6, 1, 2500, 3750, '2000-01-01', '2999-12-31'),
			(8005, 4410, 304, 2.46, 6, 1, 2500, 3750, '1968-01-01', '2999-12-31'),
			(8006, 4510, 305, 4, 6, 1, 2500, 3750, '1970-01-01', '2999-12-31'),
			(8007, 4610, 306, 4, 6, 1, 2500, 3750, '2018-01-01', '2999-12-31'),
			(8008, 4710, 307, 6, 6, 1, 2500, 3750, '2006-01-01', '2999-12-31'),
			(8009, 4810, 308, 10, 6, 1, 2500, 3750, '1987-01-01', '2999-12-31'),
			(8010, 4910, 309, 8, 6, 1, 2500, 3750, '2022-01-01', '2999-12-31');
            

    
INSERT INTO BATCH
(Batch_ID, Drug_ID, Original_Quantity, Available_Quantity, Create_Date, Expiration_Date)
	VALUES (57010, 900600, 5500, 2467, '2021-01-05 13:23:44', '2023-01-05'),
			(57011, 900601, 5493, 3467, '2022-05-25 15:46:21', '2024-05-05'),
            (57012, 900602, 2947, 1267, '2021-09-30 19:42:24', '2022-12-17'),
            (57013, 900603, 7432, 4627, '2020-07-18 17:46:34', '2024-09-05'),
            (57014, 900604, 8463, 7248, '2019-03-01 17:42:12', '2023-02-19'),
            (57015, 900605, 3985, 2005, '2021-02-12 00:00:00', '2023-07-07'),
            (57016, 900606, 7945, 6498, '2021-11-05 21:45:11', '2022-11-14'),
            (57017, 900607, 8945, 8491, '2019-12-05 15:15:15', '2021-01-01'),
            (57018, 900608, 5980, 3289, '2020-08-12 22:22:22', '2023-06-05'),
            (57019, 900609, 7469, 7460, '2021-04-04 12:46:21', '2022-12-31'),
            (57020, 900610, 7593, 6539, '2021-01-05 18:46:21', '2023-01-05'),
			(57021, 900611, 8932, 6429, '2021-09-30 09:28:08', '2022-12-17'),
			(57022, 900612, 9538, 7493, '2019-03-01 14:47:02', '2023-02-19'),
			(57023, 900617, 5925, 4567, '2021-02-12 19:43:38', '2023-07-07'),
			(57024, 900613, 8888, 1369, '2019-12-05 18:46:29', '2021-01-01'),
			(57025, 900614, 6789, 4863, '2020-08-12 00:00:00', '2023-06-05'),
			(57026, 900615, 9753, 7777, '2021-09-30 15:42:01', '2022-12-17'),
            (57027, 900916, 1357, 375, '2021-09-30 12:44:21', '2022-12-17');

            
INSERT INTO `ORDER`
(Order_ID, Drug_ID, Batch_ID, Facility_ID, D_H_Relationship_ID, Order_Type_ID, Quantity, Used_Quantity, Cost, Size, Order_Date, Delivery_By_Date, DC_Delivery_Date, HC_Delivery_Date)
	VALUES (1610, 900600, 57010, 001, 8001, 1020, 2467, 1749, 4934.00, 50, '2021-08-05', '2021-08-22', '2021-08-30', '2021-09-05'),
			(1611, 900601, 57011, 001, 8002, 1120, 6427, 409, 11500.00, 18, '2021-07-01', '2021-07-10', '2021-07-15', '2021-07-21'),
            (1612, 900602, 57012, 001, 8003, 1220, 3000, 2345, 3980.00, 16, '2021-06-01', '2021-06-10', '2021-06-15', '2021-06-21'),
            (1613, 900603, 57013, 001, 8004, 1320, 5768, 1543, 8000.00, 9, '2021-05-05', '2021-05-08', '2021-05-13', '2021-05-15'),
            (1614, 900604, 57014, 001, 8005, 1420, 6007, 5790, 5700.00, 22, '2021-04-05', '2021-04-09', '2021-04-15', '2021-04-21'),
            (1615, 900605, 57015, 001, 8006, 1520, 4267, 2789, 9000.00, 15, '2021-07-05', '2021-07-11', '2021-07-13', '2021-07-17'),
            (1616, 900606, 57016, 001, 8007, 1020, 8001, 549, 4500.00, 20, '2021-06-05', '2021-06-07', '2021-06-09', '2021-06-10'),
            (1617, 900607, 57017, 001, 8008, 1120, 9010, 4872, 5000.00, 25, '2021-05-11', '2021-05-14', '2021-05-15', '2021-05-19'),
            (1618, 900608, 57018, 001, 8009, 1320, 7498, 1890, 7000.00, 30, '2021-04-07', '2021-04-12', '2021-04-15', '2021-04-18'),
            (1619, 900609, 57019, 001, 8010, 1320, 1278, 786, 9000.00, 40, '2021-08-01', '2021-08-03', '2021-08-07', '2021-08-09');
		

INSERT INTO PRESCRIPTION
(Prescription_ID, Drug_ID, HealthRecords_ID)
	VALUES (7200, 900600, 800),
			(7201, 900601, 801),
			(7202, 900601, 802),
			(7203, 900603, 803),
			(7204, 900602, 804),
			(7205, 900605, 805),
			(7206, 900603, 806),
			(7207, 900607, 807),
			(7208, 900604, 808),
			(7209, 900609, 809),
            (7210, 900605, 810),
            (7211, 900611, 811),
            (7212, 900612, 812),
            (7213, 900612, 813),
            (7214, 900614, 814),
            (7215, 900608, 815),
			(7216, 900607, 823);


            
 #Task B 
#1 - Track hospital inventory / drug capacity over time
select b.Drug_id, YEAR(b.Create_Date), sum(b.Available_Quantity)*d.Storage_Size as 'Drug Capacity'
from Batch b JOIN drug d 
on b.Drug_id = d.Drug_ID
group by b.Drug_id, YEAR(b.Create_Date);

#1.2 
Select
HC_Description,
HC_Delivery_Date,
Drug_Description,
sum(Original_Quantity) AS Total_Quantity,
sum(Available_Quantity) AS Total_Available,
sum(Quantity) as Hospital_Inventory
From
batch B,
`Order` O,
health_center HC,
d_h_relationship DH,
drug D
Where B.Batch_ID = O.Batch_ID
AND O.D_H_Relationship_ID = DH.D_H_Relationship_ID
AND DH.HC_ID = HC.HC_ID
AND O.Drug_ID = D.Drug_ID
Group by HC_Description,
HC_Delivery_Date,
Drug_Description
Order by HC_Delivery_Date;

#2 - Track treatments for patients 
SELECT PatientNumber as 'Patient Number', HC_ID , p.Drug_ID, d.Drug_Description, Dosage
from Health_Records hr, Prescription p, Drug d 
where
hr.HealthRecords_ID = p.HealthRecords_ID
AND p.Drug_ID = d.Drug_ID;


#3 - Track popularity of drugs
SELECT Year(Order_Date) as 'Year', Drug_ID as 'Most popular drug of the year', SUM((Used_Quantity)) as 'Quantity used' from
`ORDER`
group by Drug_ID 
order by SUM(Used_Quantity) desc limit 1;

#4 - Track over/under delivery of a drug/drugs
SELECT Drug_ID, sum(Quantity), sum(Used_Quantity),
case when sum(quantity)<sum(Used_Quantity) then 'Over Delivered'
when sum(quantity)>sum(Used_Quantity) then 'Under Delivered'
else 'Sufficiently Delivered'
END as 'Over/Under'
from `ORDER`
group by Drug_ID;

#5 - Track if drug order is new/refill/reorder/etc.
SELECT Order_ID, Drug_ID, Order_Type_Description as 'Drug order type', RushOrder
from `Order` o JOIN
Order_Type ot on 
o.order_type_id = ot.Order_Type_ID;

#6 - Track if drugs are delivered on time
SELECT Order_ID, 
CASE WHEN HC_delivery_date = Delivery_By_date THEN 'On time delivery'
WHEN HC_delivery_date > Delivery_By_date THEN 'Late delivery'
WHEN HC_delivery_date < Delivery_By_date THEN 'Early delivery'
END AS Delivery 
From `Order`;

#7 - Track shelf life of drugs
SELECT Drug.Drug_ID, datediff(Expiration_Date, Create_Date) as 'Shelf_Life in days'
from Drug JOIN Batch ON
Drug.Drug_ID = Batch.Drug_ID;


            
    
