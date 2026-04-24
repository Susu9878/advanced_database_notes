-- Lesson 04: Class Exercises
-- Students: work through these in order. Don't skip the verify steps.

-- ============================================================
-- EXERCISE 1: Manual transaction (warm-up)
-- ============================================================
-- Transfer $50 from Charlie (3) to Alice (1) using BEGIN / COMMIT manually.
-- Before: verify balances. After COMMIT: verify again.

-- Your SQL here:
BEGIN
    UPDATE accounts
    SET balance = balance - 50
    WHERE account_id = 3;

    UPDATE accounts
    SET balance = balance + 50
    WHERE account_id = 1;

    COMMIT;
END;
 
-- ============================================================
-- EXERCISE 2: Catch yourself with ROLLBACK
-- ============================================================
-- Start a transfer of $10,000 from Bob (2) to Charlie (3).
-- Before committing, check the balances. Does Bob have enough?
-- Use ROLLBACK to undo. Verify balances restored.

-- Your SQL here:
CREATE OR REPLACE PROCEDURE transfer_funds(
    p_from_account  IN  NUMBER,
    p_to_account    IN  NUMBER,
    p_amount        IN  NUMBER
) AS
    v_from_balance  NUMBER;
BEGIN
    SELECT balance INTO v_from_balance
    FROM accounts
    WHERE account_id = p_from_account;
    IF v_from_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient funds in account ' || p_from_account);
    END IF;
    UPDATE accounts SET balance = balance - p_amount WHERE account_id = p_from_account;
    UPDATE accounts SET balance = balance + p_amount WHERE account_id = p_to_account;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transfer complete: $' || p_amount ||
                         ' from account ' || p_from_account ||
                         ' to account ' || p_to_account);
EXCEPTION
    WHEN OTHERS THEN
        -- Something went wrong — undo everything
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transfer failed. All changes rolled back.');
        RAISE;  -- re-raise the error so the caller knows it failed
END;
 
BEGIN
    transfer_funds(2, 3, 10000);
END;

-- ============================================================
-- EXERCISE 3: SAVEPOINT checkpoint
-- ============================================================
-- You need to:
-- 1. Add $25 to Alice's balance
-- 2. Set a savepoint
-- 3. Deduct $25 from Charlie's balance (wrong account — you meant Bob)
-- 4. Rollback to savepoint
-- 5. Deduct $25 from Bob's balance instead
-- 6. Commit

-- Your SQL here:
BEGIN
    UPDATE accounts
    SET balance = balance + 25
    WHERE account_id = 1;

    SAVEPOINT transaction;

    UPDATE accounts
    SET balance = balance - 25
    WHERE account_id = 3;

    ROLLBACK TO SAVEPOINT transaction;

    UPDATE accounts
    SET balance = balance - 25
    WHERE account_id = 2;

    COMMIT;
END;
 

-- ============================================================
-- EXERCISE 4: Write your own stored procedure
-- ============================================================
-- Create a procedure called deposit_funds(p_account_id, p_amount)
-- It should:
-- 1. Validate that p_amount > 0 (raise error if not)
-- 2. Add p_amount to the account balance
-- 3. COMMIT on success
-- 4. ROLLBACK + re-raise on any error
-- Test it with: EXEC deposit_funds(3, 75);

-- Your SQL here:
CREATE OR REPLACE PROCEDURE deposit_funds (
    p_account_id IN accounts.account_id%TYPE,
    p_amount     IN NUMBER
) IS
BEGIN
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Deposit amount must be greater than zero.');
    END IF;
    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Account not found.');
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END deposit_funds; 

-- ============================================================
-- EXERCISE 5: Discussion
-- ============================================================
-- Answer these in words (no SQL needed):

-- Q1: You're building a patient appointment booking system.
-- A booking requires:
--   a) Reserve the time slot
--   b) Create the appointment record
--   c) Send a confirmation notification
-- Which of these should be inside the transaction? Which should be outside? Why?
    -- Reserving the time slot and creating the appointment should be inside the transaction so id
    -- there is no space available we can do a rollback on everything. Sending the notification could 
    -- be set as a trigger

-- Q2: Your stored procedure calls COMMIT at the end.
-- A developer calls your procedure from inside their own larger transaction.
-- What problem does this create?
    -- data is commited meaning its saved to disk and if their larger transaction does a rollback later
    -- there would be conficts with the data as they are already commited

-- Q3: You have a function called calculate_copay() and a procedure called post_payment().
-- A colleague wants to use calculate_copay() inside a SELECT statement.
-- Can they? Can they do the same with post_payment()? Why or why not?
    -- calculate_copay() is a function that should return something so it is usable in a selct.
    -- the procedure does not return anything so it cant be used in a select as it cant displlay anything on tables