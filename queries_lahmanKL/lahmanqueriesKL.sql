-- For reference, from Mark.

-- select t.table_schema,
--        t.table_name
-- from information_schema.tables t
-- inner join information_schema.columns c on c.table_name = t.table_name
--                                 and c.table_schema = t.table_schema
-- where c.column_name ilike= '%name%'
--       and t.table_schema not in ('information_schema', 'pg_catalog')
--       and t.table_type = 'BASE TABLE'
-- order by t.table_schema;



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

SELECT CONCAT(p.namefirst, ' ', namelast) as name, 
		height, 
		p.playerid, 
		a.teamid, 
		t.name, 
		SUM(g_all) total_games
FROM people AS p
	INNER JOIN appearances AS a
	ON p.playerid = a.playerid
		INNER JOIN teams AS t
		ON a.teamid = t.teamid
GROUP BY height, namefirst, namelast, a.teamid, p.playerid, t.name
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



/* Q6. Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. 
	(A stolen base attempt results either in a stolen base or being caught stealing.) 
	Consider only players who attempted at least 20 stolen bases. */

SELECT *
FROM people

SELECT *
FROM batting

SELECT count(SB)
from batting
WHERE SB = 0


-- Thoughts... total attempts should be Caught Stealing (CS) + Stolen Bases (SB) from the batting table, and that needs to be against stolen bases.

SELECT namefirst, namelast, b.playerid, 
	(SELECT SB FROM batting WHERE SB > 0) AS SBclean,
	(SBclean/(CS + SBclean))*100 AS perc_attempts
FROM batting AS b
INNER JOIN people AS p
ON b.playerid = p.playerid
WHERE yearid = 2016
	AND SB >= 20
ORDER BY  DESC

SELECT namefirst, namelast, b.playerid, 
	ROUND(CAST(SB AS numeric)/(CAST(CS AS numeric) + CAST(SB AS numeric)), 2) AS perc_attempts
FROM batting AS b
INNER JOIN people AS p
ON b.playerid = p.playerid
WHERE yearid = 2016
	AND SB >= 20
GROUP BY SB, CS, namefirst, namelast, b.playerid
ORDER BY perc_attempts DESC

SELECT CONCAT(namefirst, ' ', namelast) as player, 
	to_char((CAST(SB AS numeric)/(CAST(CS AS numeric) + CAST(SB AS numeric)))*100, '99.99%') AS perc_attempts
FROM batting AS b
INNER JOIN people AS p
ON b.playerid = p.playerid
WHERE yearid = 2016
	AND SB >= 20
GROUP BY SB, CS, player
ORDER BY perc_attempts DESC

-- A. Chris Owings with a 91.30% success rate of stealing bases in 2016.



-----------------------------------------------------------------------------------------



/* Q7. From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
	What is the smallest number of wins for a team that did win the world series? 
	Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
	Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
	What percentage of the time? */
	
-- Thoughts... Group by year, use teams table, selct the Wins (W) and world series win (wswin) which is 'Y' or 'N'

SELECT *
FROM teams


SELECT *
FROM teams
WHERE yearid BETWEEN '1970' AND '2016'
	AND wswin = 'N'


SELECT name, max(w), yearid
FROM teams
WHERE yearid BETWEEN '1970' AND '2016'
	AND wswin = 'N'
GROUP BY name, yearid
ORDER BY max


SELECT *
FROM teams
WHERE yearid BETWEEN '1970' AND '2016'
	AND wswin = 'Y'


SELECT name, min(w), yearid
FROM teams
WHERE yearid BETWEEN '1970' AND '2016'
	AND wswin = 'Y'
GROUP BY name, yearid
ORDER BY min

-- Apparently there was a strike in 1981 and all the regular season games were cancelled.
-- Max that did not win WS was the Blue Jays with 37 wins. Min who did win WS was the Dodgers with 63 wins


SELECT name, w, yearid
FROM teams
WHERE yearid >= '1970' AND yearid <= '1980' AND yearid >= '1982' AND yearid <= '2016'
	AND wswin = 'N'
GROUP BY name, w, yearid
ORDER BY yearid




-- Below is what UrLeaka just posted and I am no where near this. It honestly meakes me nervous for the accessment coming up because I'm not even close...............

WITH winners as	(	SELECT teamid as champ, 
				           yearid, w as champ_w
	  				FROM teams
	  				WHERE 	(wswin = 'Y')
				 			AND (yearid BETWEEN 1970 AND 2016) ),
max_wins as (	SELECT yearid, 
			           max(w) as maxw
	  			FROM teams
	  			WHERE yearid BETWEEN 1970 AND 2016
				GROUP BY yearid)
SELECT 	COUNT(*) AS all_years,
		COUNT(CASE WHEN champ_w = maxw THEN 'Yes' end) as max_wins_by_champ,
		to_char((COUNT(CASE WHEN champ_w = maxw THEN 'Yes' end)/(COUNT(*))::real)*100,'99.99%') as Percent
FROM 	winners LEFT JOIN max_wins
		USING(yearid)

--------------------------------------------------------------------------------------------



/* Q8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 
	(where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. 
	Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance. */


-- Thoughts... obvs use the homegames table. I'll need to join to the teams table to get the team name and the park name since homegames only has their ids.

SELECT *
FROM homegames

SELECT *
FROM teams

SELECT *
FROM homegames
WHERE year = 2016

--Highest
SELECT t.park, t.name, (h.attendance/h.games) as avg_attend
FROM homegames as h
INNER JOIN teams as t
ON h.team = t.teamid AND h.year = t.yearid
WHERE h.year = '2016'
	AND h.games >= 10
GROUP BY t.park, t.name, avg_attend
ORDER BY avg_attend DESC
LIMIT 5

--Lowest
SELECT t.park, t.name, (h.attendance/h.games) as avg_attend
FROM homegames as h
INNER JOIN teams as t
ON h.team = t.teamid AND h.year = t.yearid
WHERE h.year = '2016'
	AND h.games >= 10
GROUP BY t.park, t.name, avg_attend
ORDER BY avg_attend
LIMIT 5

-- From Mark below. Very interesting. I just don't think that the whole 'no park listed' thing is needed, at least for 2016.

SELECT t.teamid,
   	      t.name,
		  COALESCE(t.park,'No park listed') as parkname,
		  CASE WHEN SUM(h.games) <=0 THEN 0
		  ELSE CAST(SUM(h.attendance/h.games) as float)		 
		  END as average_attendance
   FROM homegames h
   LEFT JOIN teams t
   ON h.team = t.teamid and h.year = t.yearid
   WHERE h.games >= 10
   AND h.year = '2016'
   GROUP BY t.teamid,
   	        t.name,
		    t.park
   ORDER BY 4 DESC
   LIMIT 5;



----------------------------------------------------------------------------------------------



/* Q9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
	Give their full name and the teams that they were managing when they won the award. */

-- Thoughts... I'll need to join awardsmanagers and people tables. 

SELECT *
FROM awardsmanagers as a
-- SELECT lgid and need to join to people using playerid

SELECT * 
FROM managers

SELECT *
FROM people as p 
-- SELECT namefirst, namelast, and need to join to awardsmanagers using playerid

SELECT *
FROM teams as t
-- SELECT name, join to people


--My query but using Mark's temp tables
SELECT DISTINCT p.playerid,
		p.namefirst,
		p.namelast,
		t.name as team,
		al.lgid as league
	FROM ALData as al
		INNER JOIN people as p 
		ON al.playerid = p.playerid
		LEFT JOIN managers m
			ON p.playerid = m.playerid
				AND al.yearid = m.yearid
				AND al.lgid = m.lgid
			INNER JOIN teams as t
			ON al.yearid = t.yearid
		WHERE p.playerid IN (
						SELECT playerid
						FROM ALData
						INTERSECT
						SELECT playerid
						FROM NLData
						)
	
UNION

SELECT DISTINCT p.playerid,
		p.namefirst,
		p.namelast,
		t.name as team,
		nl.lgid as league
	FROM NLData as nl
		INNER JOIN people as p 
		ON nl.playerid = p.playerid
		LEFT JOIN managers m
			ON p.playerid = m.playerid
				AND nl.yearid = m.yearid
				AND nl.lgid = m.lgid
			INNER JOIN teams as t
			ON nl.yearid = t.yearid
		WHERE p.playerid IN (
						SELECT playerid
						FROM ALData
						INTERSECT
						SELECT playerid
						FROM NLData
						) 
	ORDER BY 

--Mark's code below

-- AL league award winners
SELECT playerid, awardid, yearid,lgid
into temp table ALData
FROM public.awardsmanagers
WHERE lgid = 'AL' AND awardid = 'TSN Manager of the Year'

-- NL league award winners
SELECT playerid, awardid, yearid,lgid
into temp table NLData
FROM public.awardsmanagers
WHERE lgid = 'NL' AND awardid = 'TSN Manager of the Year'
--    "leylaji99"
--    "johnsda02"
-- drop table ALData
-- DROP table NLData
 -- final data --
	SELECT DISTINCT p.playerid,
			CONCAT(p.namelast, ', ', p.namefirst) as ManagerName,
			al.yearid,
			al.lgid,
			m.teamid,
			t.name
	 FROM ALData al 	
		INNER JOIN people p
			ON al.playerid = p.playerid
		LEFT JOIN managers m
			ON p.playerid = m.playerid
				AND al.yearid = m.yearid
				AND al.lgid = m.lgid
		INNER JOIN  teams t
			ON m.teamid = t.teamid
	WHERE p.playerid IN (
						SELECT playerid
						FROM ALData
						INTERSECT
						SELECT playerid
						FROM NLData
						)
UNION
	
	SELECT DISTINCT p.playerid,
			CONCAT(p.namelast, ', ', p.namefirst) as ManagerName,
			nl.yearid,
			nl.lgid,
			m.teamid,
			t.name
	 FROM NLData nl
	INNER JOIN people p
			ON nl.playerid = p.playerid
		LEFT JOIN managers m
			ON p.playerid = m.playerid
				AND nl.yearid = m.yearid
				AND nl.lgid = m.lgid
		INNER JOIN  teams t
			ON m.teamid = t.teamid
				AND m.lgid = t.lgid
				AND m.yearid = t.yearid
	WHERE p.playerid IN (
						SELECT playerid
						FROM ALData
						INTERSECT
						SELECT playerid
						FROM NLData
						)
	 ORDER BY managername, yearid ASC

-- A. Honestly, I can't get this one to work without stealing Mark's code. I don't know what to do.


---------------------------------------------------------------------------------------------------


/* Presentation ideas
	Something about the very first year in baseball
	Something about when women played, apparently they weren't major league and so therefore not included in this after some research.
	Something about the guy who made the least rather than the most from Vandy in 2016
	Or ranking all the players.
*/

SELECT *
FROM teams
WHERE yearid BETWEEN '1943' AND '1955'

SELECT *
FROM people
WHERE debut > '1943-01-01'
ORDER BY debut

SELECT DISTINCT lgid
FROM teams

SELECT *
FROM collegeplaying
ORDER BY yearid

SELECT COUNT(DISTINCT playerid)
FROM collegeplaying
-- 6575

SELECT COUNT(DISTINCT playerid)
FROM people
-- 19112

-- 19112-6575=12537

SELECT DISTINCT p.playerid
FROM collegeplaying AS c
RIGHT JOIN people AS p
ON p.playerid = c.playerid
ORDER BY yearid

---------------


-- I think I'm gonna use this. I really don't know what else to do at this point!!! Need to see how many years each one played
SELECT p.namefirst, p.namelast, cp.schoolid, SUM(s.salary) AS total_salary
FROM people AS p
	INNER JOIN collegeplaying as cp
	ON p.playerid = cp.playerid
		INNER JOIN salaries as s
		ON cp.playerid = s.playerid
GROUP BY p.namefirst, p.namelast, cp.schoolid
ORDER BY total_salary DESC