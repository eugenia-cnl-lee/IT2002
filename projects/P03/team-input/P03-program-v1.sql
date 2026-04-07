--
-- Group Number: 4
-- Group Members:
--   1. Yunus Emre Erkan
--   2. Lee Chun Nga
--   3. 
--   4. 
--

-- Trigger 1

CREATE OR REPLACE FUNCTION validate_stage_ranks(s INTEGER)
RETURNS VOID AS $$
DECLARE
  cnt INTEGER;
  max_rank INTEGER;
  min_rank INTEGER;
  num_active_riders INTEGER;
BEGIN
  SELECT COUNT(*), MAX(rank), MIN(rank)
  INTO cnt, max_rank, min_rank
  FROM results
  WHERE stage = s;

  IF cnt > 0 THEN
    IF min_rank <> 1 THEN
      RAISE EXCEPTION 'Ranks for stage % do not start at 1', s;
    END IF;

    IF max_rank <> cnt THEN
      RAISE EXCEPTION 'Ranks for stage % are not consecutive', s;
    END IF;

    SELECT COUNT(*) INTO num_active_riders
    FROM riders r
    WHERE NOT EXISTS (
      SELECT 1 FROM riders_exits re
      WHERE re.rider = r.bib AND re.stage <= s
    );

    IF cnt > num_active_riders THEN
      RAISE EXCEPTION 'Too many results for stage %', s;
    END IF;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_consecutive_ranks()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM validate_stage_ranks(NEW.stage);

  IF TG_OP = 'UPDATE' AND OLD.stage IS DISTINCT FROM NEW.stage THEN
    PERFORM validate_stage_ranks(OLD.stage);
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_consecutive_ranks
  AFTER INSERT OR UPDATE ON results
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE FUNCTION check_consecutive_ranks();

-- Trigger 2

CREATE OR REPLACE FUNCTION validate_rank_time(s INTEGER)
RETURNS VOID AS $$
DECLARE
  violation BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM results r1
    JOIN results r2 ON r1.stage = r2.stage
    WHERE r1.stage = s
      AND r1.rank < r2.rank
      AND r1.time > r2.time
  ) INTO violation;

  IF violation THEN
    RAISE EXCEPTION 'Rank-time inconsistency in stage %', s;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION check_rank_time_consistency()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM validate_rank_time(NEW.stage);

  IF TG_OP = 'UPDATE' AND OLD.stage IS DISTINCT FROM NEW.stage THEN
    PERFORM validate_rank_time(OLD.stage);
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_rank_time_consistency
  AFTER INSERT OR UPDATE ON results
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE FUNCTION check_rank_time_consistency();


-- Trigger 3

CREATE OR REPLACE FUNCTION check_no_result_after_exit_on_results()
RETURNS TRIGGER AS $$
DECLARE
  exit_stage INTEGER;
BEGIN
  SELECT re.stage INTO exit_stage
  FROM riders_exits re
  WHERE re.rider = NEW.rider;

  IF FOUND AND NEW.stage >= exit_stage THEN
    RAISE EXCEPTION 'Rider % exited at stage %', NEW.rider, exit_stage;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_no_result_after_exit_results
  AFTER INSERT OR UPDATE ON results
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE FUNCTION check_no_result_after_exit_on_results();


CREATE OR REPLACE FUNCTION check_no_result_after_exit_on_exits()
RETURNS TRIGGER AS $$
DECLARE
  has_result BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM results r
    WHERE r.rider = NEW.rider AND r.stage >= NEW.stage
  ) INTO has_result;

  IF has_result THEN
    RAISE EXCEPTION 'Rider % has results at or after stage % and cannot exit here', NEW.rider, NEW.stage;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_no_result_after_exit_exits
  AFTER INSERT OR UPDATE ON riders_exits
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE FUNCTION check_no_result_after_exit_on_exits();


-- Trigger 4

CREATE OR REPLACE FUNCTION check_no_consecutive_rest_days()
RETURNS TRIGGER AS $$
DECLARE
  min_day DATE;
  max_day DATE;
  curr_day DATE;
  consecutive_rest INTEGER;
BEGIN
  SELECT MIN(day), MAX(day) INTO min_day, max_day FROM stages;

  IF min_day IS NULL OR min_day = max_day THEN
    RETURN NULL;
  END IF;

  consecutive_rest := 0;

  FOR curr_day IN
    SELECT d::date
    FROM generate_series(min_day, max_day, '1 day'::interval) AS d
    ORDER BY d
  LOOP
    IF NOT EXISTS (SELECT 1 FROM stages WHERE day = curr_day) THEN
      consecutive_rest := consecutive_rest + 1;
      IF consecutive_rest >= 2 THEN
        RAISE EXCEPTION 'Consecutive rest days found';
      END IF;
    ELSE
      consecutive_rest := 0;
    END IF;
  END LOOP;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_no_consecutive_rest_days
  AFTER INSERT OR UPDATE ON stages
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE FUNCTION check_no_consecutive_rest_days();


-- Trigger 5

CREATE OR REPLACE FUNCTION check_max_two_rest_days()
RETURNS TRIGGER AS $$
DECLARE
  min_day DATE;
  max_day DATE;
  total_days INTEGER;
  num_stages INTEGER;
  rest_days INTEGER;
BEGIN
  SELECT MIN(day), MAX(day), COUNT(*)
  INTO min_day, max_day, num_stages
  FROM stages;

  IF min_day IS NULL OR min_day = max_day THEN
    RETURN NULL;
  END IF;

  total_days := (max_day - min_day) + 1;
  rest_days := total_days - num_stages;

  IF rest_days > 2 THEN
    RAISE EXCEPTION 'Too many rest days: % found but at most 2 allowed', rest_days;
  END IF;

  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_max_two_rest_days
  AFTER INSERT OR UPDATE ON stages
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE FUNCTION check_max_two_rest_days();