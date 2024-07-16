/* MSIS618, Project Deliverable 3 - Database BONUS TASK*/
/* Group 4 */
/****************** ITEM 4: BONUS TASK - 1 ******************/

Use DrugSecure;

 #procedure 1 
DROP PROCEDURE IF EXISTS `Expired`
DELIMITER //
CREATE PROCEDURE `Expired`(IN DT varchar(45))
BEGIN
select d.Drug_ID, Drug_Description, b.Batch_ID,  
CASE WHEN datediff(b.expiration_Date, CURRENT_TIMESTAMP) > 0 THEN 'NOT Expired'
ELSE 'Expired'
END AS 'Exp/Not'
from Drug d, `Order` o, Batch b
where o.Drug_ID = d.Drug_ID AND b.Batch_ID = o.Batch_ID;
END
//
CALL Expired('pill');

#procedure 2
DROP PROCEDURE IF EXISTS `PatientRecord`
DELIMITER //
CREATE PROCEDURE `PatientRecord`(IN  PN int)
BEGIN
Select Prescription_ID, Visit_Date, Treatment_Description, p.Drug_ID, Drug_Description, Dosage
from Health_Records hr, Prescription p, Drug d
where 
hr.HealthRecords_ID = p.HealthRecords_ID
AND p.Drug_ID = d.Drug_ID
AND PatientNumber = PN;
END
//
CALL PatientRecord(10091);

#procedure 3 
DROP PROCEDURE IF EXISTS `HC Business`
DELIMITER //
CREATE PROCEDURE `HC Business`(IN hcd varchar(45))
BEGIN
select hc.HC_ID, HC_Type, Relationship_Start_Date, count(Order_ID) as 'Number of Orders', Cost as 'Revenue'
from `Order` o, D_H_Relationship d, Health_Center hc 
where 
o.D_H_Relationship_ID = d.D_H_Relationship_ID
AND d.HC_ID = hc.HC_ID
AND hc.HC_Description = hcd
group by hc.HC_ID;
END
//
CALL `HC Business`('Hospital A');

/****************** ITEM 5: BONUS TASK - 2 ******************/
#Grant permission for Hyon
CREATE USER 'Hyon1'@'localhost'
IDENTIFIED BY '1001'
PASSWORD EXPIRE NEVER; 
GRANT SELECT ON DrugSecure.Drug
TO 'Hyon1'@'localhost';

#Grant permission for Rhoda
CREATE USER 'Rhoda1'@'localhost'
IDENTIFIED BY '1002'
PASSWORD EXPIRE NEVER; 
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP ON DrugSecure.`Order`
TO 'Rhoda1'@'localhost';

#Creating a view to block privileges to them 
CREATE VIEW PatientRecords AS
SELECT PatientNumber, Treatment_Description, Dosage
From Health_Records
where PatientNumber = 10090;

CREATE USER 'Sanjna1'@'localhost'
IDENTIFIED BY '1003'
PASSWORD EXPIRE NEVER; 
GRANT SELECT ON DrugSecure.PatientRecords
TO 'Sanjna1'@'localhost';

REVOKE ALL ON DrugSecure.PatientRecords
FROM 'Sanjna1'@'localhost';