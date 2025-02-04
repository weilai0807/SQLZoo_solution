/* 1. There are three issues that include the words "index" and "Oracle". Find the call_date for each of them 

+---------------------+----------+
| call_date           | call_ref |
+---------------------+----------+
| 2017-08-12 16:00:00 |     1308 |
| 2017-08-16 14:54:00 |     1697 |
| 2017-08-16 19:12:00 |     1731 |
+---------------------+----------+ */

SELECT DATE_FORMAT(call_date,'%Y-%m-%d %H:%i:%s') call_date, call_ref 
  FROM Issue
WHERE Detail LIKE '%index%' 
  AND DETAIL LIKE '%Oracle%';


/* 2. Samantha Hall made three calls on 2017-08-14. Show the date and time for each

+---------------------+------------+-----------+
| call_date           | first_name | last_name |
+---------------------+------------+-----------+
| 2017-08-14 10:10:00 | Samantha   | Hall      |
| 2017-08-14 10:49:00 | Samantha   | Hall      |
| 2017-08-14 18:18:00 | Samantha   | Hall      |
+---------------------+------------+-----------+ */

SELECT DATE_FORMAT(call_date,'%Y-%m-%d %H:%i:%s') call_date, first_name, last_name
  FROM Issue JOIN Caller ON Issue.Caller_id = Caller.Caller_id
WHERE First_name='Samantha' 
  AND Last_name='Hall' 
  AND Date(call_date) = '2017-08-14'

  
/* 3. There are 500 calls in the system (roughly). Write a query that shows the number that have each status.

+--------+--------+
| status | Volume |
+--------+--------+
| Closed |    486 |
| Open   |     10 |
+--------+--------+ */

SELECT status, Count(*) volume
  FROM Issue
GROUP BY status
ORDER BY volume DESC


/* 4. Calls are not normally assigned to a manager but it does happen. How many calls have been assigned to staff who are at Manager Level?

+------+
| mlcc |
+------+
|   51 |
+------+ */

SELECT COUNT(*) mlcc
  FROM Issue JOIN Staff ON Assigned_to = Staff_code
  JOIN Level ON Staff.Level_code = Level.Level_code
WHERE Manager = 'Y'


/* 5. Show the manager for each shift. Your output should include the shift date and type; also the first and last name of the manager.

+------------+------------+------------+-----------+
| Shift_date | Shift_type | first_name | last_name |
+------------+------------+------------+-----------+
| 2017-08-12 | Early      | Logan      | Butler    |
| 2017-08-12 | Late       | Ava        | Ellis     |
| 2017-08-13 | Early      | Ava        | Ellis     |
| 2017-08-13 | Late       | Ava        | Ellis     |
| 2017-08-14 | Early      | Logan      | Butler    |
| 2017-08-14 | Late       | Logan      | Butler    |
| 2017-08-15 | Early      | Logan      | Butler    |
| 2017-08-15 | Late       | Logan      | Butler    |
| 2017-08-16 | Early      | Logan      | Butler    |
| 2017-08-16 | Late       | Logan      | Butler    |
+------------+------------+------------+-----------+ */

SELECT DATE_FORMAT(Shift_date, '%Y-%m-%d') Shift_date, Shift_type, first_name, last_name
  FROM Shift JOIN Staff ON Manager = Staff_code
WHERE Level_code > 3
ORDER BY Shift_date, Shift_type;

/* 6. List the Company name and the number of calls for those companies with more than 18 calls.

+------------------+----+
| Company_name     | cc |
+------------------+----+
| Gimmick Inc.     | 22 |
| Hamming Services | 19 |
| High and Co.     | 20 |
+------------------+----+ */

SELECT Customer.Company_name, COUNT(*) AS cc
  FROM Customer JOIN Caller ON Customer.Company_ref=Caller.Company_ref
  JOIN Issue ON Caller.Caller_id=Issue.Caller_id
GROUP BY Company_name
Having cc > 18


/* 7. Find the callers who have never made a call. Show first name and last name

+------------+-----------+
| first_name | last_name |
+------------+-----------+
| David      | Jackson   |
| Ethan      | Phillips  |
+------------+-----------+ */

SELECT First_name, Last_name
  FROM Caller LEFT JOIN Issue ON Caller.Caller_id = Issue.Caller_id
WHERE Issue.Caller_id IS Null

  
/* 8. For each customer show: Company name, contact name, number of calls where the number of calls is fewer than 5

+--------------------+------------+-----------+----+
| Company_name       | first_name | last_name | nc |
+--------------------+------------+-----------+----+
| Pitiable Shipping  | Ethan      | McConnell |  4 |
| Rajab Group        | Emily      | Cooper    |  4 |
| Somebody Logistics | Ethan      | Phillips  |  2 |
+--------------------+------------+-----------+----+ */

SELECT cu.company_name,ca2.first_name,ca2.last_name,COUNT(*) AS nc
  FROM Customer cu INNER JOIN Caller ca ON ca.company_ref = cu.company_ref 
  INNER JOIN Issue i ON i.caller_id = ca.caller_id
  INNER JOIN Caller ca2 ON ca2.caller_id = cu.contact_id
GROUP BY cu.company_name,ca2.first_name,ca2.last_name
HAVING nc < 5


/* 9. For each shift show the number of staff assigned. 
Beware that some roles may be NULL and that the same person might have been assigned to multiple roles (The roles are 'Manager', 'Operator', 'Engineer1', 'Engineer2').

+------------+------------+----+
| Shift_date | Shift_type | cw |
+------------+------------+----+
| 2017-08-12 | Early      |  4 |
| 2017-08-12 | Late       |  4 |
| 2017-08-13 | Early      |  3 |
| 2017-08-13 | Late       |  2 |
| 2017-08-14 | Early      |  4 |
| 2017-08-14 | Late       |  4 |
| 2017-08-15 | Early      |  4 |
| 2017-08-15 | Late       |  4 |
| 2017-08-16 | Early      |  4 |
| 2017-08-16 | Late       |  4 |
+------------+------------+----+ */

SELECT DATE_FORMAT(a.Shift_date, '%Y-%m-%d') as Shift_date, a.Shift_type, COUNT(DISTINCT role) AS cw
  FROM (
        SELECT Shift_date, Shift_type, Manager AS role FROM Shift
      UNION ALL
        SELECT Shift_date, Shift_type, Operator AS role FROM Shift
      UNION ALL
        SELECT Shift_date, Shift_type, Engineer1 AS role FROM Shift
      UNION ALL SELECT Shift_date, Shift_type, Engineer2 AS role FROM Shift
  ) AS a
GROUP BY Shift_date, Shift_type


/* 10. Caller 'Harry' claims that the operator who took his most recent call was abusive and insulting. Find out who took the call (full name) and when. 
 
+------------+-----------+---------------------+
| first_name | last_name | call_date           |
+------------+-----------+---------------------+
| Emily      | Best      | 2017-08-16 10:25:00 |
+------------+-----------+---------------------+ */

SELECT Staff.First_name, Staff.Last_name, DATE_FORMAT(Issue.call_date, '%Y-%m-%d %H:%i:%s') as call_date
  FROM Staff JOIN Issue ON Staff.Staff_code = Issue.Taken_by
  JOIN Caller ON Issue.Caller_id = Caller.Caller_id
WHERE Caller.First_name = 'Harry'
ORDER BY call_date DESC
LIMIT 1;


/* 11. Show the manager and number of calls received for each hour of the day on 2017-08-12

+---------+---------------+----+
| Manager | Hr            | cc |
+---------+---------------+----+
| LB1     | 2017-08-12 08 |  6 |
| LB1     | 2017-08-12 09 | 16 |
| LB1     | 2017-08-12 10 | 11 |
| LB1     | 2017-08-12 11 |  6 |
| LB1     | 2017-08-12 12 |  8 |
| LB1     | 2017-08-12 13 |  4 |
| AE1     | 2017-08-12 14 | 12 |
| AE1     | 2017-08-12 15 |  8 |
| AE1     | 2017-08-12 16 |  8 |
| AE1     | 2017-08-12 17 |  7 |
| AE1     | 2017-08-12 19 |  5 |
+---------+---------------+----+ */

WITH temp1 AS (SELECT 
  DATE_FORMAT(Call_date, '%Y-%m-%d %H') AS day_hr,
  DATE_FORMAT(Call_date, '%Y-%m-%d') AS date1,
  DATE_FORMAT(Call_date, '%H') AS hr,
  COUNT(*) AS cc
FROM Issue
  WHERE DATE_FORMAT(Call_date, '%Y-%m-%d') = '2017-08-12'
  GROUP BY day_hr), 
temp2 AS (SELECT 
  Manager, 
  DATE_FORMAT(Shift_date, '%Y-%m-%d') AS date2, 
  LEFT(Start_time,2) AS morning,
  LEFT(End_time,2) AS night
FROM Shift s JOIN Shift_type st ON s.Shift_type = st.Shift_type
  WHERE DATE_FORMAT(s.Shift_date, '%Y-%m-%d') = '2017-08-12')
SELECT Manager, day_hr Hr, cc
FROM temp1 JOIN temp2 ON (temp1.hr >= temp2.morning AND temp1.hr < temp2.night)
ORDER BY Hr


/* 12. 80/20 rule. It is said that 80% of the calls are generated by 20% of the callers. Is this true? What percentage of calls are generated by the most active 20% of callers.

Note - Andrew has not managed to do this in one query - but he believes it is possible.

+---------+
| t20pc   |
+---------+
| 32.2581 |
+---------+ */

SET @counter := 0;

SELECT ROUND(SUM(p2.cc)/(SELECT COUNT(*) FROM Issue)*100, 4) AS t20pc
  FROM (SELECT p1.*, @counter := @counter + 1 counter
    FROM(SELECT Caller_id, COUNT(*) as cc 
      FROM Issue
      GROUP BY Caller_id
      ORDER BY cc DESC) AS p1
  ) AS p2
WHERE counter <= (0.2 * @counter)

  
/* 13. Annoying customers. Customers who call in the last five minutes of a shift are annoying. Find the most active customer who has never been annoying.

+--------------+------+
| Company_name | abna |
+--------------+------+
| High and Co. |   20 | 
+--------------+------+ */
SELECT 
  Company_name, 
  COUNT(*) AS abna
FROM Customer cus 
  JOIN Caller cal ON cus.Company_ref = cal.Company_ref
  JOIN Issue ON cal.Caller_id = Issue.Caller_id
WHERE Company_name NOT IN
  (SELECT DISTINCT Company_name
  FROM Customer cus 
    JOIN Caller cal ON cus.Company_ref = cal.Company_ref
    JOIN Issue ON cal.Caller_id = Issue.Caller_id
  WHERE HOUR(Call_date) IN (13, 19) AND MINUTE(Call_date) >= 55
  )
GROUP BY Company_name
ORDER BY abna DESC
LIMIT 1;


/* 14. Maximal usage. If every caller registered with a customer makes at least one call in one day then that customer has "maximal usage" of the service. List the maximal customers for 2017-08-13.

+-------------------+--------------+--------------------+
| company_name      | caller_count | registered_callers |
+-------------------+--------------+--------------------+
| Askew Inc.        |            2 |                  2 |
| Bai Services      |            2 |                  2 |
| Dasher Services   |            3 |                  3 |
| High and Co.      |            5 |                  5 |
| Lady Retail       |            4 |                  4 |
| Packman Shipping  |            3 |                  3 |
| Pitiable Shipping |            2 |                  2 |
| Whale Shipping    |            2 |                  2 |
+-------------------+--------------+--------------------+ */

WITH temp1 AS (SELECT 
  Company_name, 
  COUNT(Caller_id) caller_count
FROM Customer cus 
  JOIN Caller cal ON cus.Company_ref = cal.Company_ref
GROUP BY Company_name
), temp2 AS (SELECT 
  Company_name, 
  COUNT(DISTINCT(Issue.Caller_id)) registered_callers
FROM Customer cus 
  JOIN Caller cal ON cus.Company_ref = cal.Company_ref
  JOIN Issue ON cal.Caller_id = Issue.Caller_id
WHERE DATE_FORMAT(Call_date, '%Y-%m-%d') = '2017-08-13'
GROUP BY Company_name
)
SELECT temp1.Company_name, caller_count, registered_callers
FROM temp1 JOIN temp2 ON temp1.Company_name = temp2.Company_name
WHERE caller_count = registered_callers;


/* 15. Consecutive calls occur when an operator deals with two callers within 10 minutes. Find the longest sequence of consecutive calls – give the name of the operator and the first and last call date in the sequence.

+----------+---------------------+---------------------+-------+
| taken_by | first_call          | last_call           | calls |
+----------+---------------------+---------------------+-------+
| AB1      | 2017-08-14 09:06:00 | 2017-08-14 10:17:00 |    24 |
+----------+---------------------+---------------------+-------+ */

WITH temp1 AS (SELECT 
  taken_by,
  DATE_FORMAT(call_date, '%Y-%m-%d %H:%i:%s') AS last_call,
  @row_number := (CASE WHEN 
    (TIMESTAMPDIFF(MINUTE, @call_date, call_date) <= 10) THEN (@row_number + 1)
    ELSE 1 END) calls,
  @first_call_date := (CASE WHEN
    (@row_number = 1) THEN call_date 
    ELSE @first_call_date END) AS first_call,
  @call_date := Issue.call_date AS call_date
FROM Issue, (SELECT @row_number := 0, @first_call_date := 0, @call_date := 0) row_number_init
ORDER BY taken_by, call_date
)
SELECT taken_by, first_call, last_call, calls
FROM temp1
ORDER BY calls DESC
LIMIT 1
