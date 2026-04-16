Excercise 1
-- a) What scan type do you see? Why?
    -- All the data from the table that has site_id = 3
-- b) site_id has values 1–5. Is this high or low cardinality?
    -- low cardinallity because site_id is not unique
-- c) Would adding an index on site_id help? Why or why not?
    -- no, indexes work better when they filter through few rows
Excercise 2
-- Step 1: Create it
-- (write the CREATE INDEX statement here)
CREATE INDEX visit_date ON patient_visits(visit_date);

-- Step 2: Gather stats
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;

-- Step 3: Run the range query and check the plan
EXPLAIN PLAN FOR
SELECT * FROM patient_visits
WHERE visit_date BETWEEN SYSDATE - 30 AND SYSDATE;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Questions:
-- a) Does Oracle use the index for this range?
    -- no
-- b) Change the range to the last 7 days. Does the plan change?
    -- only rows read and bytes
-- c) Change to the last 700 days. What happens?
    -- More rows and more bytes compared to 30 and 7 days. 
    -- Cost(%cpu) and time remained the same
-- d) Why does the range size affect whether Oracle uses the index?
    -- Oracle determines whether its more efficient to 
    -- use the index or a full table scan

-- Exercise 3 — Composite index
CREATE INDEX idx_pv_patient_date ON patient_visits(patient_id, visit_date);

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

EXPLAIN PLAN FOR
SELECT * FROM patient_visits
WHERE patient_id = 1234
  AND visit_date > SYSDATE - 90;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Questions:
-- a) Does the plan use the composite index?
    -- yes
-- b) Now try querying ONLY on visit_date (no patient_id).
--    Does the composite index get used? Why not?
    --No, patient_id is needed for this composite index. it would first search 
    --all indexes patient id and then index through visit date
-- c) What's the rule about column order in composite indexes?
    --composite indexes uses can only be used if the indexes are used from left to right

-- Exercise 4 — Function that breaks an index
-- This query CAN use the index:
EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE patient_id = 5432;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- This one cannot — why?
EXPLAIN PLAN FOR
SELECT * FROM patient_visits WHERE TO_CHAR(patient_id) = '5432';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
    -- theres a function being used for the applied column so it will not use the index

-- Questions:
-- a) What scan type did the second query use?
    -- table access full
-- b) Why does wrapping a column in a function break index use?
    -- oracle cant use the index because the indexed column 
    -- is being read differently than normal by the function
-- c) How would you rewrite the second query to allow index use?
SELECT * FROM patient_visits WHERE patient_id = 5432;

-- Exercise 5 — Discussion: real-world scenarios
--
-- For each scenario below, decide:
--   a) Would you add an index?
--   b) On which column(s)?
--   c) Any concerns?

-- Scenario A:
-- A reporting table gets loaded once per night (batch ETL).
-- During the day, analysts run SELECT queries by date range.
-- The table has 50 million rows.
-- → Index on date? Yes/No, why?
    --   a) Would you add an index?
        -- yes, because these are rows that will be used throghout the day
        -- and it would prevent to scan millions of row per query
    --   b) On which column(s)?
        -- date
    --   c) Any concerns?
        -- indexing only by date may still load a lot fo rows. 
        -- a composite indexes for diferent purposes would work better

-- Scenario B:
-- An OLTP orders table gets 10,000 inserts per minute.
-- Support staff look up orders by customer_id or order_status.
-- order_status has 4 values: pending, processing, shipped, cancelled.
-- → What indexes would you add?
    --   a) Would you add an index?
        -- an composite index ;
    --   b) On which column(s)?
        -- customer_id and order_status
    --   c) Any concerns?
        -- an index on order_status cant work because indexing 4 unique values in a table
        -- of thousands of rows will have low latency.
        -- a composite index starting on customer_id wich is unique will have a higher latency.

-- Scenario C:
-- A patient table has an email column (unique per patient).
-- There are 5 million patients.
-- The app frequently does: WHERE email = 'user@example.com'
-- → What kind of index would be best here?
    --   a) Would you add an index?
        -- yes
    --   b) On which column(s)?
        -- email
    --   c) Any concerns?
        -- no