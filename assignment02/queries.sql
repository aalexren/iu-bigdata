/*[4 point] Which are the user ids, venue ids, venu categories, local datetime 
 * of the check-ins in Russia (Country code RU)?*/
SELECT c.user_id, p.venue_id, p.category, c.utc_time + c.timezone_offset_mins as local_datetime
FROM checkins c LEFT JOIN pois p ON c.venue_id = p.venue_id
WHERE p.country = 'RU';


/*[4 point] What are the friend ids of users who checked in Russia and have 
 * friendship before April 2012?*/
SELECT COUNT(*) FROM friendship_before fb;

SELECT friends.user_id, friends.friend_id FROM
	(SELECT fb.user_id, fb.friend_id 
	FROM friendship_before fb
	UNION
	SELECT fb2.friend_id, fb2.user_id
	FROM friendship_before fb2) friends
ORDER BY friends.user_id, friends.friend_id;

SELECT friends.user_id, friends.friend_id FROM
	(SELECT fa.user_id, fa.friend_id
	FROM friendship_after fa
	UNION
	SELECT fa2.friend_id, fa2.user_id
	FROM friendship_after fa2) friends
ORDER BY friends.user_id, friends.friend_id;



SELECT DISTINCT fa.friend_id FROM
	(SELECT fa.user_id, fa.friend_id
	FROM friendship_after fa
	UNION
	SELECT fa2.friend_id, fa2.user_id
	FROM friendship_after fa2) fa
INNER JOIN
	(SELECT fb.user_id, fb.friend_id 
	FROM friendship_before fb
	UNION
	SELECT fb2.friend_id, fb2.user_id
	FROM friendship_before fb2) fb
ON fa.user_id = fb.user_id
LEFT JOIN checkins c ON fa.user_id = c.user_id
LEFT JOIN pois p ON c.venue_id = p.venue_id
WHERE p.country = 'RU'
ORDER BY fa.friend_id;


/*[5 point] For each user, What is the number of friends before April 2012 
 * and number of friends after Januray 2014? also return the change in number of friends.*/
SELECT u.user_id, u.fa, u.fb, u.fa - u.fb AS difference FROM (
	SELECT u.user_id, SUM(u.num_fb) AS fb, SUM(u.num_fa) AS fa FROM (	
		SELECT fb.user_id, fb.num_fb, fb.num_fa FROM (
			SELECT fb.user_id, COUNT(fb.user_id) AS num_fb, 0 AS num_fa
			FROM 
				(SELECT fb.user_id, fb.friend_id 
				FROM friendship_before fb
				UNION
				SELECT fb2.friend_id, fb2.user_id
				FROM friendship_before fb2
				) fb
			GROUP BY fb.user_id
		) AS fb
		UNION
		SELECT fa.user_id, fa.num_fb, fa.num_fa FROM (
			SELECT fa.user_id, 0 AS num_fb, COUNT(fa.user_id) AS num_fa
			FROM 
				(SELECT fa.user_id, fa.friend_id 
				FROM friendship_after fa
				UNION
				SELECT fa2.friend_id, fa2.user_id
				FROM friendship_after fa2
				) fa
			GROUP BY fa.user_id
		) AS fa
		ORDER BY user_id
	) AS u
	GROUP BY user_id
) AS u;


/*[5 point] Retrieve the categories of russian venus which are checked in by 
 * friends of first 10 users from your slice and have friendship before April 2012.*/
SELECT DISTINCT p.category FROM (
	SELECT fb.friend_id FROM (
		SELECT DISTINCT user_id FROM checkins c ORDER BY user_id ASC LIMIT 10 /* get first 10 users */
	) AS u
	RIGHT JOIN (
		SELECT fb.user_id, fb.friend_id 
		FROM friendship_before fb
		UNION
		SELECT fb2.friend_id, fb2.user_id
		FROM friendship_before fb2) fb ON fb.user_id = u.user_id 
	EXCEPT 
	SELECT u.user_id FROM (
		SELECT DISTINCT user_id FROM checkins c ORDER BY user_id ASC LIMIT 10 /* left only friends of users */
	) AS u
) AS u
LEFT JOIN checkins c ON u.friend_id = c.user_id /* get all checkins for friends */
LEFT JOIN pois p ON c.venue_id = p.venue_id
WHERE p.country = 'RU';


/*[7 points] Retrieve friends of friends of friends of the users who checked in 
 * Post Office and all have friendship with each other before April 2012.*/

/* user -> f1, user -> f2, user -> f3, f1 -> f2, f1 -> f3, f2 -> f3 => 6 checks */

SELECT /*u.user_id, u.f1_id, u.f2_id,*/ DISTINCT u.f3_id FROM (
	SELECT u.user_id, u.f1_id, u.f2_id, u.f3_id FROM (
		SELECT u.user_id, f1.friend_id AS f1_id, f2.friend_id AS f2_id, f3.friend_id AS f3_id FROM (
			SELECT DISTINCT users.user_id FROM
				(SELECT fb.user_id, fb.friend_id 
				FROM friendship_before fb
				UNION
				SELECT fb2.friend_id, fb2.user_id
				FROM friendship_before fb2) users
			LEFT JOIN checkins c ON c.user_id = users.user_id
			LEFT JOIN pois p ON c.venue_id = p.venue_id 
			WHERE p.category = 'Post Office'
		) AS u
		LEFT JOIN (
			SELECT fb.user_id, fb.friend_id 
			FROM friendship_before fb
			UNION
			SELECT fb2.friend_id, fb2.user_id
			FROM friendship_before fb2
		) AS f1 ON u.user_id = f1.user_id
		LEFT JOIN (
			SELECT fb.user_id, fb.friend_id 
			FROM friendship_before fb
			UNION
			SELECT fb2.friend_id, fb2.user_id
			FROM friendship_before fb2
		) AS f2 ON f1.friend_id = f2.user_id
		LEFT JOIN (
			SELECT fb.user_id, fb.friend_id 
			FROM friendship_before fb
			UNION
			SELECT fb2.friend_id, fb2.user_id
			FROM friendship_before fb2
		) AS f3 ON f2.friend_id = f3.user_id
		ORDER BY u.user_id ASC
	) AS u
	WHERE u.user_id != u.f1_id AND
			u.f1_id != u.f2_id AND
			u.f2_id != u.f3_id AND
			u.f3_id != u.f1_id AND
			u.user_id != u.f2_id AND
			u.user_id != u.f3_id
) AS u
CROSS JOIN (
		SELECT fb.user_id, fb.friend_id 
		FROM friendship_before fb
		UNION
		SELECT fb2.friend_id, fb2.user_id
		FROM friendship_before fb2
) AS f
CROSS JOIN (
		SELECT fb.user_id, fb.friend_id 
		FROM friendship_before fb
		UNION
		SELECT fb2.friend_id, fb2.user_id
		FROM friendship_before fb2
) AS f2
CROSS JOIN (
		SELECT fb.user_id, fb.friend_id 
		FROM friendship_before fb
		UNION
		SELECT fb2.friend_id, fb2.user_id
		FROM friendship_before fb2
) AS f3
WHERE 
	u.user_id = f.user_id AND u.f2_id = f.friend_id AND
	u.user_id = f2.user_id AND u.f3_id = f2.friend_id AND
	u.f1_id = f3.user_id AND u.f3_id = f3.friend_id;

