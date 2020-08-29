---------------------------------------------------------------------------------

-- Q1. What range of years does the provided database cover?

SELECT MIN(yearid), MAX(yearid)
FROM collegeplaying

SELECT MIN(yearid), MAX(yearid)
FROM batting

-- A. 1864-2014 (in collegeplaying), 1871-2016 (the website says 2019 for batting, but the data dictionary says 2016)

---------------------------------------------------------------------------------

-- Q2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

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

----------------------------------------------------------------------------------

/* Q3. Find all players in the database who played at Vanderbilt University. Create a list showing each 
	player’s first and last names as well as the total salary they earned in the major leagues. 
	Sort this list in descending order by the total salary earned. 
	Which Vanderbilt player earned the most money in the majors? */

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

-------------------------------------------------------------------------------------

/* Q4. Using the fielding table, group players into three groups based on their position: 
	label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
	Determine the number of putouts made by each of these three groups in 2016.*/

SELECT *
FROM fielding


SELECT SUM(PO) AS putouts,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos = 'SS' THEN 'Infield'
		WHEN pos = '1B' THEN 'Infield'
		WHEN pos = '2B' THEN 'Infield'
		WHEN pos = '3B' THEN 'Infield'
		WHEN pos = 'P' THEN 'Battery'
		WHEN pos = 'C' THEN 'Battery' END AS position
FROM fielding
WHERE yearid = '2016'
GROUP BY position


-- A. Battery = 41,424, Infield = 58,934, Outfield = 29,560

-----------------------------------------------------------------------------------------


 /* Q5. Find the average number of strikeouts per game by decade since 1920. 
	Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends? */
	
-- From what I can see, I need to use the 'so' from Teams and only for batting. Except that I have to do this by game not team... hmm...
-- Teams also has games played, so could I use that with strikeouts from teams to figure it out?

SELECT *
FROM teams


-- Strike Outs below
SELECT ROUND(AVG(SO/G), 2)  as so_pergame,
	CASE WHEN yearid >= 1920 AND yearid <= 1929 THEN '1920s'
		WHEN yearid >= 1930 AND  yearid <= 1939 THEN '1930s'
		WHEN yearid >= 1940 AND  yearid <= 1949 THEN '1940s'
		WHEN yearid >= 1950 AND yearid <= 1959 THEN '1950s'
		WHEN yearid >= 1960 AND yearid <= 1969 THEN '1960s'
		WHEN yearid >= 1970 AND yearid <= 1979 THEN '1970s'
		WHEN yearid >= 1980 AND yearid <= 1989 THEN '1980s'
		WHEN yearid >= 1990 AND yearid <= 1999 THEN '1990s'
		WHEN yearid >= 2000 AND yearid <= 2009 THEN '2000s'
		WHEN yearid >= 2010 AND yearid <= 2019 THEN '2010s' END AS decade
FROM teams
GROUP BY decade
ORDER BY decade

-- Home runs below
SELECT ROUND(AVG(HR), 2),
	CASE WHEN yearid >= 1920 AND yearid <= 1929 THEN '1920s'
		WHEN yearid >= 1930 AND  yearid <= 1939 THEN '1930s'
		WHEN yearid >= 1940 AND  yearid <= 1949 THEN '1940s'
		WHEN yearid >= 1950 AND yearid <= 1959 THEN '1950s'
		WHEN yearid >= 1960 AND yearid <= 1969 THEN '1960s'
		WHEN yearid >= 1970 AND yearid <= 1979 THEN '1970s'
		WHEN yearid >= 1980 AND yearid <= 1989 THEN '1980s'
		WHEN yearid >= 1990 AND yearid <= 1999 THEN '1990s'
		WHEN yearid >= 2000 AND yearid <= 2009 THEN '2000s'
		WHEN yearid >= 2010 AND yearid <= 2019 THEN '2010s' END AS decade
FROM teams
GROUP BY decade
ORDER BY decade

-- A. It certainly looks like on both accounts, the trend is going way up. Meaning more people are being struck out, but more people are hitting far.

------------------------------------------------------------------------------------

/* Q6. Find the player who had the most success stealing bases in 2016, where success is measured 
	as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) 
	Consider only players who attempted at least 20 stolen bases. */

SELECT *
FROM people

SELECT *
FROM batting

-- Thoughts... total attempts should be caught stealing (CS) + Stolen Bases (SB) from the batting table. 