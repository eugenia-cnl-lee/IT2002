--
-- Group Number: 4
-- Group Members:
--   1. Yunus Emre Erkan
--   2. Lee Chun Nga
--   3. 
--   4. 
--

INSERT INTO countries (code, name, region) VALUES ('FRA', 'France', 'Europe');
INSERT INTO countries (code, name, region) VALUES ('GBR', 'Great Britain', 'Europe');

INSERT INTO teams (name, country) VALUES ('Team Alpha', 'FRA');
INSERT INTO teams (name, country) VALUES ('Team Beta', 'GBR');

INSERT INTO riders (bib, name, dob, team) VALUES (1, 'Rider A', '1990-01-01', 'Team Alpha');
INSERT INTO riders (bib, name, dob, team) VALUES (2, 'Rider B', '1991-02-02', 'Team Alpha');
INSERT INTO riders (bib, name, dob, team) VALUES (3, 'Rider C', '1992-03-03', 'Team Beta');
INSERT INTO riders (bib, name, dob, team) VALUES (4, 'Rider D', '1993-04-04', 'Team Beta');
INSERT INTO riders (bib, name, dob, team) VALUES (5, 'Rider E', '1994-05-05', 'Team Alpha');

INSERT INTO locations (name, country) VALUES ('Paris', 'FRA');
INSERT INTO locations (name, country) VALUES ('Lyon', 'FRA');
INSERT INTO locations (name, country) VALUES ('Marseille', 'FRA');
INSERT INTO locations (name, country) VALUES ('Toulouse', 'FRA');
INSERT INTO locations (name, country) VALUES ('Nice', 'FRA');
INSERT INTO locations (name, country) VALUES ('Bordeaux', 'FRA');
INSERT INTO locations (name, country) VALUES ('Lille', 'FRA');
INSERT INTO locations (name, country) VALUES ('Strasbourg', 'FRA');
INSERT INTO locations (name, country) VALUES ('Nantes', 'FRA');
INSERT INTO locations (name, country) VALUES ('Rennes', 'FRA');
INSERT INTO locations (name, country) VALUES ('Dijon', 'FRA');

INSERT INTO stages (num, day, start, finish, length, type) VALUES (1, '2025-07-05', 'Paris', 'Lyon', 200, 'flat');
INSERT INTO stages (num, day, start, finish, length, type) VALUES (2, '2025-07-06', 'Lyon', 'Marseille', 180, 'hilly');
INSERT INTO stages (num, day, start, finish, length, type) VALUES (3, '2025-07-07', 'Marseille', 'Toulouse', 220, 'mountain');
INSERT INTO stages (num, day, start, finish, length, type) VALUES (4, '2025-07-08', 'Toulouse', 'Nice', 190, 'flat');
INSERT INTO stages (num, day, start, finish, length, type) VALUES (5, '2025-07-09', 'Nice', 'Bordeaux', 210, 'hilly');
INSERT INTO stages (num, day, start, finish, length, type) VALUES (6, '2025-07-10', 'Bordeaux', 'Lille', 160, 'flat');
INSERT INTO stages (num, day, start, finish, length, type) VALUES (7, '2025-07-11', 'Lille', 'Strasbourg', 170, 'flat');



-- Test 1.1: consecutive ranks for stage 1
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 1.1: Consecutive ranks for stage 1 (should ACCEPT)';
  INSERT INTO results (rider, stage, rank, time) VALUES (1, 1, 1, 3600);
  INSERT INTO results (rider, stage, rank, time) VALUES (2, 1, 2, 3610);
  INSERT INTO results (rider, stage, rank, time) VALUES (3, 1, 3, 3620);
  INSERT INTO results (rider, stage, rank, time) VALUES (4, 1, 4, 3630);
  INSERT INTO results (rider, stage, rank, time) VALUES (5, 1, 5, 3640);
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 1.1: PASSED (accepted)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 1.1: FAILED (unexpected rejection: %)', SQLERRM;
END;
$$;


-- Test 1.2: Ranks with gap for stage 2
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 1.2: Ranks with gap for stage 2 (should REJECT)';
  INSERT INTO results (rider, stage, rank, time) VALUES (1, 2, 1, 3600);
  INSERT INTO results (rider, stage, rank, time) VALUES (2, 2, 3, 3620);
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 1.2: FAILED (should have been rejected)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 1.2: PASSED (correctly rejected: %)', SQLERRM;
END;
$$;


-- Test 2.1: equal times allowed for different ranks
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 2.1: Equal times with consecutive ranks (should ACCEPT)';
  INSERT INTO results (rider, stage, rank, time) VALUES (1, 3, 1, 3600);
  INSERT INTO results (rider, stage, rank, time) VALUES (2, 3, 2, 3600);
  INSERT INTO results (rider, stage, rank, time) VALUES (3, 3, 3, 3620);
  INSERT INTO results (rider, stage, rank, time) VALUES (4, 3, 4, 3630);
  INSERT INTO results (rider, stage, rank, time) VALUES (5, 3, 5, 3640);
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 2.1: PASSED (accepted)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 2.1: FAILED (unexpected rejection: %)', SQLERRM;
END;
$$;


-- Test 2.2: rank 1 has worse time than rank 2
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 2.2: Rank 1 worse time than rank 2 (should REJECT)';
  INSERT INTO results (rider, stage, rank, time) VALUES (1, 4, 1, 5000);
  INSERT INTO results (rider, stage, rank, time) VALUES (2, 4, 2, 3600);
  INSERT INTO results (rider, stage, rank, time) VALUES (3, 4, 3, 3620);
  INSERT INTO results (rider, stage, rank, time) VALUES (4, 4, 4, 3630);
  INSERT INTO results (rider, stage, rank, time) VALUES (5, 4, 5, 3640);
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 2.2: FAILED (should have been rejected)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 2.2: PASSED (correctly rejected: %)', SQLERRM;
END;
$$;


-- Test 3.1: rider 5 exits at stage 6
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 3.1: Rider 5 exits at stage 6 (should ACCEPT)';
  INSERT INTO riders_exits (rider, stage, reason) VALUES (5, 6, 'withdrawal');
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 3.1: PASSED (accepted)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 3.1: FAILED (unexpected rejection: %)', SQLERRM;
END;
$$;


-- Test 3.2: result for exited rider at exit stage
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 3.2: Result for rider 5 at exit stage 6 (should REJECT)';
  INSERT INTO results (rider, stage, rank, time) VALUES (1, 6, 1, 3600);
  INSERT INTO results (rider, stage, rank, time) VALUES (2, 6, 2, 3610);
  INSERT INTO results (rider, stage, rank, time) VALUES (3, 6, 3, 3620);
  INSERT INTO results (rider, stage, rank, time) VALUES (5, 6, 4, 3630);
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 3.2: FAILED (should have been rejected)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 3.2: PASSED (correctly rejected: %)', SQLERRM;
END;
$$;


-- Test 4.1: move stage 7 to july 12
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 4.1: 1 rest day (should ACCEPT)';
  UPDATE stages SET day = '2025-07-12' WHERE num = 7;
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 4.1: PASSED (accepted)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 4.1: FAILED (unexpected rejection: %)', SQLERRM;
END;
$$;


-- Test 4.2: move stage 7 to july 13
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 4.2: Consecutive rest days (should REJECT)';
  UPDATE stages SET day = '2025-07-13' WHERE num = 7;
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 4.2: FAILED (should have been rejected)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 4.2: PASSED (correctly rejected: %)', SQLERRM;
END;
$$;
-- State unchanged: July 5,6,7,8,9,10,12


-- Test 5.1: add stage 8 on july 14
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 5.1: 2 non consecutive rest days (should ACCEPT)';
  INSERT INTO stages (num, day, start, finish, length, type)
  VALUES (8, '2025-07-14', 'Strasbourg', 'Nantes', 200, 'mountain');
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 5.1: PASSED (accepted)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 5.1: FAILED (unexpected rejection: %)', SQLERRM;
END;
$$;


-- Test 5.2: add stage on july 17
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 5.2: Too many rest days (should REJECT)';
  INSERT INTO stages (num, day, start, finish, length, type)
  VALUES (9, '2025-07-17', 'Nantes', 'Rennes', 150, 'flat');
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 5.2: FAILED (should have been rejected)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 5.2: PASSED (correctly rejected: %)', SQLERRM;
END;
$$;


-- Test 6.1: UPDATE causes rank gap
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 6.1: UPDATE causes rank gap (should REJECT)';

  INSERT INTO results (rider, stage, rank, time) VALUES (1, 7, 1, 3600);
  INSERT INTO results (rider, stage, rank, time) VALUES (2, 7, 2, 3610);
  INSERT INTO results (rider, stage, rank, time) VALUES (3, 7, 3, 3620);

  -- move rank 2 to stage 6 where rank 4 is free, leaving a gap in stage 7
  INSERT INTO results (rider, stage, rank, time) VALUES (4, 6, 1, 3500);
  INSERT INTO results (rider, stage, rank, time) VALUES (5, 6, 2, 3510);
  INSERT INTO results (rider, stage, rank, time) VALUES (3, 6, 3, 3520);

  UPDATE results
  SET stage = 6, rank = 4
  WHERE stage = 7 AND rank = 2;

  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 6.1: FAILED (should have been rejected)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 6.1: PASSED (correctly rejected: %)', SQLERRM;
END;
$$;


-- Test 6.2: UPDATE breaks rank-time consistency
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 6.2: UPDATE breaks rank-time consistency (should REJECT)';

  INSERT INTO results (rider, stage, rank, time) VALUES (1, 5, 1, 3600);
  INSERT INTO results (rider, stage, rank, time) VALUES (2, 5, 2, 3610);

  UPDATE results
  SET time = 5000
  WHERE stage = 5 AND rank = 1;

  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 6.2: FAILED (should have been rejected)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 6.2: PASSED (correctly rejected: %)', SQLERRM;
END;
$$;


-- Test 6.3: UPDATE valid stage move
DO $$
BEGIN
  SET CONSTRAINTS ALL DEFERRED;
  RAISE NOTICE 'Test 6.3: UPDATE valid stage move (should ACCEPT)';

  INSERT INTO results (rider, stage, rank, time) VALUES (1, 6, 1, 3600);
  INSERT INTO results (rider, stage, rank, time) VALUES (2, 6, 2, 3610);
  INSERT INTO results (rider, stage, rank, time) VALUES (3, 7, 1, 3600);

  UPDATE results
  SET stage = 7, rank = 2
  WHERE stage = 6 AND rank = 2;

  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE NOTICE 'Test 6.3: PASSED (accepted)';
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Test 6.3: FAILED (unexpected rejection: %)', SQLERRM;
END;
$$;