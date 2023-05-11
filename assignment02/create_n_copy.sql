CREATE TABLE IF NOT EXISTS pois(
	venue_id VARCHAR(24) PRIMARY KEY,
	latitude REAL,
	longitude REAL,
	category VARCHAR(50),
	country VARCHAR(2)
);

CREATE TABLE IF NOT EXISTS friendship_before(
	user_id INTEGER,
	friend_id INTEGER
);

CREATE TABLE IF NOT EXISTS friendship_after(
	user_id INTEGER,
	friend_id INTEGER
);

CREATE TABLE IF NOT EXISTS checkins(
	user_id INTEGER,
	venue_id VARCHAR(24),
	utc_time TIMESTAMP,
	timezone_offset_mins INTERVAL MINUTE,
	
	FOREIGN KEY (venue_id) REFERENCES pois(venue_id)
);


/*\COPY pois(venue_id, latitude, longitude, category, country) FROM 'my_POIs.tsv' DELIMITER E'\t' CSV HEADER;*/
/*\COPY checkins(user_id, venue_id, utc_time, timezone_offset_mins) FROM 'my_checkins_anonymized.tsv' DELIMITER E'\t' CSV HEADER;*/
/*\COPY friendship_after(user_id, friend_id) FROM 'my_friendship_after.tsv' DELIMITER E'\t' CSV HEADER;*/
/*\COPY friendship_before(user_id, friend_id) FROM 'my_friendship_before.tsv' DELIMITER E'\t' CSV HEADER;*/

SELECT * FROM checkins LIMIT 10;
SELECT * FROM pois LIMIT 10;
SELECT * FROM friendship_after;
SELECT * FROM friendship_before;