SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 255
SET PAGESIZE 999

---*Question1*---
COLUMN Employee_Name FORMAT A20
COLUMN Instructor FORMAT A20
COLUMN "List of Class" FORMAT A100
SELECT  e.Fname || ',' || e.Lname AS Employee_Name, i.Fname || ',' || i.Lname AS Instructor,
		LISTAGG(Crs_ID || '-' || Crs_Title || '-' ||  Sem_Cmpltd ,', ')AS "List of Class"
FROM EMPLOYEE e JOIN TRAINING USING (Emp_ID)
				JOIN CLASS USING (Crs_ID, Section, Sem_Cmpltd)
				JOIN COURSE USING (Crs_ID)
				JOIN INSTRUCTOR i USING (Instr_ID)
GROUP BY e.Fname || ',' || e.Lname,  i.Fname || ',' || i.Lname
HAVING COUNT(DISTINCT(Crs_ID || '-' || Crs_Title || '-' ||  Sem_Cmpltd))>1
ORDER BY Employee_Name,Instructor;

---*Question2*---
--"RANK"
COLUMN Sem_Cmpltd FORMAT A20
SELECT Sem_Cmpltd
FROM(SELECT DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT (Crs_ID || Section || Sem_Cmpltd)) DESC) AS RANK, 
			Sem_Cmpltd, COUNT(DISTINCT (Crs_ID || Section || Sem_Cmpltd)) AS Class_Count
		FROM TRAINING
		GROUP BY Sem_Cmpltd)
WHERE RANK <= 1;

--"Without RANK,Rownum, and FETCH Functiton"
SELECT Sem_Cmpltd
FROM TRAINING
GROUP BY Sem_Cmpltd
HAVING COUNT(DISTINCT (Crs_ID || Section || Sem_Cmpltd)) 
			= (SELECT MAX(COUNT(DISTINCT (Crs_ID || Section || Sem_Cmpltd))) AS Class_Count
				FROM TRAINING
				GROUP BY Sem_Cmpltd);
 
---*Question3*---
COLUMN Sem_Cmpltd FORMAT A20
COLUMN Sem_Cmpltd FORMAT A20
SELECT Sem_Cmpltd, Crs_ID || ',' || Section || ',' || Sem_Cmpltd AS Class_ID, Crs_Title, COUNT(Emp_ID) AS Emp_Count
FROM TRAINING JOIN CLASS USING (Crs_ID, Section, Sem_Cmpltd)
				JOIN COURSE USING (Crs_ID)
GROUP BY Sem_Cmpltd, Crs_ID || ',' || Section || ',' || Sem_Cmpltd, Crs_Title
ORDER BY regexp_replace(Sem_Cmpltd, '[^0-9]+', ''),
         regexp_replace(Sem_Cmpltd, '[^a-zA-Z]+', '')DESC;

---*Question4*---
COLUMN "Employee" FORMAT 'A25'
COLUMN "Total for 2019-2021:" FORMAT '999999999999'
SELECT "Employee","2019","2020","2021","2019" + "2020" + "2021" AS "Total for 2019-2021:" 
FROM(SELECT Emp_ID || ':' || FNAME || ' ' || LNAME AS "Employee", 
		TO_CHAR(regexp_replace(TRIM(Sem_Cmpltd), '[^0-9]+', ''), '9999') AS "YEAR" 
FROM TRAINING JOIN EMPLOYEE USING (Emp_ID)
WHERE regexp_replace(TRIM(Sem_Cmpltd), '[^0-9]+', '') IN (2019,2020,2021))
PIVOT (COUNT("YEAR") FOR "YEAR" IN (' 2019' AS "2019",' 2020' AS "2020",' 2021' AS "2021"))
UNION
SELECT 'Year Total : ',"2019","2020","2021","2019" + "2020" + "2021" AS "Total for 2019-2021:" 
FROM(SELECT TO_CHAR(regexp_replace(TRIM(Sem_Cmpltd), '[^0-9]+', ''), '9999') AS "YEAR"  
FROM TRAINING JOIN EMPLOYEE USING (Emp_ID)
WHERE regexp_replace(TRIM(Sem_Cmpltd), '[^0-9]+', '') IN (2019,2020,2021))
PIVOT (COUNT("YEAR") FOR "YEAR" IN (' 2019' AS "2019",' 2020' AS "2020",' 2021' AS "2021"))
ORDER BY "Employee";

---*Question5*---
COLUMN Crs_ID FORMAT A20
SELECT Crs_ID,Crs_Title, COUNT(DISTINCT Emp_ID) AS Emp_Count,
 		     RANK() OVER (ORDER BY COUNT(DISTINCT Emp_ID) DESC) AS RANK
FROM COURSE LEFT JOIN CLASS USING (Crs_ID)
			LEFT JOIN TRAINING USING (Crs_ID, Section, Sem_Cmpltd)
GROUP BY Crs_ID,Crs_Title;

---*Question6*---
COLUMN "YEAR" FORMAT 'A20'
SELECT "YEAR",TO_CHAR(Tuition_Year, '$99999999,990') AS "Total_Tuition", 
		TO_CHAR(AVG(Tuition_Year) OVER(ORDER BY "YEAR" ROWS BETWEEN 1 PRECEDING
				AND 1 FOLLOWING),'$999,990') "MA(3)"
FROM(SELECT regexp_replace(Sem_Cmpltd, '[^0-9]+', '') AS "YEAR", SUM(Tuition) AS Tuition_Year
FROM TRAINING JOIN COURSE USING (Crs_ID)
GROUP BY regexp_replace(Sem_Cmpltd, '[^0-9]+', '')
ORDER BY "YEAR");

---*Question7*---
COLUMN Total_Spent FORMAT $999,990								
SELECT Emp_ID,Class_Count,Total_Spent
FROM(SELECT RANK() OVER (ORDER BY SUM(Allowance) DESC) AS RANK,
			Emp_ID, COUNT(Crs_ID) AS Class_Count, SUM(Tuition) AS Total_Spent
FROM TRAINING JOIN COURSE USING (Crs_ID)
				JOIN EMPLOYEE USING (Emp_ID)
GROUP BY Emp_ID)
WHERE RANK <= 2;
