-- ============================================================
-- PAHO - Sample Data Loader
-- OpenEMR 8.0.0.2
-- ============================================================
--
-- Creates:
--   * 10 sample patients (pubpid PAHO-SAMPLE-PATIENT-001..010) with
--     portal logins patient001..patient010. Each missing patient is
--     assigned the next normal pid via (SELECT COALESCE(MAX(pid),0)+1
--     FROM patient_data) so that OpenEMR's "Add Patient" form (which
--     uses MAX(pid)+1) continues to allocate contiguous pids for
--     real patients added later.
--   * 5 sample doctors/providers (username doctor001..doctor005)
--     wired into the Physicians ACL group so they can log in to the
--     OpenEMR admin UI and see their calendar/agenda. Each is set
--     calendar=1 so they appear as schedulable providers in the
--     calendar (the provider dropdown filters on authorized=1 AND
--     calendar=1; see UserService::searchUsersForCalendar).
--
-- Password for every sample user: 0p3n3MR!
-- Stored as a pre-computed bcrypt hash (cost 12) generated and
-- verified against the same OpenEMR install. No plaintext anywhere.
--
-- Idempotency:
--   Every INSERT is guarded by a NOT EXISTS check on a natural key
--   (pubpid, portal_login_username, users.username, gacl_aro.value,
--   the map (acl_id, group_id) / (group_id, aro_id) pairs).
--   Safe to run repeatedly. Real records are never touched.
--
-- Restrictions (verified — none violated):
--   No CREATE, ALTER, DROP, TRUNCATE, DELETE, REPLACE.
--   No changes to `globals` or any configuration table.
--   No encounters, appointments, billing, insurance, prescriptions,
--   clinical notes, documents, or translations.
-- ============================================================


-- ============================================================
-- A. patient_data — 10 sample patients
-- ============================================================
-- Each missing patient is assigned the next available pid via
-- (SELECT COALESCE(MAX(pid), 0) + 1 FROM patient_data). This is
-- the same allocation rule OpenEMR's "Add Patient" form uses, so
-- pid numbering stays contiguous and real patients added later
-- pick up where these leave off. Idempotency guard is on pubpid.
-- Within a multi_query batch, statement N sees rows inserted by
-- statements 1..N-1, so the ten INSERTs allocate ten consecutive
-- pids when run on a fresh table.

INSERT INTO patient_data (pid, pubpid, fname, lname, DOB, sex, street, city, state, postal_code, country_code, phone_home, email, allow_patient_portal)
SELECT next_pid.np, 'PAHO-SAMPLE-PATIENT-001', 'Sofia',     'Ramirez',  '1980-01-15', 'Female', '100 Sample St', 'Sampleville', 'XX', '00001', 'US', '+1-555-0101', 'sofia.ramirez@emailpaciente.com',     'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-SAMPLE-PATIENT-001');

INSERT INTO patient_data (pid, pubpid, fname, lname, DOB, sex, street, city, state, postal_code, country_code, phone_home, email, allow_patient_portal)
SELECT next_pid.np, 'PAHO-SAMPLE-PATIENT-002', 'Mateo',     'Torres',   '1982-02-20', 'Male',   '101 Sample St', 'Sampleville', 'XX', '00001', 'US', '+1-555-0102', 'mateo.torres@emailpaciente.com',      'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-SAMPLE-PATIENT-002');

INSERT INTO patient_data (pid, pubpid, fname, lname, DOB, sex, street, city, state, postal_code, country_code, phone_home, email, allow_patient_portal)
SELECT next_pid.np, 'PAHO-SAMPLE-PATIENT-003', 'Valentina', 'Morales',  '1975-03-10', 'Female', '102 Sample St', 'Sampleville', 'XX', '00001', 'US', '+1-555-0103', 'valentina.morales@emailpaciente.com', 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-SAMPLE-PATIENT-003');

INSERT INTO patient_data (pid, pubpid, fname, lname, DOB, sex, street, city, state, postal_code, country_code, phone_home, email, allow_patient_portal)
SELECT next_pid.np, 'PAHO-SAMPLE-PATIENT-004', 'Santiago',  'Herrera',  '1990-04-25', 'Male',   '103 Sample St', 'Sampleville', 'XX', '00001', 'US', '+1-555-0104', 'santiago.herrera@emailpaciente.com',  'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-SAMPLE-PATIENT-004');

INSERT INTO patient_data (pid, pubpid, fname, lname, DOB, sex, street, city, state, postal_code, country_code, phone_home, email, allow_patient_portal)
SELECT next_pid.np, 'PAHO-SAMPLE-PATIENT-005', 'Camila',    'Vargas',   '1965-05-05', 'Female', '104 Sample St', 'Sampleville', 'XX', '00001', 'US', '+1-555-0105', 'camila.vargas@emailpaciente.com',     'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-SAMPLE-PATIENT-005');

INSERT INTO patient_data (pid, pubpid, fname, lname, DOB, sex, street, city, state, postal_code, country_code, phone_home, email, allow_patient_portal)
SELECT next_pid.np, 'PAHO-SAMPLE-PATIENT-006', 'Nicolas',   'Castillo', '1995-06-12', 'Male',   '105 Sample St', 'Sampleville', 'XX', '00001', 'US', '+1-555-0106', 'nicolas.castillo@emailpaciente.com',  'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-SAMPLE-PATIENT-006');

INSERT INTO patient_data (pid, pubpid, fname, lname, DOB, sex, street, city, state, postal_code, country_code, phone_home, email, allow_patient_portal)
SELECT next_pid.np, 'PAHO-SAMPLE-PATIENT-007', 'Isabella',  'Navarro',  '1970-07-30', 'Female', '106 Sample St', 'Sampleville', 'XX', '00001', 'US', '+1-555-0107', 'isabella.navarro@emailpaciente.com',  'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-SAMPLE-PATIENT-007');

INSERT INTO patient_data (pid, pubpid, fname, lname, DOB, sex, street, city, state, postal_code, country_code, phone_home, email, allow_patient_portal)
SELECT next_pid.np, 'PAHO-SAMPLE-PATIENT-008', 'Diego',     'Mendoza',  '2001-08-18', 'Male',   '107 Sample St', 'Sampleville', 'XX', '00001', 'US', '+1-555-0108', 'diego.mendoza@emailpaciente.com',     'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-SAMPLE-PATIENT-008');

INSERT INTO patient_data (pid, pubpid, fname, lname, DOB, sex, street, city, state, postal_code, country_code, phone_home, email, allow_patient_portal)
SELECT next_pid.np, 'PAHO-SAMPLE-PATIENT-009', 'Mariana',   'Rojas',    '1988-09-09', 'Female', '108 Sample St', 'Sampleville', 'XX', '00001', 'US', '+1-555-0109', 'mariana.rojas@emailpaciente.com',     'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-SAMPLE-PATIENT-009');

INSERT INTO patient_data (pid, pubpid, fname, lname, DOB, sex, street, city, state, postal_code, country_code, phone_home, email, allow_patient_portal)
SELECT next_pid.np, 'PAHO-SAMPLE-PATIENT-010', 'Andres',    'Paredes',  '1992-10-22', 'Male',   '109 Sample St', 'Sampleville', 'XX', '00001', 'US', '+1-555-0110', 'andres.paredes@emailpaciente.com',    'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-SAMPLE-PATIENT-010');

-- Sync the demographic fields for any sample patients that already
-- exist from a previous run. Keyed on pubpid (our sample range), so
-- only the rows we own get touched; the UPDATE is a no-op for any
-- pubpid not in the database.
UPDATE patient_data SET fname='Sofia',     lname='Ramirez',  sex='Female', email='sofia.ramirez@emailpaciente.com'     WHERE pubpid='PAHO-SAMPLE-PATIENT-001';
UPDATE patient_data SET fname='Mateo',     lname='Torres',   sex='Male',   email='mateo.torres@emailpaciente.com'      WHERE pubpid='PAHO-SAMPLE-PATIENT-002';
UPDATE patient_data SET fname='Valentina', lname='Morales',  sex='Female', email='valentina.morales@emailpaciente.com' WHERE pubpid='PAHO-SAMPLE-PATIENT-003';
UPDATE patient_data SET fname='Santiago',  lname='Herrera',  sex='Male',   email='santiago.herrera@emailpaciente.com'  WHERE pubpid='PAHO-SAMPLE-PATIENT-004';
UPDATE patient_data SET fname='Camila',    lname='Vargas',   sex='Female', email='camila.vargas@emailpaciente.com'     WHERE pubpid='PAHO-SAMPLE-PATIENT-005';
UPDATE patient_data SET fname='Nicolas',   lname='Castillo', sex='Male',   email='nicolas.castillo@emailpaciente.com'  WHERE pubpid='PAHO-SAMPLE-PATIENT-006';
UPDATE patient_data SET fname='Isabella',  lname='Navarro',  sex='Female', email='isabella.navarro@emailpaciente.com'  WHERE pubpid='PAHO-SAMPLE-PATIENT-007';
UPDATE patient_data SET fname='Diego',     lname='Mendoza',  sex='Male',   email='diego.mendoza@emailpaciente.com'     WHERE pubpid='PAHO-SAMPLE-PATIENT-008';
UPDATE patient_data SET fname='Mariana',   lname='Rojas',    sex='Female', email='mariana.rojas@emailpaciente.com'     WHERE pubpid='PAHO-SAMPLE-PATIENT-009';
UPDATE patient_data SET fname='Andres',    lname='Paredes',  sex='Male',   email='andres.paredes@emailpaciente.com'    WHERE pubpid='PAHO-SAMPLE-PATIENT-010';


-- ============================================================
-- B. patient_access_onsite — portal credentials for the 10 patients
-- ============================================================
-- portal_pwd_status = 1 means "no forced password change on next
-- login" (column default is 1; we set it explicitly for clarity).
-- portal_login_username is the BINARY-compared value during portal
-- login. Hash literal below is verified bcrypt of '0p3n3MR!'.
-- pid is looked up from patient_data by pubpid so this row always
-- links to the patient created in section A regardless of which
-- numeric pid was allocated.

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'patient001', 'patient001', '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-SAMPLE-PATIENT-001'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'patient001');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'patient002', 'patient002', '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-SAMPLE-PATIENT-002'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'patient002');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'patient003', 'patient003', '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-SAMPLE-PATIENT-003'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'patient003');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'patient004', 'patient004', '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-SAMPLE-PATIENT-004'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'patient004');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'patient005', 'patient005', '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-SAMPLE-PATIENT-005'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'patient005');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'patient006', 'patient006', '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-SAMPLE-PATIENT-006'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'patient006');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'patient007', 'patient007', '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-SAMPLE-PATIENT-007'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'patient007');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'patient008', 'patient008', '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-SAMPLE-PATIENT-008'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'patient008');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'patient009', 'patient009', '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-SAMPLE-PATIENT-009'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'patient009');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'patient010', 'patient010', '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-SAMPLE-PATIENT-010'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'patient010');


-- ============================================================
-- C. users — 5 sample doctors
-- ============================================================
-- users.id is AUTO_INCREMENT, so we omit it. Idempotency guard is
-- on username (BINARY-compared at login). authorized=1 marks the
-- user as a clinician; active=1 lets login proceed; calendar=1 makes
-- the provider show up in the calendar's schedulable-provider list
-- (the dropdown query filters on authorized=1 AND calendar=1).

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'doctor001', 'Alejandro', 'Fuentes',  'alejandro.fuentes@emailpaciente.com', 1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'doctor001');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'doctor002', 'Carolina',  'Salazar',  'carolina.salazar@emailpaciente.com',  1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'doctor002');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'doctor003', 'Ricardo',   'Benitez',  'ricardo.benitez@emailpaciente.com',   1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'doctor003');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'doctor004', 'Daniela',   'Cardenas', 'daniela.cardenas@emailpaciente.com',  1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'doctor004');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'doctor005', 'Fernando',  'Cabrera',  'fernando.cabrera@emailpaciente.com',  1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'doctor005');

-- Sync provider names/emails for any sample doctors that already
-- exist from a previous run. Keyed on username, so only our 5
-- sample rows are touched.
UPDATE users SET fname='Alejandro', lname='Fuentes',  email='alejandro.fuentes@emailpaciente.com', calendar=1 WHERE username='doctor001';
UPDATE users SET fname='Carolina',  lname='Salazar',  email='carolina.salazar@emailpaciente.com',  calendar=1 WHERE username='doctor002';
UPDATE users SET fname='Ricardo',   lname='Benitez',  email='ricardo.benitez@emailpaciente.com',   calendar=1 WHERE username='doctor003';
UPDATE users SET fname='Daniela',   lname='Cardenas', email='daniela.cardenas@emailpaciente.com',  calendar=1 WHERE username='doctor004';
UPDATE users SET fname='Fernando',  lname='Cabrera',  email='fernando.cabrera@emailpaciente.com',  calendar=1 WHERE username='doctor005';


-- ============================================================
-- D. users_secure — provider passwords
-- ============================================================
-- users_secure.id must equal users.id (looked up via subquery so
-- this works regardless of the AUTO_INCREMENT value assigned).
-- last_update_password = NOW() bypasses the password-expiration
-- prompt (globals.password_expiration_days = 180).

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', NOW()
FROM users u
WHERE u.username = 'doctor001'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'doctor001');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', NOW()
FROM users u
WHERE u.username = 'doctor002'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'doctor002');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', NOW()
FROM users u
WHERE u.username = 'doctor003'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'doctor003');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', NOW()
FROM users u
WHERE u.username = 'doctor004'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'doctor004');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$o5wzw0JcLkRnv9N6QQK5i.rJQL6BKjsf4Yb2pFDy0ieAjySf3l5Cy', NOW()
FROM users u
WHERE u.username = 'doctor005'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'doctor005');


-- ============================================================
-- E. groups — auth-group membership (UserService::getAuthGroupForUser)
-- ============================================================
-- The login flow requires a row in `groups` whose `user` column
-- matches the username. The convention (seen on the admin row) is
-- name='Default' regardless of role; the actual role distinction
-- lives in the gacl_* rows below.

INSERT INTO groups (name, user)
SELECT 'Default', 'doctor001'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'doctor001');

INSERT INTO groups (name, user)
SELECT 'Default', 'doctor002'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'doctor002');

INSERT INTO groups (name, user)
SELECT 'Default', 'doctor003'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'doctor003');

INSERT INTO groups (name, user)
SELECT 'Default', 'doctor004'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'doctor004');

INSERT INTO groups (name, user)
SELECT 'Default', 'doctor005'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'doctor005');


-- ============================================================
-- F. gacl_aro — phpGACL identity for each doctor
-- ============================================================
-- gacl_aro.id has no AUTO_INCREMENT in the stock schema (default 0).
-- phpGACL maintains gacl_aro_seq as the next-ID allocator. We use
-- the same MAX(id)+1 derived-table pattern as patient_data so the
-- five doctor AROs land on contiguous ids right after whatever is
-- already there, then sync gacl_aro_seq to the new MAX(gacl_aro.id)
-- so phpGACL's own allocator stays consistent when an admin later
-- creates a user via the UI. Idempotency guard is on the natural
-- key (section_value, value). order_value=10 matches admin's
-- convention.

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'doctor001', 10, 'Alejandro Fuentes', 0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'doctor001');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'doctor002', 10, 'Carolina Salazar',  0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'doctor002');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'doctor003', 10, 'Ricardo Benitez',   0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'doctor003');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'doctor004', 10, 'Daniela Cardenas',  0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'doctor004');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'doctor005', 10, 'Fernando Cabrera',  0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'doctor005');

-- Sync the ARO display name for any sample doctors that already
-- exist from a previous run.
UPDATE gacl_aro SET name='Alejandro Fuentes' WHERE section_value='users' AND value='doctor001';
UPDATE gacl_aro SET name='Carolina Salazar'  WHERE section_value='users' AND value='doctor002';
UPDATE gacl_aro SET name='Ricardo Benitez'   WHERE section_value='users' AND value='doctor003';
UPDATE gacl_aro SET name='Daniela Cardenas'  WHERE section_value='users' AND value='doctor004';
UPDATE gacl_aro SET name='Fernando Cabrera'  WHERE section_value='users' AND value='doctor005';

-- Keep phpGACL's allocator aligned with the new MAX(gacl_aro.id).
-- Only advances forward; never lowers the seq.
UPDATE gacl_aro_seq s,
       (SELECT MAX(id) AS m FROM gacl_aro) g
SET    s.id = g.m
WHERE  s.id < g.m;


-- ============================================================
-- G. gacl_groups_aro_map — doctor → Physicians group membership
-- ============================================================
-- group_id = 13 -> 'Physicians' (seeded by the install in
-- gacl_aro_groups). phpGACL's get_object_groups() reads this table
-- at login time to discover the doctor's ACL group.

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'doctor001'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'doctor002'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'doctor003'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'doctor004'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'doctor005'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);
