-- 1. What range of years does the provided database cover?

SELECT MIN(yearid), MAX(yearid)
FROM collegeplaying

SELECT MIN(yearid), MAX(yearid)
FROM batting

-- A. 1864-2014 (in collegeplaying), 1871-2016 (the website says 2019 for batting, but the data dictionary says 2016)

-----------------------------------------------------------------

-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT *
FROM people 

SELECT *
FROM teams

SELECT *
FROM appearances

SELECT height, namefirst, namelast, p.playerid, a.teamid, a.yearid, t.name, SUM(g_all)
FROM people AS p
	INNER JOIN appearances AS a
	ON p.playerid = a.playerid
		INNER JOIN teams AS t
		ON a.teamid = t.teamid
GROUP BY a.yearid, height, namefirst, namelast, a.teamid, p.playerid, t.name
ORDER BY height

-- A. Eddie Gaedel, 43 (I'm guessing inches), 52 games, St. Louis Browns

--------------------------------------------------------------------

SELECT *
FROM collegeplaying
WHERE schoolid = 'vandy'

-- collegeplaying and schools = schoolid

SELECT *
FROM schools

-- didn't end up needing this one ^^

SELECT *
FROM people 

-- people and collegeplaying = playerid

SELECT *
FROM salaries 

-- salaries has playerid

SELECT p.namefirst, p.namelast, cp.schoolid, SUM(s.salary) AS total_salary
FROM people AS p
	INNER JOIN collegeplaying as cp
	ON p.playerid = cp.playerid
		INNER JOIN salaries as s
		ON cp.playerid = s.playerid
WHERE cp.schoolid = 'vandy'
GROUP BY p.namefirst, p.namelast, cp.schoolid
ORDER BY total_salary DESC

-- A. David Price with $245,553,888

--------------------------------------------------------------------

/* 4. Using the fielding table, group players into three groups based on their position: 
label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.*/

SELECT *
FROM fielding


SELECT playerid, 
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' THEN 'Infield'
		WHEN pos = '1B' THEN 'Infield'
		WHEN pos = '2B' THEN 'Infield'
		WHEN pos = '3B' THEN 'Infield'
		WHEN pos = 'P' THEN 'Battery'
		WHEN pos = 'C' THEN 'Battery' END
FROM fielding

