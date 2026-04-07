CREATE TABLE staging_tdf (
  day DATE,
  stage INTEGER,
  bib INTEGER,
  rank INTEGER,
  time INTEGER,
  bonus INTEGER,
  penalty INTEGER,
  start_location VARCHAR(64),
  start_country_code CHAR(3),
  start_country_name VARCHAR(64),
  start_region VARCHAR(64),
  finish_location VARCHAR(64),
  finish_country_code CHAR(3),
  finish_country_name VARCHAR(64),
  finish_region VARCHAR(64),
  length INTEGER,
  type VARCHAR(32),
  rider VARCHAR(64),
  team VARCHAR(64),
  dob DATE,
  rider_country_code CHAR(3),
  rider_country_name VARCHAR(64),
  rider_region VARCHAR(64),
  team_country_code CHAR(3),
  team_country_name VARCHAR(64),
  team_region VARCHAR(64)
);

SELECT COUNT(*) FROM staging_tdf;

-- Load countries
INSERT INTO countries (code, name, region)
SELECT start_country_code, start_country_name, start_region 
FROM staging_tdf
WHERE start_country_code IS NOT NULL AND BTRIM(start_country_code) <> ''

UNION

SELECT finish_country_code, finish_country_name, finish_region 
FROM staging_tdf
WHERE finish_country_code IS NOT NULL AND BTRIM(finish_country_code) <> ''

UNION

SELECT rider_country_code, rider_country_name, rider_region 
FROM staging_tdf
WHERE rider_country_code IS NOT NULL AND BTRIM(rider_country_code) <> ''

UNION

SELECT team_country_code, team_country_name, team_region 
FROM staging_tdf
WHERE team_country_code IS NOT NULL AND BTRIM(team_country_code) <> '';

-- Load Teams
INSERT INTO teams (name, country)
SELECT DISTINCT team, team_country_code
FROM staging_tdf
WHERE team IS NOT NULL
  AND BTRIM(team) <> ''
  AND team_country_code IS NOT NULL
  AND BTRIM(team_country_code) <> '';

-- Load Riders
INSERT INTO riders (bib, name, dob, team)
SELECT DISTINCT bib, rider, dob, team
FROM staging_tdf
WHERE bib IS NOT NULL
  AND rider IS NOT NULL
  AND BTRIM(rider) <> ''
  AND dob IS NOT NULL
  AND team IS NOT NULL
  AND BTRIM(team) <> '';

-- Load Locations
INSERT INTO locations (name, country)
SELECT start_location, start_country_code
FROM staging_tdf
WHERE start_location IS NOT NULL
  AND BTRIM(start_location) <> ''
  AND start_country_code IS NOT NULL
  AND BTRIM(start_country_code) <> ''

UNION

SELECT finish_location, finish_country_code
FROM staging_tdf
WHERE finish_location IS NOT NULL
  AND BTRIM(finish_location) <> ''
  AND finish_country_code IS NOT NULL
  AND BTRIM(finish_country_code) <> '';


-- Load Stages
INSERT INTO stages (num, day, start, finish, length, type)
SELECT DISTINCT stage, day, start_location, finish_location, length, type
FROM staging_tdf
WHERE stage IS NOT NULL
  AND day IS NOT NULL
  AND start_location IS NOT NULL
  AND BTRIM(start_location) <> ''
  AND finish_location IS NOT NULL
  AND BTRIM(finish_location) <> ''
  AND length IS NOT NULL
  AND type IS NOT NULL
  AND BTRIM(type) <> '';

-- Load riders_from
INSERT INTO riders_from (rider, country)
SELECT DISTINCT bib, rider_country_code
FROM staging_tdf
WHERE bib IS NOT NULL
  AND rider_country_code IS NOT NULL
  AND BTRIM(rider_country_code) <> '';

-- Load results
-- ATTENTION: one rider has the same rank as another, that's why I use DISTINCT ON
INSERT INTO results (rider, stage, rank, time, bonus, penalty)
SELECT DISTINCT ON (stage, rank)
  bib, stage, rank, time, bonus, penalty
FROM staging_tdf
WHERE bib IS NOT NULL
  AND stage IS NOT NULL
  AND rank IS NOT NULL
  AND time IS NOT NULL
  AND bonus IS NOT NULL
  AND penalty IS NOT NULL
ORDER BY stage, rank, time, bib;


  