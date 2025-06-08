
-- Q 1. List the names of all pet owners along with the names of their pets.
SELECT 
    o.name AS 'Owner name', p.name AS 'Pet name'
FROM
    petowners o
        LEFT JOIN
    pets p ON o.ownerid = p.ownerid;

-- Q 2. List all pets and their owner names, including pets that don't have recorded owners.

SELECT 
    p.name AS 'Pet name', o.name AS 'Owner name'
FROM
    pets p
        LEFT JOIN
    petowners o ON p.ownerid = o.ownerid;
   
-- Q 3. Combine the information of pets and their owners, including those pets without owners and owners without pets.

SELECT 
    p.name AS 'Pet name', o.name AS 'Owner name'
FROM
    pets p
        LEFT JOIN
    petowners o ON p.ownerid = o.ownerid 
UNION SELECT 
    p.name AS 'Pet name', o.name AS 'Owner name'
FROM
    pets p
        RIGHT JOIN
    petowners o ON p.ownerid = o.ownerid
WHERE
    p.ownerid IS NULL;


-- Q 4. Find the names of pets along with their owners' names and the details of the procedures they have undergone.

SELECT 
    p.name AS 'Pet Name',
    o.name AS 'Owner Name',
    ph.proceduretype AS 'Procedure Type',
    pd.price AS 'Procedure Price'
FROM
    pets p
        JOIN
    petowners o ON p.ownerid = o.ownerid
        JOIN
    procedurehistory ph ON p.petid = ph.petid
        JOIN
    proceduredetails pd ON ph.ProcedureSubCode = pd.ProcedureSubCode;


-- Q 5. List all pet owners and the number of dogs they own. 

with dogcount
as
(
select o.name as 'Ownername', p.kind as 'CountofDogs'
from petowners o
left join
pets p on o.ownerid = p.ownerid
where p.kind = 'Dog'
)
select ownername, count(countofdogs) as 'Number of Dogs' from dogcount
group by ownername order by ownername;



-- Q 6. Identify pets that have not had any procedures.

SELECT 
    p.name AS 'Pet name',
    ph.proceduretype AS 'Undergone Procedure'
FROM
    pets p
        LEFT JOIN
    procedurehistory ph ON p.petid = ph.petid
WHERE
    ph.petid IS NULL;



-- Q 7. Find the name of the oldest pet. 

with oldpet
as
(
select name, kind, gender, age, dense_rank() over(order by age desc) as `Rank` from pets)
select name, kind, gender, age from oldpet where `Rank` = 1;

-- Q 8. List all pets who had procedures that cost more than the average cost of all procedures. 
SELECT 
    p.name AS 'Pet Name',
    ph.proceduretype AS 'Procedure Type',
    pd.price AS 'Procedure Price'
FROM
    pets p
        JOIN
    procedurehistory ph ON p.petid = ph.petid
        JOIN
    proceduredetails pd ON ph.ProcedureSubCode = pd.ProcedureSubCode
WHERE
    pd.price > (SELECT 
            AVG(price)
        FROM
            proceduredetails);


-- Q 9. Find the details of procedures performed on pet 'Cuddles'.

SELECT 
    p.name AS 'Pet name',
    ph.proceduretype AS 'Procedure Performed'
FROM
    pets p
        JOIN
    procedurehistory ph ON p.petid = ph.petid
WHERE
    name = 'Cuddles';


-- Q 10.Create a list of pet owners along with the total cost they have spent on
-- procedures and display only those who have spent above the average spending. 

WITH MoreThanAvg AS (
    SELECT
        o.name AS 'Owner name',
        p.name AS 'Pet name',
        ph.proceduretype AS 'Procedure type',
        pd.price AS 'Price'
    FROM
        petowners o
    LEFT JOIN
        pets p ON o.ownerid = p.ownerid
    JOIN
        procedurehistory ph ON p.petid = ph.petid
    JOIN
        proceduredetails pd ON ph.ProcedureSubCode = pd.ProcedureSubCode
)
SELECT
    `Owner name`,
    SUM(Price) AS 'Total Spending'
FROM
    MoreThanAvg
GROUP BY
    `Owner name`
HAVING
    SUM(Price) > (SELECT AVG(Price) FROM MoreThanAvg);

-- Q 11.List the pets who have undergone a procedure called 'VACCINATIONS'. 

SELECT 
    p.name AS 'Pet Name', ph.proceduretype AS 'Procedure Type'
FROM
    pets p
        JOIN
    procedurehistory ph ON p.petid = ph.petid
WHERE
    ph.proceduretype = 'VACCINATIONS';


-- Q 12.Find the owners of pets who have had a procedure called 'EMERGENCY'.
SELECT 
    o.name AS 'Owner Name',
    p.name AS 'Pet Name',
    ph.proceduretype AS 'Procedure Type'
FROM
    petowners o
        JOIN
    pets p ON o.ownerid = p.ownerid
        JOIN
    procedurehistory ph ON p.petid = ph.petid
WHERE
    ph.proceduretype = 'EMERGENCY';

-- Q 13.Calculate the total cost spent by each pet owner on procedures.
SELECT 
    o.name AS 'Owner Name', SUM(pd.price) AS 'Total Cost'
FROM
    petowners o
        JOIN
    pets p ON o.ownerid = p.ownerid
        JOIN
    procedurehistory ph ON p.petid = ph.petid
        JOIN
    proceduredetails pd ON ph.ProcedureSubCode = pd.ProcedureSubCode
GROUP BY o.ownerid , o.name;

-- Q 14.Count the number of pets of each kind.
SELECT 
    kind AS 'Pet Kind', COUNT(*) AS 'Number of Pets'
FROM
    pets
GROUP BY kind;

-- 15.Group pets by their kind and gender and count the number of pets in each group.
SELECT 
    kind AS 'Pet Kind',
    gender AS 'Pet Gender',
    COUNT(*) AS 'Number of Pets'
FROM
    pets
GROUP BY kind , gender;


-- Q 16.Show the average age of pets for each kind, but only for kinds that have more than 5 pets.
SELECT 
    kind AS 'Pet Kind', ROUND(AVG(age), 2) AS 'Average Age'
FROM
    pets
GROUP BY kind
HAVING COUNT(*) > 5;

-- Q 17.Find the types of procedures that have an average cost greater than $50.
SELECT 
    proceduretype AS 'Procedure Type',
    AVG(price) AS 'Average Cost'
FROM
    proceduredetails
GROUP BY proceduretype
HAVING AVG(price) > 50;

-- Q 18.Classify pets as 'Young', 'Adult', or 'Senior' based on their age. Age less then 3 Young, Age between 3and 8 Adult, else Senior.

SELECT 
    name AS 'Pet Name',
    age AS 'Pet Age',
    CASE
        WHEN age < 3 THEN 'Young'
        WHEN age BETWEEN 3 AND 8 THEN 'Adult'
        ELSE 'Senior'
    END AS 'Age Category'
FROM
    pets;

/* Q 19.Calculate the total spending of each pet owner on procedures, labeling them
-- as 'Low Spender' for spending under $100, 'Moderate Spender' for spending
between $100 and $500, and 'High Spender' for spending over $500.*/

SELECT 
    o.name AS 'Owner Name',
    SUM(pd.price) AS 'Total Spending',
    CASE
        WHEN SUM(pd.price) < 100 THEN 'Low Spender'
        WHEN SUM(pd.price) BETWEEN 100 AND 500 THEN 'Moderate Spender'
        ELSE 'High Spender'
    END AS 'Spending Category'
FROM
    petowners o
        JOIN
    pets p ON o.ownerid = p.ownerid
        JOIN
    procedurehistory ph ON p.petid = ph.petid
        JOIN
    proceduredetails pd ON ph.ProcedureSubCode = pd.ProcedureSubCode
GROUP BY o.ownerid , o.name;

-- Q 20.Show the gender of pets with a custom label ('Boy' for male, 'Girl' for female).
SELECT 
    name AS 'Pet Name',
    gender AS 'Gender',
    CASE
        WHEN gender = 'Male' THEN 'Boy'
        WHEN gender = 'Female' THEN 'Girl'
        ELSE 'Unknown'
    END AS 'Custom Gender Label'
FROM
    pets;

/*21.For each pet, display the pet's name, the number of procedures they've had,
and a status label: 'Regular' for pets with 1 to 3 procedures, 'Frequent' for 4 to
7 procedures, and 'Super User' for more than 7 procedures.*/

SELECT 
    p.name AS 'Pet Name',
    COUNT(ph.petid) AS 'Number of Procedures',
    CASE
        WHEN COUNT(ph.petid) BETWEEN 1 AND 3 THEN 'Regular'
        WHEN COUNT(ph.petid) BETWEEN 4 AND 7 THEN 'Frequent'
        ELSE 'Super User'
    END AS 'Status Label'
FROM
    pets p
        LEFT JOIN
    procedurehistory ph ON p.petid = ph.petid
GROUP BY p.petid , p.name;

-- Q 22.Rank pets by age within each kind.
SELECT
    name AS 'Pet Name',
    kind AS 'Pet Kind',
    age AS 'Pet Age',
    RANK() OVER (PARTITION BY kind ORDER BY age) AS 'Age Rank Within Kind'
FROM
    pets;

-- Q 23.Assign a dense rank to pets based on their age, regardless of kind.
SELECT
    name AS 'Pet Name',
    kind AS 'Pet Kind',
    age AS 'Pet Age',
    DENSE_RANK() OVER (ORDER BY age) AS 'Age Dense Rank'
FROM
    pets;

-- Q 24.For each pet, show the name of the next and previous pet in alphabetical order.
SELECT
    name AS 'Pet Name',
    LEAD(name) OVER (ORDER BY name) AS 'Next Pet',
    LAG(name) OVER (ORDER BY name) AS 'Previous Pet'
FROM
    pets;

-- Q 25.Show the average age of pets, partitioned by their kind.
SELECT
    name AS 'Pet Name',
    kind AS 'Pet Kind',
    age AS 'Pet Age',
    AVG(age) OVER (PARTITION BY kind) AS 'Average Age for Kind'
FROM
    pets;

-- Q 26.Create a CTE that lists all pets, then select pets older than 5 years from the CTE.
WITH AllPets AS (
    SELECT
        name AS 'Pet Name',
        kind AS 'Pet Kind',
        age AS 'Pet Age'
    FROM
        pets
)

SELECT *
FROM AllPets
WHERE `Pet age` > 5;


