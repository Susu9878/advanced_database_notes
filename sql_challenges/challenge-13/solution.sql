++++++++++++++++++++++++++++++++++++++++++++++++++++

# Lesson 08: Exercise — Assignment History

A support ticketing system. Tickets get reassigned between agents. You need
to track who was assigned when the ticket was created vs when it was resolved.

---

## Step 1 — Source Tables (OLTP)

Create two tables:

**`tickets`** — current state of each ticket. Needs:
- ticket_id, title, status, priority, created_at, resolved_at, assigned_to

**`ticket_assignments`** — history of who was assigned when. Needs:
- assignment_id, ticket_id, assigned_to, assigned_by, valid_from, valid_to

```sql
-- Your code here
```
CREATE TABLE TICKETS (
    ticket_id int PRIMARY KEY,
    title varchar2(255) NOT NULL,
    status varchar2(20) NOT NULL 
        CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    priority int NOT NULL
        CHECK (priority BETWEEN 1 AND 5),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    resolved_at TIMESTAMP,
    assigned_to INT NOT NULL,

    CONSTRAINT chk_resolved_at
        CHECK (
            resolved_at IS NULL
            OR resolved_at >= created_at
        ),

    CONSTRAINT fk_ticket_user
        FOREIGN KEY (assigned_to)
        REFERENCES USERS(id)
);

CREATE TABLE TICKETS_ASSIGNMENTS (
    assignment_id INT PRIMARY KEY,
    ticket_id INT NOT NULL,
    assigned_to INT NOT NULL,
    assigned_by INT NOT NULL,
    valid_from TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
    valid_to TIMESTAMP NOT NULL,

    CONSTRAINT chk_valid_dates
        CHECK (valid_to >= valid_from),

    CONSTRAINT fk_assignment_ticket
        FOREIGN KEY (ticket_id)
        REFERENCES tickets(ticket_id),

    CONSTRAINT fk_assignment_assigned_to
        FOREIGN KEY (assigned_to)
        REFERENCES users(id),

    CONSTRAINT fk_assignment_assigned_by
        FOREIGN KEY (assigned_by)
        REFERENCES users(id)
);
---

## Step 2 — Sample Data

Insert at least 5 tickets. Make sure at least one gets reassigned (different
person in `ticket_assignments` than the current `assigned_to` in `tickets`).

```sql
-- Your code here
```
INSERT INTO TICKETS  VALUES (
    1,
    'Login page error',
    'OPEN',
    4,
    SYSTIMESTAMP,
    NULL,
    1
);

INSERT INTO TICKETS VALUES (
    2,
    'Database backup failure',
    'IN_PROGRESS',
    5,
    SYSTIMESTAMP - INTERVAL '2' DAY,
    NULL,
    2
);

INSERT INTO TICKETS VALUES (
    3,
    'UI alignment issue',
    'RESOLVED',
    2,
    SYSTIMESTAMP - INTERVAL '5' DAY,
    SYSTIMESTAMP - INTERVAL '1' DAY,
    1
);

INSERT INTO TICKETS VALUES (
    4,
    'Email notifications not sent',
    'CLOSED',
    3,
    SYSTIMESTAMP - INTERVAL '10' DAY,
    SYSTIMESTAMP - INTERVAL '3' DAY,
    3
);

INSERT INTO TICKETS VALUES (
    5,
    'Performance issue on dashboard',
    'IN_PROGRESS',
    5,
    SYSTIMESTAMP - INTERVAL '1' DAY,
    NULL,
    2
);

--reassigned
INSERT INTO TICKETS_ASSIGNMENTS VALUES (
    5,
    5,
    1,
    3,
    SYSTIMESTAMP - INTERVAL '3' DAY,
    SYSTIMESTAMP - INTERVAL '1' DAY
);
---

## Step 3 — Trigger

Write a trigger on `tickets` that:
- On INSERT or UPDATE of `assigned_to`, logs the change to `ticket_assignments`
- Closes the previous active assignment (sets its `valid_to`)
- Inserts a new row with `valid_from = now()` and `valid_to = NULL`

```sql
-- Your code here
```
CREATE OR REPLACE TRIGGER trg_ticket_assignment
AFTER INSERT OR UPDATE OF assigned_to
ON tickets
FOR EACH ROW
DECLARE
    v_assignment_id INT;
BEGIN
    IF INSERTING OR (:OLD.assigned_to != :NEW.assigned_to) THEN

        UPDATE tickets_assignments
        SET valid_to = SYSTIMESTAMP
        WHERE ticket_id = :NEW.ticket_id
          AND valid_to IS NULL;

        SELECT NVL(MAX(assignment_id), 0) + 1
        INTO v_assignment_id
        FROM tickets_assignments;

        INSERT INTO tickets_assignments (
            assignment_id,
            ticket_id,
            assigned_to,
            assigned_by,
            valid_from,
            valid_to
        ) VALUES (
            v_assignment_id,
            :NEW.ticket_id,
            :NEW.assigned_to,
            :NEW.assigned_to,
            SYSTIMESTAMP,
            NULL
        );

    END IF;
END;

**Test it:** Reassign a ticket, then query `ticket_assignments` to confirm
both the old and new assignment are recorded.

---

## Step 4 — Data Warehouse Tables (Star Schema)

Create two tables:

**`dim_agent`** — agent details. Needs: agent_key, agent_name, team

**`fact_ticket_daily`** — daily counts per agent/status/priority. Needs:
date_key, agent_key, status, priority, tickets_created, tickets_resolved

```sql
-- Your code here
```
CREATE TABLE dim_agent (
    agent_key INT PRIMARY KEY,
    agent_name VARCHAR2(100) NOT NULL,
    team VARCHAR2(100) NOT NULL
);

CREATE TABLE fact_ticket_daily (
    date_key DATE NOT NULL,
    agent_key INT NOT NULL,
    status VARCHAR2(20) NOT NULL,
    priority INT NOT NULL,
    tickets_created INT DEFAULT 0 NOT NULL,
    tickets_resolved INT DEFAULT 0 NOT NULL,

    CONSTRAINT pk_fact_ticket_daily
        PRIMARY KEY (
            date_key,
            agent_key,
            status,
            priority
        ),

    CONSTRAINT fk_fact_agent
        FOREIGN KEY (agent_key)
        REFERENCES dim_agent(agent_key),

    CONSTRAINT chk_fact_status
        CHECK (
            status IN (
                'OPEN',
                'IN_PROGRESS',
                'RESOLVED',
                'CLOSED'
            )
        ),

    CONSTRAINT chk_fact_priority
        CHECK (
            priority BETWEEN 1 AND 5
        ),

    CONSTRAINT chk_ticket_counts
        CHECK (
            tickets_created >= 0
            AND tickets_resolved >= 0
        )
);

---

## Step 5 — Populate dim_agent

Insert 3-4 agents with their teams.

```sql
-- Your code here
```
INSERT INTO dim_agent (agent_key, agent_name, team)
VALUES (1, 'Alice Smith', 'Backend Support');

INSERT INTO dim_agent (agent_key, agent_name, team)
VALUES (2, 'Bob Jones', 'Infrastructure');

INSERT INTO dim_agent (agent_key, agent_name, team)
VALUES (3, 'Carol White', 'Project Management');

INSERT INTO dim_agent (agent_key, agent_name, team)
VALUES (4, 'David Brown', 'Frontend Support');

---

## Step 6 — ETL Logic (Colab)

In your Colab notebook, write pandas code that:
1. Extracts `tickets` and `ticket_assignments` from FreeSQL
2. For each ticket, finds who was assigned at `created_at` using:
   `valid_from <= created_at AND (valid_to IS NULL OR valid_to > created_at)`
3. Same for `resolved_at`
4. Groups by date, agent, status, priority and counts
5. Inserts into `fact_ticket_daily`

---

## Step 7 — Verify

Write a query joining `fact_ticket_daily` and `dim_agent` to show tickets
created and resolved per agent per day. The reassigned ticket should show
the original agent for creation and the new agent for resolution.

```sql
-- Your code here
```

SELECT
    f.date_key,
    a.agent_name,
    a.team,
    f.status,
    f.priority,
    f.tickets_created,
    f.tickets_resolved
FROM fact_ticket_daily f
JOIN dim_agent a
    ON f.agent_key = a.agent_key
ORDER BY
    f.date_key,
    a.agent_name,
    f.priority;