Today's Challenge
-- ============================================================
-- Lesson 07: KPI Dashboards
-- File: 01_enrich_schema.sql
-- Purpose: Enrich the tasks table with analytics columns
--
-- Run this in your FreeSQL worksheet after Lesson 06 schema.
-- ============================================================

-- Add columns needed for KPI analysis
ALTER TABLE tasks ADD (
    priority      VARCHAR2(10)  DEFAULT 'medium',
    due_date      DATE,
    completed_at  TIMESTAMP,
    tags          VARCHAR2(200)
);

-- Add check constraint for valid priorities
ALTER TABLE tasks ADD CONSTRAINT chk_task_priority
    CHECK (priority IN ('low', 'medium', 'high', 'critical'));

-- Add check constraint for valid statuses (expanded)
ALTER TABLE tasks DROP CONSTRAINT chk_task_status;
ALTER TABLE tasks ADD CONSTRAINT chk_task_status
    CHECK (status IN ('open', 'in_progress', 'blocked', 'completed', 'cancelled'));

COMMIT;

-- Verify
SELECT column_name, data_type, nullable
FROM   user_tab_columns
WHERE  table_name = 'TASKS'
ORDER  BY column_id;

-- ============================================================
-- Lesson 07: KPI Dashboards
-- File: 02_seed_dashboard_data.sql
-- Purpose: Generate 36 realistic tasks across 2 weeks
--
-- Run this in your FreeSQL worksheet.
-- ============================================================

-- First, clear existing tasks (keep teams and users from Lesson 06)
DELETE FROM tasks;
COMMIT;

-- ============================================================
-- 36 REALISTIC TASKS
-- ============================================================
-- Spread across 14 days with varied statuses, priorities, assignees
-- Includes cancelled tasks and overdue tasks for exercise coverage

INSERT INTO tasks (title, description, status, priority, assigned_to, created_at, due_date, completed_at, tags) VALUES
('Fix login bug', 'Users cannot log in with SSO after password reset', 'completed', 'high', 1, TIMESTAMP '2026-05-01 09:00:00', DATE '2026-05-03', TIMESTAMP '2026-05-02 14:30:00', 'bug,sso,auth'),
('Design new dashboard', 'Create mockups for analytics page with KPI cards', 'in_progress', 'medium', 3, TIMESTAMP '2026-05-01 10:00:00', DATE '2026-05-10', NULL, 'design,ui,dashboard'),
('Update dependencies', 'Upgrade numpy and pandas to latest stable', 'completed', 'low', 2, TIMESTAMP '2026-05-01 11:00:00', DATE '2026-05-05', TIMESTAMP '2026-05-04 16:00:00', 'maintenance,deps'),
('API rate limiting', 'Implement rate limiting on public endpoints', 'open', 'high', 1, TIMESTAMP '2026-05-02 09:00:00', DATE '2026-05-08', NULL, 'api,security,backend'),
('Write unit tests for auth', 'Cover login, logout, token refresh flows', 'in_progress', 'medium', 2, TIMESTAMP '2026-05-02 10:00:00', DATE '2026-05-09', NULL, 'testing,auth,qa'),
('Database backup script', 'Automate daily backup to S3 with retention', 'completed', 'medium', 1, TIMESTAMP '2026-05-02 11:00:00', DATE '2026-05-04', TIMESTAMP '2026-05-03 10:00:00', 'devops,backup,s3'),
('Mobile responsive nav', 'Menu does not collapse on screens < 768px', 'blocked', 'high', 3, TIMESTAMP '2026-05-03 09:00:00', DATE '2026-05-07', NULL, 'bug,mobile,ui,css'),
('User profile page', 'Allow users to edit avatar and bio', 'open', 'low', 3, TIMESTAMP '2026-05-03 10:00:00', DATE '2026-05-15', NULL, 'feature,profile,frontend'),
('Optimize slow query', 'Report generation takes 45 seconds', 'completed', 'critical', 1, TIMESTAMP '2026-05-03 11:00:00', DATE '2026-05-04', TIMESTAMP '2026-05-03 18:00:00', 'performance,sql,optimization'),
('Set up CI/CD pipeline', 'GitHub Actions for test + deploy', 'in_progress', 'medium', 2, TIMESTAMP '2026-05-04 09:00:00', DATE '2026-05-12', NULL, 'devops,cicd,github'),
('Error tracking integration', 'Connect Sentry for production error alerts', 'open', 'medium', 1, TIMESTAMP '2026-05-04 10:00:00', DATE '2026-05-11', NULL, 'monitoring,sentry,ops'),
('Dark mode toggle', 'Add theme switcher with CSS variables', 'completed', 'low', 3, TIMESTAMP '2026-05-04 11:00:00', DATE '2026-05-06', TIMESTAMP '2026-05-05 15:00:00', 'feature,ui,theming'),
('Password strength meter', 'Visual indicator for password complexity', 'open', 'low', 2, TIMESTAMP '2026-05-05 09:00:00', DATE '2026-05-14', NULL, 'feature,auth,frontend'),
('Export to CSV', 'Allow users to download report as CSV', 'in_progress', 'medium', 3, TIMESTAMP '2026-05-05 10:00:00', DATE '2026-05-13', NULL, 'feature,export,reporting'),
('Redis caching layer', 'Cache frequent queries to reduce DB load', 'open', 'high', 1, TIMESTAMP '2026-05-05 11:00:00', DATE '2026-05-10', NULL, 'backend,redis,performance'),
('Email notification service', 'Send task assignment emails via SendGrid', 'completed', 'medium', 2, TIMESTAMP '2026-05-06 09:00:00', DATE '2026-05-08', TIMESTAMP '2026-05-07 12:00:00', 'feature,email,notifications'),
('Audit log table', 'Track all changes to tasks with timestamps', 'in_progress', 'medium', 1, TIMESTAMP '2026-05-06 10:00:00', DATE '2026-05-15', NULL, 'feature,audit,logging'),
('Two-factor auth', 'Add TOTP support for admin accounts', 'open', 'critical', 2, TIMESTAMP '2026-05-06 11:00:00', DATE '2026-05-09', NULL, 'feature,security,auth'),
('Load testing script', 'Simulate 1000 concurrent users with k6', 'completed', 'medium', 1, TIMESTAMP '2026-05-07 09:00:00', DATE '2026-05-08', TIMESTAMP '2026-05-07 17:00:00', 'testing,performance,k6'),
('Documentation site', 'Set up MkDocs for API documentation', 'open', 'low', 3, TIMESTAMP '2026-05-07 10:00:00', DATE '2026-05-20', NULL, 'docs,mkdocs,technical-writing'),
('Fix memory leak', 'Node process grows to 2GB after 24 hours', 'blocked', 'critical', 1, TIMESTAMP '2026-05-07 11:00:00', DATE '2026-05-09', NULL, 'bug,performance,memory'),
('Webhook integrations', 'Allow third-party services to subscribe to events', 'open', 'medium', 2, TIMESTAMP '2026-05-08 09:00:00', DATE '2026-05-16', NULL, 'feature,api,integrations'),
('Search autocomplete', 'Typeahead search with debounced API calls', 'in_progress', 'low', 3, TIMESTAMP '2026-05-08 10:00:00', DATE '2026-05-14', NULL, 'feature,search,frontend'),
('GDPR data export', 'Allow users to download all their data', 'open', 'high', 1, TIMESTAMP '2026-05-08 11:00:00', DATE '2026-05-12', NULL, 'compliance,gdpr,privacy'),
('Slack bot integration', 'Post task updates to team Slack channel', 'completed', 'low', 2, TIMESTAMP '2026-05-09 09:00:00', DATE '2026-05-11', TIMESTAMP '2026-05-10 11:00:00', 'feature,slack,bot'),
('Database migration tool', 'Evaluate Flyway vs Liquibase for schema changes', 'open', 'medium', 1, TIMESTAMP '2026-05-09 10:00:00', DATE '2026-05-17', NULL, 'research,db,migrations'),
('Image upload resizing', 'Resize avatars to 256x256 on upload', 'in_progress', 'low', 3, TIMESTAMP '2026-05-09 11:00:00', DATE '2026-05-13', NULL, 'feature,images,processing'),
('Session timeout bug', 'Users stay logged in after 30 days', 'open', 'high', 2, TIMESTAMP '2026-05-10 09:00:00', DATE '2026-05-11', NULL, 'bug,auth,sessions'),
('Analytics event tracking', 'Track page views and clicks with Mixpanel', 'completed', 'medium', 3, TIMESTAMP '2026-05-10 10:00:00', DATE '2026-05-12', TIMESTAMP '2026-05-11 09:00:00', 'feature,analytics,tracking'),
('Kubernetes deployment', 'Migrate from EC2 to EKS with Helm charts', 'open', 'critical', 1, TIMESTAMP '2026-05-10 11:00:00', DATE '2026-05-15', NULL, 'devops,k8s,infrastructure'),

-- ============================================================
-- ADDITIONAL TASKS FOR EXERCISE COVERAGE
-- ============================================================
-- Cancelled tasks (for completion_rate calculation in EXERCISE 3)
('Legacy API deprecation', 'Sunset the v1 API endpoints', 'cancelled', 'low', 2, TIMESTAMP '2026-05-01 08:00:00', DATE '2026-05-20', NULL, 'api,deprecation,legacy'),
('Manual data migration', 'One-time script to migrate old records', 'cancelled', 'medium', 1, TIMESTAMP '2026-05-02 08:00:00', DATE '2026-05-10', NULL, 'migration,data,one-time'),
('Third-party auth provider', 'Integrate with Okta for enterprise SSO', 'cancelled', 'high', 3, TIMESTAMP '2026-05-03 08:00:00', DATE '2026-05-18', NULL, 'auth,sso,enterprise'),

-- Overdue tasks (for EXERCISE 5 — overdue report with severity)
('Security audit remediation', 'Fix findings from Q1 penetration test', 'open', 'critical', 1, TIMESTAMP '2026-05-01 09:00:00', DATE '2026-05-05', NULL, 'security,audit,compliance'),
('Customer data retention policy', 'Implement automatic data purging', 'in_progress', 'high', 2, TIMESTAMP '2026-05-02 09:00:00', DATE '2026-05-06', NULL, 'compliance,gdpr,data'),
('Payment gateway integration', 'Add Stripe support for subscriptions', 'blocked', 'medium', 3, TIMESTAMP '2026-05-03 09:00:00', DATE '2026-05-07', NULL, 'payments,stripe,billing'),
('Performance regression fix', 'Query latency spike after last deploy', 'open', 'critical', 1, TIMESTAMP '2026-05-04 09:00:00', DATE '2026-05-08', NULL, 'performance,regression,sql');

COMMIT;

-- Verify counts
SELECT status, COUNT(*) AS task_count
FROM   tasks
GROUP  BY status
ORDER  BY task_count DESC;

