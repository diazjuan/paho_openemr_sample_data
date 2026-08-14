-- ============================================================
-- PAHO - Sample Data Loader (OPS regional data set)
-- OpenEMR 8.0.0.2
-- ============================================================
--
-- Creates:
--   * 100 sample patients (pubpid PAHO-OPS-PATIENT-001..100)
--     with portal logins ops001..ops100. Each missing patient is
--     assigned the next normal pid via (SELECT COALESCE(MAX(pid),0)+1
--     FROM patient_data) so that OpenEMR's "Add Patient" form (which
--     uses MAX(pid)+1) continues to allocate contiguous pids for
--     real patients added later.
--   * 10 sample doctors/providers (username opsdoc01..opsdoc10)
--     wired into the Physicians ACL group so they can log in to the
--     OpenEMR admin UI and see their calendar/agenda. Each is set
--     calendar=1 so they appear as schedulable providers in the
--     calendar (the provider dropdown filters on authorized=1 AND
--     calendar=1; see UserService::searchUsersForCalendar).
--     Every patient's providerID and referrer name point at one of
--     these doctors, so the demo data is self consistent.
--   * 10 insurance carriers, 2 X12 partners, and 3 insurance rows
--     per patient (primary, secondary, tertiary). Subscriber details
--     mirror the patient, because every relationship is 'self'.
--
-- Data locale:
--   Names, addresses, phone numbers, national IDs and ethnicity
--   values are Latin American. The country is the fictional 'OPS',
--   so no real city, carrier or national ID scheme is reproduced.
--
-- Password for every sample user, patients and doctors alike:
--   0p3n3MR2026!
-- Stored as a pre-computed bcrypt hash (cost 12) generated and
-- verified against the same OpenEMR install. No plaintext anywhere.
--
-- Idempotency:
--   Every INSERT is guarded by a NOT EXISTS check on a natural key
--   (pubpid, portal_login_username, users.username, gacl_aro.value,
--   insurance_companies.name, x12_partners.name, the pair
--   (insurance_data.pid, type), and the map (group_id, aro_id)).
--   Safe to run repeatedly. Real records are never touched.
--   Foreign keys are resolved by subquery, never hardcoded, so the
--   script is correct whatever ids the database already holds.
--
-- Restrictions (verified - none violated):
--   No CREATE, ALTER, DROP, TRUNCATE, DELETE, REPLACE.
--   No changes to `globals` or any configuration table.
--   No encounters, appointments, billing, prescriptions, clinical
--   notes, documents, or translations.
-- ============================================================


-- ============================================================
-- A. users - sample doctors
-- ============================================================
-- users.id is AUTO_INCREMENT, so we omit it. Idempotency guard is
-- on username (BINARY-compared at login). authorized=1 marks the
-- user as a clinician; active=1 lets login proceed; calendar=1 makes
-- the provider show up in the calendar's schedulable-provider list.

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'opsdoc01', 'Carolina', 'Salazar Fuentes', 'carolina.salazar@correo.ops', 1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'opsdoc01');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'opsdoc02', 'Ricardo', 'Benítez Cabrera', 'ricardo.benitez@correo.ops', 1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'opsdoc02');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'opsdoc03', 'Daniela', 'Cárdenas Rojas', 'daniela.cardenas@correo.ops', 1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'opsdoc03');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'opsdoc04', 'Fernando', 'Cabrera Medina', 'fernando.cabrera@correo.ops', 1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'opsdoc04');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'opsdoc05', 'Alejandra', 'Fuentes Navarro', 'alejandra.fuentes@correo.ops', 1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'opsdoc05');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'opsdoc06', 'Alejandro', 'Paredes Vargas', 'alejandro.paredes@correo.ops', 1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'opsdoc06');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'opsdoc07', 'Verónica', 'Miranda Acosta', 'veronica.miranda@correo.ops', 1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'opsdoc07');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'opsdoc08', 'Esteban', 'Quispe Herrera', 'esteban.quispe@correo.ops', 1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'opsdoc08');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'opsdoc09', 'Gabriela', 'Escobar Silva', 'gabriela.escobar@correo.ops', 1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'opsdoc09');

INSERT INTO users (username, fname, lname, email, authorized, active, calendar, facility_id)
SELECT 'opsdoc10', 'Mauricio', 'Villalobos Campos', 'mauricio.villalobos@correo.ops', 1, 1, 1, 3
WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'opsdoc10');

-- Sync names for doctors that already exist from a previous run.
UPDATE users SET fname='Carolina', lname='Salazar Fuentes', email='carolina.salazar@correo.ops', calendar=1 WHERE username='opsdoc01';
UPDATE users SET fname='Ricardo', lname='Benítez Cabrera', email='ricardo.benitez@correo.ops', calendar=1 WHERE username='opsdoc02';
UPDATE users SET fname='Daniela', lname='Cárdenas Rojas', email='daniela.cardenas@correo.ops', calendar=1 WHERE username='opsdoc03';
UPDATE users SET fname='Fernando', lname='Cabrera Medina', email='fernando.cabrera@correo.ops', calendar=1 WHERE username='opsdoc04';
UPDATE users SET fname='Alejandra', lname='Fuentes Navarro', email='alejandra.fuentes@correo.ops', calendar=1 WHERE username='opsdoc05';
UPDATE users SET fname='Alejandro', lname='Paredes Vargas', email='alejandro.paredes@correo.ops', calendar=1 WHERE username='opsdoc06';
UPDATE users SET fname='Verónica', lname='Miranda Acosta', email='veronica.miranda@correo.ops', calendar=1 WHERE username='opsdoc07';
UPDATE users SET fname='Esteban', lname='Quispe Herrera', email='esteban.quispe@correo.ops', calendar=1 WHERE username='opsdoc08';
UPDATE users SET fname='Gabriela', lname='Escobar Silva', email='gabriela.escobar@correo.ops', calendar=1 WHERE username='opsdoc09';
UPDATE users SET fname='Mauricio', lname='Villalobos Campos', email='mauricio.villalobos@correo.ops', calendar=1 WHERE username='opsdoc10';


-- ============================================================
-- B. users_secure - provider passwords
-- ============================================================
-- users_secure.id must equal users.id (looked up via subquery so
-- this works regardless of the AUTO_INCREMENT value assigned).
-- last_update_password = NOW() bypasses the password-expiration
-- prompt (globals.password_expiration_days = 180).

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', NOW()
FROM users u
WHERE u.username = 'opsdoc01'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'opsdoc01');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', NOW()
FROM users u
WHERE u.username = 'opsdoc02'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'opsdoc02');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', NOW()
FROM users u
WHERE u.username = 'opsdoc03'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'opsdoc03');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', NOW()
FROM users u
WHERE u.username = 'opsdoc04'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'opsdoc04');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', NOW()
FROM users u
WHERE u.username = 'opsdoc05'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'opsdoc05');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', NOW()
FROM users u
WHERE u.username = 'opsdoc06'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'opsdoc06');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', NOW()
FROM users u
WHERE u.username = 'opsdoc07'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'opsdoc07');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', NOW()
FROM users u
WHERE u.username = 'opsdoc08'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'opsdoc08');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', NOW()
FROM users u
WHERE u.username = 'opsdoc09'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'opsdoc09');

INSERT INTO users_secure (id, username, password, last_update_password)
SELECT u.id, u.username, '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', NOW()
FROM users u
WHERE u.username = 'opsdoc10'
  AND NOT EXISTS (SELECT 1 FROM users_secure WHERE username = 'opsdoc10');


-- ============================================================
-- C. groups - auth-group membership
-- ============================================================
-- The login flow requires a row in `groups` whose `user` column
-- matches the username. name='Default' matches the admin row; the
-- role distinction lives in the gacl_* rows below.

INSERT INTO groups (name, user)
SELECT 'Default', 'opsdoc01'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'opsdoc01');

INSERT INTO groups (name, user)
SELECT 'Default', 'opsdoc02'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'opsdoc02');

INSERT INTO groups (name, user)
SELECT 'Default', 'opsdoc03'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'opsdoc03');

INSERT INTO groups (name, user)
SELECT 'Default', 'opsdoc04'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'opsdoc04');

INSERT INTO groups (name, user)
SELECT 'Default', 'opsdoc05'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'opsdoc05');

INSERT INTO groups (name, user)
SELECT 'Default', 'opsdoc06'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'opsdoc06');

INSERT INTO groups (name, user)
SELECT 'Default', 'opsdoc07'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'opsdoc07');

INSERT INTO groups (name, user)
SELECT 'Default', 'opsdoc08'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'opsdoc08');

INSERT INTO groups (name, user)
SELECT 'Default', 'opsdoc09'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'opsdoc09');

INSERT INTO groups (name, user)
SELECT 'Default', 'opsdoc10'
WHERE NOT EXISTS (SELECT 1 FROM groups WHERE user = 'opsdoc10');


-- ============================================================
-- D. gacl_aro - phpGACL identity for each doctor
-- ============================================================
-- gacl_aro.id has no AUTO_INCREMENT in the stock schema. phpGACL
-- maintains gacl_aro_seq as the next-ID allocator, so we use the
-- MAX(id)+1 derived-table pattern and then advance the sequence.
-- Idempotency guard is the natural key (section_value, value).

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'opsdoc01', 10, 'Carolina Salazar Fuentes', 0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'opsdoc01');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'opsdoc02', 10, 'Ricardo Benítez Cabrera', 0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'opsdoc02');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'opsdoc03', 10, 'Daniela Cárdenas Rojas', 0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'opsdoc03');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'opsdoc04', 10, 'Fernando Cabrera Medina', 0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'opsdoc04');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'opsdoc05', 10, 'Alejandra Fuentes Navarro', 0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'opsdoc05');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'opsdoc06', 10, 'Alejandro Paredes Vargas', 0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'opsdoc06');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'opsdoc07', 10, 'Verónica Miranda Acosta', 0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'opsdoc07');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'opsdoc08', 10, 'Esteban Quispe Herrera', 0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'opsdoc08');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'opsdoc09', 10, 'Gabriela Escobar Silva', 0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'opsdoc09');

INSERT INTO gacl_aro (id, section_value, value, order_value, name, hidden)
SELECT next_aro.np, 'users', 'opsdoc10', 10, 'Mauricio Villalobos Campos', 0
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM gacl_aro) next_aro
WHERE NOT EXISTS (SELECT 1 FROM gacl_aro WHERE section_value = 'users' AND value = 'opsdoc10');

-- Sync the ARO display name for doctors from a previous run.
UPDATE gacl_aro SET name='Carolina Salazar Fuentes' WHERE section_value='users' AND value='opsdoc01';
UPDATE gacl_aro SET name='Ricardo Benítez Cabrera' WHERE section_value='users' AND value='opsdoc02';
UPDATE gacl_aro SET name='Daniela Cárdenas Rojas' WHERE section_value='users' AND value='opsdoc03';
UPDATE gacl_aro SET name='Fernando Cabrera Medina' WHERE section_value='users' AND value='opsdoc04';
UPDATE gacl_aro SET name='Alejandra Fuentes Navarro' WHERE section_value='users' AND value='opsdoc05';
UPDATE gacl_aro SET name='Alejandro Paredes Vargas' WHERE section_value='users' AND value='opsdoc06';
UPDATE gacl_aro SET name='Verónica Miranda Acosta' WHERE section_value='users' AND value='opsdoc07';
UPDATE gacl_aro SET name='Esteban Quispe Herrera' WHERE section_value='users' AND value='opsdoc08';
UPDATE gacl_aro SET name='Gabriela Escobar Silva' WHERE section_value='users' AND value='opsdoc09';
UPDATE gacl_aro SET name='Mauricio Villalobos Campos' WHERE section_value='users' AND value='opsdoc10';

-- Keep phpGACL's allocator aligned with the new MAX(gacl_aro.id).
-- Only advances forward; never lowers the seq.
UPDATE gacl_aro_seq s,
       (SELECT MAX(id) AS m FROM gacl_aro) g
SET    s.id = g.m
WHERE  s.id < g.m;


-- ============================================================
-- E. gacl_groups_aro_map - doctor to Physicians group
-- ============================================================
-- group_id = 13 -> 'Physicians', seeded by the install in
-- gacl_aro_groups. phpGACL reads this at login to discover the
-- doctor's ACL group.

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'opsdoc01'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'opsdoc02'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'opsdoc03'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'opsdoc04'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'opsdoc05'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'opsdoc06'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'opsdoc07'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'opsdoc08'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'opsdoc09'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);

INSERT INTO gacl_groups_aro_map (group_id, aro_id)
SELECT 13, a.id
FROM gacl_aro a
WHERE a.section_value = 'users' AND a.value = 'opsdoc10'
  AND NOT EXISTS (SELECT 1 FROM gacl_groups_aro_map m WHERE m.group_id = 13 AND m.aro_id = a.id);


-- ============================================================
-- F. patient_data - sample patients
-- ============================================================
-- Each missing patient is assigned the next available pid via
-- (SELECT COALESCE(MAX(pid), 0) + 1 FROM patient_data), the same
-- allocation rule OpenEMR's "Add Patient" form uses, so pid
-- numbering stays contiguous. Idempotency guard is on pubpid.
-- providerID resolves the doctor by username, so it is correct
-- whatever AUTO_INCREMENT value section A produced.
-- allow_patient_portal='YES' enables portal access for everyone.

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-001', 'Srta.', 'Spanish', 'María Elena', 'Bustamante Vega', '', '1932-5-22', 'Female', 'Av. Independencia 2569', 'Punta Serena', 'Costa Sur', '10916', 'OPS', '(03) 3114-8954', '(03) 3114-8954', '(03) 3114-8954', '(9) 6516-2807', 'maria.bustamante@correo.ops', '62197530', 'L776257231', 'single', 'Friend', 'Mestizo', '8', '5905', '2003-11-17 12:06:00', 'Dra. Carolina Salazar Fuentes', (SELECT id FROM users WHERE username = 'opsdoc01'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-001');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-002', 'Srta.', 'Spanish', 'Elena', 'Moreno Sánchez', '', '1931-6-4', 'Female', 'Calle Sucre 3168', 'San Cristóbal', 'Costa Sur', '60317', 'OPS', '(06) 4877-6762', '(06) 4877-6762', '(06) 4877-6762', '(9) 1590-6329', 'elena.moreno@correo.ops', '41856149', 'L257467495', 'single', 'Friend', 'Indígena', '5', '7677', '2003-11-17 12:06:00', 'Dr. Ricardo Benítez Cabrera', (SELECT id FROM users WHERE username = 'opsdoc02'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-002');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-003', 'Srta.', 'Spanish', 'Carmen Beatriz', 'Bustamante García', '', '2007-5-22', 'Female', 'Calle Colón 4940', 'San Rafael', 'Norte', '61621', 'OPS', '(04) 3002-3325', '(04) 3002-3325', '(04) 3002-3325', '(9) 2097-9823', 'carmen.bustamante@correo.ops', '53183612', 'L611934816', 'single', 'Friend', 'Blanco', '7', '2574', '2003-11-17 12:06:00', 'Dra. Daniela Cárdenas Rojas', (SELECT id FROM users WHERE username = 'opsdoc03'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-003');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-004', 'Sra.', 'Spanish', 'Consuelo Fernanda', 'Delgado Fuentes', '', '1973-8-5', 'Female', 'Jr. Bolívar 2651', 'Valle Verde', 'Valle', '63941', 'OPS', '(05) 6691-5235', '(05) 6691-5235', '(05) 6691-5235', '(9) 9037-5254', 'consuelo.delgado@correo.ops', '90897683', 'L902551298', 'married', 'Friend', 'Mestizo', '6', '2504', '2003-11-17 12:06:00', 'Dr. Fernando Cabrera Medina', (SELECT id FROM users WHERE username = 'opsdoc04'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-004');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-005', 'Srta.', 'Spanish', 'Elena', 'Ortiz Vega', '', '2003-2-11', 'Female', 'Carrera 62 No. 97-14', 'Nueva Aurora', 'Oriente', '59982', 'OPS', '(09) 3705-9765', '(09) 3705-9765', '(09) 3705-9765', '(9) 3301-4323', 'elena.ortiz@correo.ops', '40663282', 'L106268982', 'single', 'Friend', 'Blanco', '10', '3337', '2003-11-17 12:06:00', 'Dra. Alejandra Fuentes Navarro', (SELECT id FROM users WHERE username = 'opsdoc05'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-005');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-006', 'Sra.', 'Spanish', 'Marcela Fernanda', 'Ramírez Gutiérrez', '', '1965-6-9', 'Female', 'Av. Libertador 2092', 'San Rafael', 'Norte', '77317', 'OPS', '(03) 6521-8482', '(03) 6521-8482', '(03) 6521-8482', '(9) 1058-9909', 'marcela.ramirez@correo.ops', '11171765', 'L182143064', 'married', 'Friend', 'Afrodescendiente', '9', '3863', '2003-11-17 12:06:00', 'Dr. Alejandro Paredes Vargas', (SELECT id FROM users WHERE username = 'opsdoc06'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-006');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-007', 'Sr.', 'Spanish', 'Emilio', 'Campos Ramos', '', '2010-11-6', 'Male', 'Av. Central 3142', 'Ciudad Bolívar', 'Norte', '31963', 'OPS', '(08) 6031-1495', '(08) 6031-1495', '(08) 6031-1495', '(9) 4912-1936', 'emilio.campos@correo.ops', '94749844', 'L922302233', 'single', 'Friend', 'Afrodescendiente', '4', '4207', '2003-11-17 12:06:00', 'Dra. Verónica Miranda Acosta', (SELECT id FROM users WHERE username = 'opsdoc07'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-007');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-008', 'Sr.', 'Spanish', 'Tomás Alberto', 'Contreras Silva', '', '1967-11-15', 'Male', 'Jr. Bolívar 4404', 'Puerto Alegre', 'Litoral', '21540', 'OPS', '(07) 3080-4628', '(07) 3080-4628', '(07) 3080-4628', '(9) 8516-4535', 'tomas.contreras@correo.ops', '85104216', 'L370011259', 'married', 'Friend', 'Asiático', '9', '8201', '2003-11-17 12:06:00', 'Dr. Esteban Quispe Herrera', (SELECT id FROM users WHERE username = 'opsdoc08'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-008');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-009', 'Srta.', 'Spanish', 'Ángela Fernanda', 'Cárdenas Álvarez', '', '1997-1-21', 'Female', 'Calle Sucre 3170', 'Santa Lucía', 'Central', '31034', 'OPS', '(06) 8396-7209', '(06) 8396-7209', '(06) 8396-7209', '(9) 3550-1943', 'angela.cardenas@correo.ops', '71471851', 'L429684889', 'single', 'Friend', 'Blanco', '0', '1463', '2003-11-17 12:06:00', 'Dra. Gabriela Escobar Silva', (SELECT id FROM users WHERE username = 'opsdoc09'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-009');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-010', 'Sra.', 'Spanish', 'Adriana Isabel', 'Cárdenas Gutiérrez', '', '1974-3-27', 'Female', 'Av. San Martín 4552', 'Villa Nueva', 'Litoral', '39833', 'OPS', '(02) 6326-2303', '(02) 6326-2303', '(02) 6326-2303', '(9) 8506-1668', 'adriana.cardenas@correo.ops', '65237414', 'L704231060', 'married', 'Friend', 'Mestizo', '5', '7274', '2003-11-17 12:06:00', 'Dr. Mauricio Villalobos Campos', (SELECT id FROM users WHERE username = 'opsdoc10'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-010');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-011', 'Sr.', 'Spanish', 'José Enrique', 'Ramos Herrera', '', '2009-6-27', 'Male', 'Calle 72 No. 64-16', 'Valle Verde', 'Valle', '10790', 'OPS', '(05) 3381-8171', '(05) 3381-8171', '(05) 3381-8171', '(9) 3793-4505', 'jose.ramos@correo.ops', '78418567', 'L398144293', 'single', 'Friend', 'Blanco', '4', '8586', '2003-11-17 12:06:00', 'Dra. Carolina Salazar Fuentes', (SELECT id FROM users WHERE username = 'opsdoc01'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-011');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-012', 'Srta.', 'Spanish', 'Teresa', 'Jiménez López', '', '1939-5-9', 'Female', 'Calle Sucre 2975', 'Santa Lucía', 'Central', '26882', 'OPS', '(08) 6850-5864', '(08) 6850-5864', '(08) 6850-5864', '(9) 6616-5237', 'teresa.jimenez@correo.ops', '40326096', 'L768863239', 'single', 'Friend', 'Asiático', '0', '783', '2003-11-17 12:06:00', 'Dr. Ricardo Benítez Cabrera', (SELECT id FROM users WHERE username = 'opsdoc02'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-012');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-013', 'Srta.', 'Spanish', 'Fernanda Isabel', 'Rodríguez Núñez', '', '1988-1-11', 'Female', 'Calle Colón 3805', 'Villa Nueva', 'Litoral', '50067', 'OPS', '(05) 5775-8374', '(05) 5775-8374', '(05) 5775-8374', '(9) 8326-6662', 'fernanda.rodriguez@correo.ops', '16238184', 'L884769450', 'single', 'Friend', 'Mulato', '0', '3216', '2003-11-17 12:06:00', 'Dra. Daniela Cárdenas Rojas', (SELECT id FROM users WHERE username = 'opsdoc03'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-013');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-014', 'Sr.', 'Spanish', 'Óscar', 'Herrera Romero', '', '1934-11-18', 'Male', 'Av. Las Américas 4152', 'San Cristóbal', 'Costa Sur', '71102', 'OPS', '(09) 7664-8410', '(09) 7664-8410', '(09) 7664-8410', '(9) 9584-6320', 'oscar.herrera@correo.ops', '40744850', 'L142254072', 'married', 'Friend', 'Indígena', '3', '7324', '2003-11-17 12:06:00', 'Dr. Fernando Cabrera Medina', (SELECT id FROM users WHERE username = 'opsdoc04'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-014');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-015', 'Srta.', 'Spanish', 'Julia Fernanda', 'Flores Guerrero', '', '1989-3-4', 'Female', 'Calle 94 No. 23-68', 'La Esperanza', 'Oriente', '31660', 'OPS', '(06) 7523-5159', '(06) 7523-5159', '(06) 7523-5159', '(9) 6818-7294', 'julia.flores@correo.ops', '70640090', 'L557821655', 'single', 'Friend', 'Indígena', '0', '1779', '2003-11-17 12:06:00', 'Dra. Alejandra Fuentes Navarro', (SELECT id FROM users WHERE username = 'opsdoc05'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-015');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-016', 'Sr.', 'Spanish', 'Felipe Enrique', 'Sánchez Guerrero', '', '1967-9-25', 'Male', 'Calle 12 No. 20-95', 'Valle Verde', 'Valle', '42874', 'OPS', '(09) 5290-4223', '(09) 5290-4223', '(09) 5290-4223', '(9) 2623-9638', 'felipe.sanchez@correo.ops', '55792334', 'L865938298', 'married', 'Friend', 'Mestizo', '9', '763', '2003-11-17 12:06:00', 'Dr. Alejandro Paredes Vargas', (SELECT id FROM users WHERE username = 'opsdoc06'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-016');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-017', 'Sra.', 'Spanish', 'Silvia Cristina', 'Sandoval Acosta', '', '1942-6-26', 'Female', 'Jr. Bolívar 4404', 'Santa Lucía', 'Central', '11730', 'OPS', '(09) 8938-7508', '(09) 8938-7508', '(09) 8938-7508', '(9) 2384-3054', 'silvia.sandoval@correo.ops', '91456339', 'L159026706', 'married', 'Friend', 'Afrodescendiente', '0', '510', '2003-11-17 12:06:00', 'Dra. Verónica Miranda Acosta', (SELECT id FROM users WHERE username = 'opsdoc07'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-017');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-018', 'Sra.', 'Spanish', 'Daniela Victoria', 'Miranda Romero', '', '1933-8-21', 'Female', 'Av. Independencia 2624', 'Ciudad Bolívar', 'Norte', '29974', 'OPS', '(03) 5814-1311', '(03) 5814-1311', '(03) 5814-1311', '(9) 5064-5829', 'daniela.miranda@correo.ops', '30831629', 'L684566553', 'married', 'Friend', 'Mulato', '4', '3834', '2003-11-17 12:06:00', 'Dr. Esteban Quispe Herrera', (SELECT id FROM users WHERE username = 'opsdoc08'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-018');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-019', 'Sr.', 'Spanish', 'Jorge Antonio', 'Vargas Molina', '', '1930-4-25', 'Male', 'Carrera 5 No. 53-96', 'Ciudad Bolívar', 'Norte', '12910', 'OPS', '(03) 2086-9338', '(03) 2086-9338', '(03) 2086-9338', '(9) 5803-8975', 'jorge.vargas@correo.ops', '73674143', 'L633856986', 'single', 'Friend', 'Afrodescendiente', '0', '2858', '2003-11-17 12:06:00', 'Dra. Gabriela Escobar Silva', (SELECT id FROM users WHERE username = 'opsdoc09'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-019');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-020', 'Srta.', 'Spanish', 'Valentina del Carmen', 'Vega Hernández', '', '1948-11-12', 'Female', 'Jr. Bolívar 4908', 'La Esperanza', 'Oriente', '24778', 'OPS', '(06) 2331-4849', '(06) 2331-4849', '(06) 2331-4849', '(9) 6095-1757', 'valentina.vega@correo.ops', '75545029', 'L118095513', 'single', 'Friend', 'Afrodescendiente', '5', '1953', '2003-11-17 12:06:00', 'Dr. Mauricio Villalobos Campos', (SELECT id FROM users WHERE username = 'opsdoc10'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-020');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-021', 'Srta.', 'Spanish', 'Daniela del Carmen', 'Romero Molina', '', '1937-8-14', 'Female', 'Pasaje Las Palmas 1648', 'Santa Lucía', 'Central', '60841', 'OPS', '(06) 7283-2637', '(06) 7283-2637', '(06) 7283-2637', '(9) 1604-7014', 'daniela.romero@correo.ops', '95448467', 'L223862958', 'single', 'Friend', 'Mestizo', '7', '3701', '2003-11-17 12:06:00', 'Dra. Carolina Salazar Fuentes', (SELECT id FROM users WHERE username = 'opsdoc01'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-021');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-022', 'Srta.', 'Spanish', 'Rosa', 'Aguilar Ramos', '', '1935-10-16', 'Female', 'Pasaje Las Palmas 3426', 'Nueva Aurora', 'Oriente', '62756', 'OPS', '(02) 2182-2269', '(02) 2182-2269', '(02) 2182-2269', '(9) 8339-5599', 'rosa.aguilar@correo.ops', '31485237', 'L903410047', 'single', 'Friend', 'Indígena', '7', '8710', '2003-11-17 12:06:00', 'Dr. Ricardo Benítez Cabrera', (SELECT id FROM users WHERE username = 'opsdoc02'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-022');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-023', 'Srta.', 'Spanish', 'Raquel Elena', 'Gómez Hernández', '', '1966-6-26', 'Female', 'Av. San Martín 1529', 'Villa Nueva', 'Litoral', '17929', 'OPS', '(05) 5771-5900', '(05) 5771-5900', '(05) 5771-5900', '(9) 1108-6994', 'raquel.gomez@correo.ops', '31227397', 'L313818795', 'single', 'Friend', 'Asiático', '0', '7876', '2003-11-17 12:06:00', 'Dra. Daniela Cárdenas Rojas', (SELECT id FROM users WHERE username = 'opsdoc03'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-023');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-024', 'Sr.', 'Spanish', 'Juan', 'Moreno Torres', '', '1978-4-22', 'Male', 'Calle Colón 632', 'Villa Nueva', 'Litoral', '18029', 'OPS', '(02) 6949-3827', '(02) 6949-3827', '(02) 6949-3827', '(9) 5577-2933', 'juan.moreno@correo.ops', '21967648', 'L785313613', 'married', 'Friend', 'Mestizo', '2', '8065', '2003-11-17 12:06:00', 'Dr. Fernando Cabrera Medina', (SELECT id FROM users WHERE username = 'opsdoc04'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-024');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-025', 'Sr.', 'Spanish', 'Tomás', 'Miranda Cruz', '', '1964-2-21', 'Male', 'Av. Libertador 3821', 'Villa Nueva', 'Litoral', '76872', 'OPS', '(08) 7989-8883', '(08) 7989-8883', '(08) 7989-8883', '(9) 2198-2519', 'tomas.miranda@correo.ops', '67949190', 'L651956499', 'married', 'Friend', 'Mulato', '4', '4114', '2003-11-17 12:06:00', 'Dra. Alejandra Fuentes Navarro', (SELECT id FROM users WHERE username = 'opsdoc05'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-025');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-026', 'Sr.', 'Spanish', 'Julián Ramón', 'Mendoza Navarro', '', '1976-4-9', 'Male', 'Av. San Martín 3572', 'Nueva Aurora', 'Oriente', '68366', 'OPS', '(04) 5366-5532', '(04) 5366-5532', '(04) 5366-5532', '(9) 8857-9192', 'julian.mendoza@correo.ops', '13519970', 'L998735457', 'married', 'Friend', 'Blanco', '6', '2977', '2003-11-17 12:06:00', 'Dr. Alejandro Paredes Vargas', (SELECT id FROM users WHERE username = 'opsdoc06'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-026');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-027', 'Sra.', 'Spanish', 'Dolores Victoria', 'Rivera Gómez', '', '1961-2-19', 'Female', 'Av. San Martín 4390', 'Valle Verde', 'Valle', '61797', 'OPS', '(02) 4161-5268', '(02) 4161-5268', '(02) 4161-5268', '(9) 3579-3483', 'dolores.rivera@correo.ops', '89811953', 'L834318704', 'married', 'Friend', 'Blanco', '9', '8432', '2003-11-17 12:06:00', 'Dra. Verónica Miranda Acosta', (SELECT id FROM users WHERE username = 'opsdoc07'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-027');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-028', 'Srta.', 'Spanish', 'María de los Ángeles', 'Martínez Miranda', '', '1989-3-4', 'Female', 'Pasaje Las Palmas 4206', 'Ciudad Bolívar', 'Norte', '59364', 'OPS', '(05) 3754-7723', '(05) 3754-7723', '(05) 3754-7723', '(9) 9513-9412', 'maria.martinez@correo.ops', '12253329', 'L919149005', 'single', 'Friend', 'Blanco', '0', '7338', '2003-11-17 12:06:00', 'Dr. Esteban Quispe Herrera', (SELECT id FROM users WHERE username = 'opsdoc08'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-028');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-029', 'Sr.', 'Spanish', 'Eduardo Antonio', 'Paredes Fuentes', '', '1970-8-7', 'Male', 'Calle Los Pinos 1123', 'Nueva Aurora', 'Oriente', '45400', 'OPS', '(05) 7824-3094', '(05) 7824-3094', '(05) 7824-3094', '(9) 7573-9569', 'eduardo.paredes@correo.ops', '78289270', 'L283016192', 'single', 'Friend', 'Mestizo', '10', '2538', '2003-11-17 12:06:00', 'Dra. Gabriela Escobar Silva', (SELECT id FROM users WHERE username = 'opsdoc09'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-029');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-030', 'Sr.', 'Spanish', 'Andrés Alberto', 'Flores Peña', '', '1970-5-19', 'Male', 'Jr. Bolívar 2233', 'Villa Nueva', 'Litoral', '28539', 'OPS', '(04) 7625-4027', '(04) 7625-4027', '(04) 7625-4027', '(9) 7184-1545', 'andres.flores@correo.ops', '16929162', 'L767633247', 'single', 'Friend', 'Asiático', '7', '6437', '2003-11-17 12:06:00', 'Dr. Mauricio Villalobos Campos', (SELECT id FROM users WHERE username = 'opsdoc10'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-030');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-031', 'Sra.', 'Spanish', 'Ana Isabel', 'Rojas Navarro', '', '1985-1-10', 'Female', 'Av. San Martín 4630', 'Puerto Alegre', 'Litoral', '53044', 'OPS', '(08) 5882-8958', '(08) 5882-8958', '(08) 5882-8958', '(9) 3348-9522', 'ana.rojas@correo.ops', '74913182', 'L961290248', 'married', 'Friend', 'Afrodescendiente', '1', '7597', '2003-11-17 12:06:00', 'Dra. Carolina Salazar Fuentes', (SELECT id FROM users WHERE username = 'opsdoc01'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-031');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-032', 'Sra.', 'Spanish', 'Adriana Victoria', 'Flores Moreno', '', '1956-1-18', 'Female', 'Av. San Martín 3665', 'Villa Nueva', 'Litoral', '23489', 'OPS', '(07) 7438-7568', '(07) 7438-7568', '(07) 7438-7568', '(9) 1566-5051', 'adriana.flores@correo.ops', '99268762', 'L213720019', 'married', 'Friend', 'Afrodescendiente', '7', '7836', '2003-11-17 12:06:00', 'Dr. Ricardo Benítez Cabrera', (SELECT id FROM users WHERE username = 'opsdoc02'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-032');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-033', 'Sr.', 'Spanish', 'Emilio', 'García Rodríguez', '', '1930-6-10', 'Male', 'Pasaje Las Palmas 732', 'Santa Lucía', 'Central', '65764', 'OPS', '(04) 3547-2812', '(04) 3547-2812', '(04) 3547-2812', '(9) 3675-9478', 'emilio.garcia@correo.ops', '49854185', 'L720192488', 'single', 'Friend', 'Blanco', '4', '5513', '2003-11-17 12:06:00', 'Dra. Daniela Cárdenas Rojas', (SELECT id FROM users WHERE username = 'opsdoc03'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-033');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-034', 'Srta.', 'Spanish', 'Esperanza de los Ángeles', 'Moreno Molina', '', '1943-6-18', 'Female', 'Av. Las Américas 1240', 'Punta Serena', 'Costa Sur', '29555', 'OPS', '(02) 5067-1179', '(02) 5067-1179', '(02) 5067-1179', '(9) 7687-5188', 'esperanza.moreno@correo.ops', '24833333', 'L301669364', 'single', 'Friend', 'Indígena', '5', '4529', '2003-11-17 12:06:00', 'Dr. Fernando Cabrera Medina', (SELECT id FROM users WHERE username = 'opsdoc04'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-034');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-035', 'Sra.', 'Spanish', 'Verónica', 'Sánchez Campos', '', '1972-11-17', 'Female', 'Av. Central 685', 'Punta Serena', 'Costa Sur', '13387', 'OPS', '(04) 9954-8510', '(04) 9954-8510', '(04) 9954-8510', '(9) 9779-5730', 'veronica.sanchez@correo.ops', '39346430', 'L970315640', 'married', 'Friend', 'Mestizo', '0', '9365', '2003-11-17 12:06:00', 'Dra. Alejandra Fuentes Navarro', (SELECT id FROM users WHERE username = 'opsdoc05'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-035');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-036', 'Sra.', 'Spanish', 'Valentina Victoria', 'González Campos', '', '1944-7-19', 'Female', 'Av. Independencia 4506', 'Santa Lucía', 'Central', '51967', 'OPS', '(06) 5548-6362', '(06) 5548-6362', '(06) 5548-6362', '(9) 3342-2918', 'valentina.gonzalez@correo.ops', '78845536', 'L689518131', 'married', 'Friend', 'Indígena', '10', '8684', '2003-11-17 12:06:00', 'Dr. Alejandro Paredes Vargas', (SELECT id FROM users WHERE username = 'opsdoc06'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-036');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-037', 'Srta.', 'Spanish', 'Daniela del Carmen', 'Moreno Castillo', '', '1992-9-10', 'Female', 'Av. Independencia 811', 'San Cristóbal', 'Costa Sur', '33782', 'OPS', '(08) 2919-8141', '(08) 2919-8141', '(08) 2919-8141', '(9) 8400-6099', 'daniela.moreno@correo.ops', '66011279', 'L195993287', 'single', 'Friend', 'Mestizo', '0', '8637', '2003-11-17 12:06:00', 'Dra. Verónica Miranda Acosta', (SELECT id FROM users WHERE username = 'opsdoc07'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-037');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-038', 'Sr.', 'Spanish', 'Javier Manuel', 'Díaz Flores', '', '1989-2-27', 'Male', 'Jr. Bolívar 294', 'Puerto Alegre', 'Litoral', '58792', 'OPS', '(09) 3085-7660', '(09) 3085-7660', '(09) 3085-7660', '(9) 1222-8277', 'javier.diaz@correo.ops', '68939574', 'L100466124', 'married', 'Friend', 'Indígena', '6', '2591', '2003-11-17 12:06:00', 'Dr. Esteban Quispe Herrera', (SELECT id FROM users WHERE username = 'opsdoc08'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-038');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-039', 'Srta.', 'Spanish', 'Patricia Isabel', 'Díaz Acosta', '', '2004-4-5', 'Female', 'Calle 83 No. 70-35', 'Nueva Aurora', 'Oriente', '41407', 'OPS', '(04) 9590-6135', '(04) 9590-6135', '(04) 9590-6135', '(9) 6024-4100', 'patricia.diaz@correo.ops', '34323362', 'L691179639', 'single', 'Friend', 'Mulato', '0', '8557', '2003-11-17 12:06:00', 'Dra. Gabriela Escobar Silva', (SELECT id FROM users WHERE username = 'opsdoc09'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-039');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-040', 'Sr.', 'Spanish', 'Marcos', 'Aguilar Vega', '', '1997-6-19', 'Male', 'Carrera 69 No. 11-93', 'Puerto Alegre', 'Litoral', '14618', 'OPS', '(03) 8938-2465', '(03) 8938-2465', '(03) 8938-2465', '(9) 9678-8429', 'marcos.aguilar@correo.ops', '11217553', 'L480015917', 'single', 'Friend', 'Indígena', '6', '8400', '2003-11-17 12:06:00', 'Dr. Mauricio Villalobos Campos', (SELECT id FROM users WHERE username = 'opsdoc10'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-040');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-041', 'Sr.', 'Spanish', 'Ignacio Manuel', 'Navarro Vega', '', '2003-2-17', 'Male', 'Calle 54 No. 82-50', 'San Cristóbal', 'Costa Sur', '80798', 'OPS', '(07) 5895-2547', '(07) 5895-2547', '(07) 5895-2547', '(9) 4601-7995', 'ignacio.navarro@correo.ops', '96082431', 'L293369996', 'single', 'Friend', 'Asiático', '6', '3315', '2003-11-17 12:06:00', 'Dra. Carolina Salazar Fuentes', (SELECT id FROM users WHERE username = 'opsdoc01'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-041');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-042', 'Srta.', 'Spanish', 'María', 'Quispe Cruz', '', '1952-1-4', 'Female', 'Pasaje Las Palmas 3313', 'Los Robles', 'Valle', '71117', 'OPS', '(09) 5407-3859', '(09) 5407-3859', '(09) 5407-3859', '(9) 7629-4225', 'maria.quispe@correo.ops', '42047508', 'L429562325', 'single', 'Friend', 'Mestizo', '2', '6483', '2003-11-17 12:06:00', 'Dr. Ricardo Benítez Cabrera', (SELECT id FROM users WHERE username = 'opsdoc02'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-042');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-043', 'Srta.', 'Spanish', 'Mercedes de los Ángeles', 'Rojas Acosta', '', '2007-5-28', 'Female', 'Calle 74 No. 36-62', 'San Rafael', 'Norte', '42823', 'OPS', '(08) 2490-5196', '(08) 2490-5196', '(08) 2490-5196', '(9) 5061-6523', 'mercedes.rojas@correo.ops', '31329987', 'L814708919', 'single', 'Friend', 'Asiático', '8', '5534', '2003-11-17 12:06:00', 'Dra. Daniela Cárdenas Rojas', (SELECT id FROM users WHERE username = 'opsdoc03'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-043');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-044', 'Srta.', 'Spanish', 'Cecilia', 'Acosta Navarro', '', '1949-11-22', 'Female', 'Calle Colón 2808', 'La Esperanza', 'Oriente', '99243', 'OPS', '(03) 4212-6294', '(03) 4212-6294', '(03) 4212-6294', '(9) 1701-9230', 'cecilia.acosta@correo.ops', '83857521', 'L605335017', 'single', 'Friend', 'Blanco', '7', '2762', '2003-11-17 12:06:00', 'Dr. Fernando Cabrera Medina', (SELECT id FROM users WHERE username = 'opsdoc04'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-044');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-045', 'Sr.', 'Spanish', 'Andrés', 'Romero Salazar', '', '1991-9-6', 'Male', 'Jr. Bolívar 4969', 'San Rafael', 'Norte', '56693', 'OPS', '(06) 3665-8163', '(06) 3665-8163', '(06) 3665-8163', '(9) 4215-8684', 'andres.romero@correo.ops', '35033091', 'L115022200', 'single', 'Friend', 'Indígena', '10', '1661', '2003-11-17 12:06:00', 'Dra. Alejandra Fuentes Navarro', (SELECT id FROM users WHERE username = 'opsdoc05'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-045');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-046', 'Sra.', 'Spanish', 'Adriana', 'Torres Chávez', '', '1971-1-28', 'Female', 'Av. Las Américas 4552', 'Santa Lucía', 'Central', '76115', 'OPS', '(06) 9990-2296', '(06) 9990-2296', '(06) 9990-2296', '(9) 6807-4641', 'adriana.torres@correo.ops', '23898273', 'L989635121', 'married', 'Friend', 'Indígena', '1', '5829', '2003-11-17 12:06:00', 'Dr. Alejandro Paredes Vargas', (SELECT id FROM users WHERE username = 'opsdoc06'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-046');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-047', 'Srta.', 'Spanish', 'Raquel Elena', 'Hernández Torres', '', '1955-12-5', 'Female', 'Calle 31 No. 88-89', 'Valle Verde', 'Valle', '51200', 'OPS', '(07) 5457-4553', '(07) 5457-4553', '(07) 5457-4553', '(9) 5761-7014', 'raquel.hernandez@correo.ops', '81751856', 'L453410187', 'single', 'Friend', 'Blanco', '6', '5053', '2003-11-17 12:06:00', 'Dra. Verónica Miranda Acosta', (SELECT id FROM users WHERE username = 'opsdoc07'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-047');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-048', 'Sr.', 'Spanish', 'Mauricio Javier', 'Fuentes Cárdenas', '', '1988-12-13', 'Male', 'Pasaje Las Palmas 2549', 'Ciudad Bolívar', 'Norte', '27462', 'OPS', '(02) 4542-4783', '(02) 4542-4783', '(02) 4542-4783', '(9) 3911-4168', 'mauricio.fuentes@correo.ops', '37522538', 'L126082549', 'married', 'Friend', 'Mulato', '6', '4880', '2003-11-17 12:06:00', 'Dr. Esteban Quispe Herrera', (SELECT id FROM users WHERE username = 'opsdoc08'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-048');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-049', 'Sr.', 'Spanish', 'Fernando Antonio', 'González Vargas', '', '1976-4-15', 'Male', 'Av. Central 3934', 'Puerto Alegre', 'Litoral', '61557', 'OPS', '(03) 3325-1773', '(03) 3325-1773', '(03) 3325-1773', '(9) 6839-4873', 'fernando.gonzalez@correo.ops', '13554929', 'L764006032', 'single', 'Friend', 'Asiático', '9', '8633', '2003-11-17 12:06:00', 'Dra. Gabriela Escobar Silva', (SELECT id FROM users WHERE username = 'opsdoc09'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-049');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-050', 'Srta.', 'Spanish', 'Sofía Victoria', 'Torres Álvarez', '', '1937-8-15', 'Female', 'Calle Los Pinos 1802', 'San Cristóbal', 'Costa Sur', '94070', 'OPS', '(03) 2649-3362', '(03) 2649-3362', '(03) 2649-3362', '(9) 6899-6626', 'sofia.torres@correo.ops', '30518445', 'L407531312', 'single', 'Friend', 'Afrodescendiente', '5', '6612', '2003-11-17 12:06:00', 'Dr. Mauricio Villalobos Campos', (SELECT id FROM users WHERE username = 'opsdoc10'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-050');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-051', 'Sr.', 'Spanish', 'Alejandro', 'Miranda Flores', '', '1993-9-17', 'Male', 'Carrera 30 No. 76-45', 'Valle Verde', 'Valle', '25471', 'OPS', '(04) 9620-4154', '(04) 9620-4154', '(04) 9620-4154', '(9) 9065-2941', 'alejandro.miranda@correo.ops', '60333683', 'L321834103', 'single', 'Friend', 'Mulato', '9', '4902', '2003-11-17 12:06:00', 'Dra. Carolina Salazar Fuentes', (SELECT id FROM users WHERE username = 'opsdoc01'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-051');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-052', 'Sra.', 'Spanish', 'Carmen Isabel', 'Núñez Morales', '', '1960-5-2', 'Female', 'Calle Sucre 1992', 'La Esperanza', 'Oriente', '83137', 'OPS', '(04) 6191-9242', '(04) 6191-9242', '(04) 6191-9242', '(9) 9097-8077', 'carmen.nunez@correo.ops', '13256384', 'L748690389', 'married', 'Friend', 'Mulato', '2', '9913', '2003-11-17 12:06:00', 'Dr. Ricardo Benítez Cabrera', (SELECT id FROM users WHERE username = 'opsdoc02'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-052');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-053', 'Srta.', 'Spanish', 'Beatriz Victoria', 'Ortiz García', '', '1960-5-20', 'Female', 'Calle Colón 4897', 'Villa Nueva', 'Litoral', '97523', 'OPS', '(05) 3499-1270', '(05) 3499-1270', '(05) 3499-1270', '(9) 5997-5908', 'beatriz.ortiz@correo.ops', '76946750', 'L980878549', 'single', 'Friend', 'Afrodescendiente', '1', '5872', '2003-11-17 12:06:00', 'Dra. Daniela Cárdenas Rojas', (SELECT id FROM users WHERE username = 'opsdoc03'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-053');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-054', 'Sra.', 'Spanish', 'Mercedes Cristina', 'Díaz Fuentes', '', '1944-8-19', 'Female', 'Jr. Bolívar 976', 'Los Robles', 'Valle', '60043', 'OPS', '(09) 9004-8361', '(09) 9004-8361', '(09) 9004-8361', '(9) 2443-6872', 'mercedes.diaz@correo.ops', '95980408', 'L166214745', 'married', 'Friend', 'Afrodescendiente', '3', '5677', '2003-11-17 12:06:00', 'Dr. Fernando Cabrera Medina', (SELECT id FROM users WHERE username = 'opsdoc04'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-054');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-055', 'Srta.', 'Spanish', 'Inés', 'Rivera Vargas', '', '1965-8-3', 'Female', 'Pasaje Las Palmas 4083', 'Punta Serena', 'Costa Sur', '76882', 'OPS', '(09) 6028-9360', '(09) 6028-9360', '(09) 6028-9360', '(9) 3104-9080', 'ines.rivera@correo.ops', '42167099', 'L256403992', 'single', 'Friend', 'Blanco', '2', '7701', '2003-11-17 12:06:00', 'Dra. Alejandra Fuentes Navarro', (SELECT id FROM users WHERE username = 'opsdoc05'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-055');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-056', 'Sr.', 'Spanish', 'Mauricio Manuel', 'Mendoza Álvarez', '', '1949-9-28', 'Male', 'Av. San Martín 3766', 'Ciudad Bolívar', 'Norte', '30043', 'OPS', '(07) 5712-4817', '(07) 5712-4817', '(07) 5712-4817', '(9) 6308-3444', 'mauricio.mendoza@correo.ops', '94753089', 'L449878375', 'married', 'Friend', 'Afrodescendiente', '6', '3863', '2003-11-17 12:06:00', 'Dr. Alejandro Paredes Vargas', (SELECT id FROM users WHERE username = 'opsdoc06'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-056');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-057', 'Srta.', 'Spanish', 'Elena Isabel', 'Cruz Villalobos', '', '2000-8-28', 'Female', 'Av. Independencia 3632', 'La Esperanza', 'Oriente', '17735', 'OPS', '(07) 5681-4565', '(07) 5681-4565', '(07) 5681-4565', '(9) 9301-9568', 'elena.cruz@correo.ops', '42356314', 'L593306868', 'single', 'Friend', 'Afrodescendiente', '6', '5737', '2003-11-17 12:06:00', 'Dra. Verónica Miranda Acosta', (SELECT id FROM users WHERE username = 'opsdoc07'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-057');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-058', 'Srta.', 'Spanish', 'Mercedes del Carmen', 'Miranda Vega', '', '1944-1-1', 'Female', 'Calle Sucre 2374', 'Nueva Aurora', 'Oriente', '63011', 'OPS', '(04) 8170-8219', '(04) 8170-8219', '(04) 8170-8219', '(9) 8031-4669', 'mercedes.miranda@correo.ops', '36837564', 'L921842675', 'single', 'Friend', 'Mestizo', '10', '5407', '2003-11-17 12:06:00', 'Dr. Esteban Quispe Herrera', (SELECT id FROM users WHERE username = 'opsdoc08'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-058');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-059', 'Sr.', 'Spanish', 'Marcos', 'Silva Escobar', '', '2000-7-27', 'Male', 'Calle 15 No. 66-64', 'Villa Nueva', 'Litoral', '73666', 'OPS', '(08) 8601-2991', '(08) 8601-2991', '(08) 8601-2991', '(9) 8842-2620', 'marcos.silva@correo.ops', '26593215', 'L898496418', 'single', 'Friend', 'Afrodescendiente', '0', '2235', '2003-11-17 12:06:00', 'Dra. Gabriela Escobar Silva', (SELECT id FROM users WHERE username = 'opsdoc09'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-059');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-060', 'Sra.', 'Spanish', 'Cecilia', 'Sánchez Paredes', '', '1934-8-12', 'Female', 'Av. Independencia 3118', 'Puerto Alegre', 'Litoral', '89423', 'OPS', '(04) 7763-7263', '(04) 7763-7263', '(04) 7763-7263', '(9) 6967-9711', 'cecilia.sanchez@correo.ops', '79287911', 'L180436798', 'married', 'Friend', 'Mulato', '9', '2969', '2003-11-17 12:06:00', 'Dr. Mauricio Villalobos Campos', (SELECT id FROM users WHERE username = 'opsdoc10'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-060');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-061', 'Sr.', 'Spanish', 'Antonio Andrés', 'Jiménez Ramos', '', '1931-9-7', 'Male', 'Calle 30 No. 36-47', 'Villa Nueva', 'Litoral', '73796', 'OPS', '(04) 3020-5162', '(04) 3020-5162', '(04) 3020-5162', '(9) 7363-2120', 'antonio.jimenez@correo.ops', '59061302', 'L259731384', 'married', 'Friend', 'Blanco', '2', '3507', '2003-11-17 12:06:00', 'Dra. Carolina Salazar Fuentes', (SELECT id FROM users WHERE username = 'opsdoc01'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-061');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-062', 'Sr.', 'Spanish', 'Gustavo Eduardo', 'Miranda Rojas', '', '1975-5-23', 'Male', 'Carrera 42 No. 61-45', 'Villa Nueva', 'Litoral', '62932', 'OPS', '(02) 8675-2325', '(02) 8675-2325', '(02) 8675-2325', '(9) 5247-4484', 'gustavo.miranda@correo.ops', '82904149', 'L101765739', 'single', 'Friend', 'Indígena', '10', '396', '2003-11-17 12:06:00', 'Dr. Ricardo Benítez Cabrera', (SELECT id FROM users WHERE username = 'opsdoc02'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-062');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-063', 'Sra.', 'Spanish', 'Carmen', 'Cruz Fuentes', '', '1988-5-10', 'Female', 'Av. Las Américas 2424', 'Puerto Alegre', 'Litoral', '27743', 'OPS', '(04) 3113-1275', '(04) 3113-1275', '(04) 3113-1275', '(9) 6293-7690', 'carmen.cruz@correo.ops', '36028342', 'L611876087', 'married', 'Friend', 'Asiático', '10', '4035', '2003-11-17 12:06:00', 'Dra. Daniela Cárdenas Rojas', (SELECT id FROM users WHERE username = 'opsdoc03'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-063');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-064', 'Srta.', 'Spanish', 'Silvia Cristina', 'Rojas Morales', '', '1992-6-22', 'Female', 'Calle 14 No. 74-59', 'La Esperanza', 'Oriente', '10090', 'OPS', '(07) 5201-1920', '(07) 5201-1920', '(07) 5201-1920', '(9) 7542-4482', 'silvia.rojas@correo.ops', '60868959', 'L441258319', 'single', 'Friend', 'Mestizo', '6', '9778', '2003-11-17 12:06:00', 'Dr. Fernando Cabrera Medina', (SELECT id FROM users WHERE username = 'opsdoc04'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-064');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-065', 'Srta.', 'Spanish', 'Verónica Isabel', 'Martínez Ramos', '', '1978-6-3', 'Female', 'Jr. Bolívar 2372', 'San Cristóbal', 'Costa Sur', '58938', 'OPS', '(02) 7390-1388', '(02) 7390-1388', '(02) 7390-1388', '(9) 9865-6840', 'veronica.martinez@correo.ops', '62587263', 'L858829314', 'single', 'Friend', 'Mulato', '8', '1079', '2003-11-17 12:06:00', 'Dra. Alejandra Fuentes Navarro', (SELECT id FROM users WHERE username = 'opsdoc05'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-065');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-066', 'Sr.', 'Spanish', 'Manuel', 'Hernández Escobar', '', '2004-2-9', 'Male', 'Calle 79 No. 18-71', 'La Esperanza', 'Oriente', '60544', 'OPS', '(07) 7731-1424', '(07) 7731-1424', '(07) 7731-1424', '(9) 1952-7158', 'manuel.hernandez@correo.ops', '47648067', 'L522265609', 'single', 'Friend', 'Afrodescendiente', '3', '2911', '2003-11-17 12:06:00', 'Dr. Alejandro Paredes Vargas', (SELECT id FROM users WHERE username = 'opsdoc06'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-066');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-067', 'Sra.', 'Spanish', 'María Cristina', 'Vargas Díaz', '', '1971-11-12', 'Female', 'Jr. Bolívar 3686', 'Los Robles', 'Valle', '54125', 'OPS', '(06) 8519-8553', '(06) 8519-8553', '(06) 8519-8553', '(9) 3304-5566', 'maria.vargas@correo.ops', '69399330', 'L896658049', 'married', 'Friend', 'Mulato', '7', '7205', '2003-11-17 12:06:00', 'Dra. Verónica Miranda Acosta', (SELECT id FROM users WHERE username = 'opsdoc07'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-067');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-068', 'Sr.', 'Spanish', 'Ramón', 'Gutiérrez López', '', '1937-2-11', 'Male', 'Calle 7 No. 26-87', 'Valle Verde', 'Valle', '55431', 'OPS', '(02) 6774-7330', '(02) 6774-7330', '(02) 6774-7330', '(9) 2639-2003', 'ramon.gutierrez@correo.ops', '72553925', 'L420804081', 'single', 'Friend', 'Mulato', '4', '8938', '2003-11-17 12:06:00', 'Dr. Esteban Quispe Herrera', (SELECT id FROM users WHERE username = 'opsdoc08'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-068');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-069', 'Sra.', 'Spanish', 'Sofía Beatriz', 'Bustamante López', '', '1965-9-6', 'Female', 'Av. Las Américas 4664', 'Santa Lucía', 'Central', '90266', 'OPS', '(04) 3144-5762', '(04) 3144-5762', '(04) 3144-5762', '(9) 3691-8445', 'sofia.bustamante@correo.ops', '12090639', 'L809861533', 'married', 'Friend', 'Mestizo', '8', '7563', '2003-11-17 12:06:00', 'Dra. Gabriela Escobar Silva', (SELECT id FROM users WHERE username = 'opsdoc09'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-069');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-070', 'Srta.', 'Spanish', 'Verónica de los Ángeles', 'Castillo Villalobos', '', '1998-6-26', 'Female', 'Av. Las Américas 825', 'Valle Verde', 'Valle', '94234', 'OPS', '(06) 9661-2575', '(06) 9661-2575', '(06) 9661-2575', '(9) 5719-3994', 'veronica.castillo@correo.ops', '77143453', 'L689231911', 'single', 'Friend', 'Asiático', '10', '8047', '2003-11-17 12:06:00', 'Dr. Mauricio Villalobos Campos', (SELECT id FROM users WHERE username = 'opsdoc10'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-070');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-071', 'Sr.', 'Spanish', 'Carlos', 'López Vega', '', '1966-2-26', 'Male', 'Jr. Bolívar 2138', 'Puerto Alegre', 'Litoral', '31854', 'OPS', '(08) 6694-2244', '(08) 6694-2244', '(08) 6694-2244', '(9) 8456-5348', 'carlos.lopez@correo.ops', '43851724', 'L547223889', 'single', 'Friend', 'Mulato', '8', '9618', '2003-11-17 12:06:00', 'Dra. Carolina Salazar Fuentes', (SELECT id FROM users WHERE username = 'opsdoc01'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-071');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-072', 'Sra.', 'Spanish', 'Natalia del Carmen', 'Ramírez Peña', '', '1959-11-14', 'Female', 'Av. Independencia 1307', 'San Cristóbal', 'Costa Sur', '68216', 'OPS', '(06) 3125-3495', '(06) 3125-3495', '(06) 3125-3495', '(9) 6742-6112', 'natalia.ramirez@correo.ops', '13607092', 'L361103905', 'married', 'Friend', 'Blanco', '1', '454', '2003-11-17 12:06:00', 'Dr. Ricardo Benítez Cabrera', (SELECT id FROM users WHERE username = 'opsdoc02'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-072');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-073', 'Sra.', 'Spanish', 'Pilar Guadalupe', 'Rivera Cárdenas', '', '1951-9-20', 'Female', 'Av. Central 103', 'Valle Verde', 'Valle', '41600', 'OPS', '(08) 8227-2450', '(08) 8227-2450', '(08) 8227-2450', '(9) 7447-3942', 'pilar.rivera@correo.ops', '38142991', 'L504106850', 'married', 'Friend', 'Indígena', '5', '731', '2003-11-17 12:06:00', 'Dra. Daniela Cárdenas Rojas', (SELECT id FROM users WHERE username = 'opsdoc03'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-073');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-074', 'Sr.', 'Spanish', 'Juan Eduardo', 'Peña Castillo', '', '1952-3-21', 'Male', 'Calle 70 No. 25-40', 'San Rafael', 'Norte', '45252', 'OPS', '(09) 6046-1791', '(09) 6046-1791', '(09) 6046-1791', '(9) 9311-9182', 'juan.pena@correo.ops', '20448162', 'L205022382', 'single', 'Friend', 'Blanco', '4', '6223', '2003-11-17 12:06:00', 'Dr. Fernando Cabrera Medina', (SELECT id FROM users WHERE username = 'opsdoc04'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-074');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-075', 'Srta.', 'Spanish', 'Teresa Beatriz', 'Ramos Paredes', '', '1992-4-15', 'Female', 'Calle Sucre 2024', 'San Rafael', 'Norte', '59103', 'OPS', '(03) 5628-8797', '(03) 5628-8797', '(03) 5628-8797', '(9) 4485-6630', 'teresa.ramos@correo.ops', '76638945', 'L465752482', 'single', 'Friend', 'Mestizo', '7', '2485', '2003-11-17 12:06:00', 'Dra. Alejandra Fuentes Navarro', (SELECT id FROM users WHERE username = 'opsdoc05'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-075');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-076', 'Sr.', 'Spanish', 'Manuel Javier', 'Rivera Cárdenas', '', '1939-2-14', 'Male', 'Calle Colón 2056', 'Ciudad Bolívar', 'Norte', '26646', 'OPS', '(02) 4869-6762', '(02) 4869-6762', '(02) 4869-6762', '(9) 8332-8181', 'manuel.rivera@correo.ops', '92913538', 'L645100490', 'single', 'Friend', 'Mestizo', '4', '4459', '2003-11-17 12:06:00', 'Dr. Alejandro Paredes Vargas', (SELECT id FROM users WHERE username = 'opsdoc06'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-076');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-077', 'Sra.', 'Spanish', 'Gabriela Beatriz', 'Fuentes Contreras', '', '1974-7-28', 'Female', 'Av. Central 2499', 'San Miguel', 'Central', '53883', 'OPS', '(02) 4509-3863', '(02) 4509-3863', '(02) 4509-3863', '(9) 8267-5750', 'gabriela.fuentes@correo.ops', '11308058', 'L112548951', 'married', 'Friend', 'Afrodescendiente', '9', '8892', '2003-11-17 12:06:00', 'Dra. Verónica Miranda Acosta', (SELECT id FROM users WHERE username = 'opsdoc07'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-077');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-078', 'Sr.', 'Spanish', 'Tomás', 'Peña Fuentes', '', '1989-3-11', 'Male', 'Calle Los Pinos 3906', 'Los Robles', 'Valle', '89824', 'OPS', '(09) 7928-2251', '(09) 7928-2251', '(09) 7928-2251', '(9) 7645-5893', 'tomas.pena@correo.ops', '46819409', 'L489473175', 'married', 'Friend', 'Asiático', '8', '5577', '2003-11-17 12:06:00', 'Dr. Esteban Quispe Herrera', (SELECT id FROM users WHERE username = 'opsdoc08'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-078');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-079', 'Sr.', 'Spanish', 'Eduardo Enrique', 'Álvarez Gómez', '', '1945-9-9', 'Male', 'Carrera 18 No. 19-21', 'San Cristóbal', 'Costa Sur', '97655', 'OPS', '(04) 6351-5115', '(04) 6351-5115', '(04) 6351-5115', '(9) 3300-5450', 'eduardo.alvarez@correo.ops', '48440966', 'L150269309', 'married', 'Friend', 'Mestizo', '8', '9998', '2003-11-17 12:06:00', 'Dra. Gabriela Escobar Silva', (SELECT id FROM users WHERE username = 'opsdoc09'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-079');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-080', 'Sra.', 'Spanish', 'Alejandra Isabel', 'Paredes Sánchez', '', '1951-8-24', 'Female', 'Av. Las Américas 4172', 'Santa Lucía', 'Central', '53338', 'OPS', '(04) 3795-8738', '(04) 3795-8738', '(04) 3795-8738', '(9) 9571-6075', 'alejandra.paredes@correo.ops', '89535434', 'L362042019', 'married', 'Friend', 'Indígena', '3', '569', '2003-11-17 12:06:00', 'Dr. Mauricio Villalobos Campos', (SELECT id FROM users WHERE username = 'opsdoc10'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-080');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-081', 'Srta.', 'Spanish', 'Rosa Beatriz', 'Navarro López', '', '2004-3-17', 'Female', 'Calle 59 No. 98-77', 'Villa Nueva', 'Litoral', '55799', 'OPS', '(02) 6659-8153', '(02) 6659-8153', '(02) 6659-8153', '(9) 3054-5679', 'rosa.navarro@correo.ops', '24355159', 'L794358162', 'single', 'Friend', 'Afrodescendiente', '5', '2953', '2003-11-17 12:06:00', 'Dra. Carolina Salazar Fuentes', (SELECT id FROM users WHERE username = 'opsdoc01'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-081');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-082', 'Sr.', 'Spanish', 'Julián Eduardo', 'Guerrero Fuentes', '', '1949-2-26', 'Male', 'Calle Sucre 1216', 'Nueva Aurora', 'Oriente', '48921', 'OPS', '(09) 5911-6150', '(09) 5911-6150', '(09) 5911-6150', '(9) 2529-9667', 'julian.guerrero@correo.ops', '94402622', 'L338667707', 'single', 'Friend', 'Mulato', '2', '7458', '2003-11-17 12:06:00', 'Dr. Ricardo Benítez Cabrera', (SELECT id FROM users WHERE username = 'opsdoc02'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-082');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-083', 'Sra.', 'Spanish', 'Inés Beatriz', 'Sandoval Chávez', '', '1979-10-6', 'Female', 'Av. San Martín 1233', 'La Esperanza', 'Oriente', '44526', 'OPS', '(07) 6561-4008', '(07) 6561-4008', '(07) 6561-4008', '(9) 6526-5623', 'ines.sandoval@correo.ops', '25711163', 'L192833985', 'married', 'Friend', 'Mulato', '8', '9828', '2003-11-17 12:06:00', 'Dra. Daniela Cárdenas Rojas', (SELECT id FROM users WHERE username = 'opsdoc03'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-083');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-084', 'Sr.', 'Spanish', 'Francisco Eduardo', 'Salazar Mendoza', '', '1940-4-18', 'Male', 'Jr. Bolívar 2502', 'Punta Serena', 'Costa Sur', '37917', 'OPS', '(04) 2794-6833', '(04) 2794-6833', '(04) 2794-6833', '(9) 4031-1363', 'francisco.salazar@correo.ops', '59174427', 'L499113929', 'single', 'Friend', 'Afrodescendiente', '8', '3304', '2003-11-17 12:06:00', 'Dr. Fernando Cabrera Medina', (SELECT id FROM users WHERE username = 'opsdoc04'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-084');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-085', 'Sr.', 'Spanish', 'Raúl', 'Vega Espinoza', '', '2006-4-27', 'Male', 'Calle Los Pinos 4617', 'Santa Lucía', 'Central', '98517', 'OPS', '(07) 6002-4497', '(07) 6002-4497', '(07) 6002-4497', '(9) 6772-8436', 'raul.vega@correo.ops', '91239038', 'L719280282', 'single', 'Friend', 'Blanco', '7', '6262', '2003-11-17 12:06:00', 'Dra. Alejandra Fuentes Navarro', (SELECT id FROM users WHERE username = 'opsdoc05'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-085');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-086', 'Sra.', 'Spanish', 'Adriana Cristina', 'Salazar Flores', '', '1948-7-28', 'Female', 'Pasaje Las Palmas 459', 'Santa Lucía', 'Central', '65975', 'OPS', '(02) 2093-6247', '(02) 2093-6247', '(02) 2093-6247', '(9) 9873-8209', 'adriana.salazar@correo.ops', '10099857', 'L893493960', 'married', 'Friend', 'Blanco', '1', '3773', '2003-11-17 12:06:00', 'Dr. Alejandro Paredes Vargas', (SELECT id FROM users WHERE username = 'opsdoc06'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-086');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-087', 'Sr.', 'Spanish', 'Sergio Eduardo', 'Pérez Molina', '', '1989-11-5', 'Male', 'Calle Sucre 4982', 'Punta Serena', 'Costa Sur', '57703', 'OPS', '(05) 4002-9207', '(05) 4002-9207', '(05) 4002-9207', '(9) 4617-3980', 'sergio.perez@correo.ops', '79163939', 'L725870839', 'single', 'Friend', 'Blanco', '9', '4788', '2003-11-17 12:06:00', 'Dra. Verónica Miranda Acosta', (SELECT id FROM users WHERE username = 'opsdoc07'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-087');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-088', 'Sra.', 'Spanish', 'Pilar Fernanda', 'Mendoza Navarro', '', '1932-6-2', 'Female', 'Av. Independencia 2643', 'Villa Nueva', 'Litoral', '50584', 'OPS', '(05) 6447-2916', '(05) 6447-2916', '(05) 6447-2916', '(9) 8623-7649', 'pilar.mendoza@correo.ops', '74898592', 'L615444502', 'married', 'Friend', 'Asiático', '6', '6921', '2003-11-17 12:06:00', 'Dr. Esteban Quispe Herrera', (SELECT id FROM users WHERE username = 'opsdoc08'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-088');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-089', 'Sr.', 'Spanish', 'José', 'Ortiz Ramírez', '', '1988-4-23', 'Male', 'Av. Las Américas 2325', 'Ciudad Bolívar', 'Norte', '55589', 'OPS', '(08) 2154-6003', '(08) 2154-6003', '(08) 2154-6003', '(9) 5650-8994', 'jose.ortiz@correo.ops', '57372458', 'L995429980', 'single', 'Friend', 'Afrodescendiente', '9', '3878', '2003-11-17 12:06:00', 'Dra. Gabriela Escobar Silva', (SELECT id FROM users WHERE username = 'opsdoc09'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-089');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-090', 'Sr.', 'Spanish', 'Javier Antonio', 'Ramírez Peña', '', '1958-6-5', 'Male', 'Calle 19 No. 48-59', 'Puerto Alegre', 'Litoral', '69670', 'OPS', '(07) 6512-4363', '(07) 6512-4363', '(07) 6512-4363', '(9) 4527-8419', 'javier.ramirez@correo.ops', '29520137', 'L576869547', 'single', 'Friend', 'Afrodescendiente', '0', '6857', '2003-11-17 12:06:00', 'Dr. Mauricio Villalobos Campos', (SELECT id FROM users WHERE username = 'opsdoc10'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-090');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-091', 'Sr.', 'Spanish', 'José Manuel', 'Peña González', '', '1958-6-19', 'Male', 'Jr. Bolívar 3618', 'La Esperanza', 'Oriente', '51734', 'OPS', '(05) 3454-1716', '(05) 3454-1716', '(05) 3454-1716', '(9) 9785-2045', 'jose.pena@correo.ops', '82699540', 'L995671036', 'married', 'Friend', 'Afrodescendiente', '3', '342', '2003-11-17 12:06:00', 'Dra. Carolina Salazar Fuentes', (SELECT id FROM users WHERE username = 'opsdoc01'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-091');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-092', 'Srta.', 'Spanish', 'Fernanda', 'Castillo Romero', '', '1990-9-20', 'Female', 'Av. San Martín 3659', 'Ciudad Bolívar', 'Norte', '94289', 'OPS', '(04) 2801-6781', '(04) 2801-6781', '(04) 2801-6781', '(9) 8907-9561', 'fernanda.castillo@correo.ops', '96714231', 'L651619544', 'single', 'Friend', 'Afrodescendiente', '9', '6104', '2003-11-17 12:06:00', 'Dr. Ricardo Benítez Cabrera', (SELECT id FROM users WHERE username = 'opsdoc02'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-092');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-093', 'Sra.', 'Spanish', 'Dolores', 'Herrera Espinoza', '', '1951-2-26', 'Female', 'Av. Central 3553', 'Valle Verde', 'Valle', '20094', 'OPS', '(02) 9410-6928', '(02) 9410-6928', '(02) 9410-6928', '(9) 9528-8770', 'dolores.herrera@correo.ops', '61868334', 'L200229749', 'married', 'Friend', 'Afrodescendiente', '6', '6004', '2003-11-17 12:06:00', 'Dra. Daniela Cárdenas Rojas', (SELECT id FROM users WHERE username = 'opsdoc03'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-093');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-094', 'Srta.', 'Spanish', 'Isabel Fernanda', 'Moreno Torres', '', '1978-12-27', 'Female', 'Av. San Martín 962', 'Villa Nueva', 'Litoral', '11166', 'OPS', '(02) 4964-6093', '(02) 4964-6093', '(02) 4964-6093', '(9) 2756-8647', 'isabel.moreno@correo.ops', '95701483', 'L543439891', 'single', 'Friend', 'Mulato', '3', '5307', '2003-11-17 12:06:00', 'Dr. Fernando Cabrera Medina', (SELECT id FROM users WHERE username = 'opsdoc04'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-094');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-095', 'Sr.', 'Spanish', 'Sergio Eduardo', 'Ortiz Pérez', '', '2000-5-2', 'Male', 'Calle Colón 866', 'Villa Nueva', 'Litoral', '19472', 'OPS', '(02) 6952-2771', '(02) 6952-2771', '(02) 6952-2771', '(9) 6348-9669', 'sergio.ortiz@correo.ops', '80993899', 'L296300524', 'single', 'Friend', 'Blanco', '7', '4319', '2003-11-17 12:06:00', 'Dra. Alejandra Fuentes Navarro', (SELECT id FROM users WHERE username = 'opsdoc05'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-095');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-096', 'Sr.', 'Spanish', 'Tomás', 'Álvarez Ortiz', '', '1996-10-11', 'Male', 'Calle Los Pinos 294', 'Ciudad Bolívar', 'Norte', '53805', 'OPS', '(05) 6467-9234', '(05) 6467-9234', '(05) 6467-9234', '(9) 9620-3251', 'tomas.alvarez@correo.ops', '23921659', 'L511798487', 'single', 'Friend', 'Mulato', '4', '1553', '2003-11-17 12:06:00', 'Dr. Alejandro Paredes Vargas', (SELECT id FROM users WHERE username = 'opsdoc06'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-096');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-097', 'Srta.', 'Spanish', 'Paola Cristina', 'Guerrero López', '', '2002-11-26', 'Female', 'Av. San Martín 1759', 'Valle Verde', 'Valle', '82630', 'OPS', '(07) 3185-4939', '(07) 3185-4939', '(07) 3185-4939', '(9) 4108-3205', 'paola.guerrero@correo.ops', '36039686', 'L949948349', 'single', 'Friend', 'Afrodescendiente', '5', '8890', '2003-11-17 12:06:00', 'Dra. Verónica Miranda Acosta', (SELECT id FROM users WHERE username = 'opsdoc07'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-097');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-098', 'Srta.', 'Spanish', 'Daniela Guadalupe', 'Pérez López', '', '1997-2-1', 'Female', 'Calle Los Pinos 2814', 'Valle Verde', 'Valle', '13569', 'OPS', '(06) 8570-1320', '(06) 8570-1320', '(06) 8570-1320', '(9) 9991-5400', 'daniela.perez@correo.ops', '72895972', 'L280164202', 'single', 'Friend', 'Mestizo', '7', '7423', '2003-11-17 12:06:00', 'Dr. Esteban Quispe Herrera', (SELECT id FROM users WHERE username = 'opsdoc08'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-098');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-099', 'Sr.', 'Spanish', 'Ramón Alberto', 'Morales Miranda', '', '1996-4-27', 'Male', 'Pasaje Las Palmas 4895', 'Punta Serena', 'Costa Sur', '93392', 'OPS', '(09) 3906-8074', '(09) 3906-8074', '(09) 3906-8074', '(9) 4773-6202', 'ramon.morales@correo.ops', '57588840', 'L714032913', 'single', 'Friend', 'Mestizo', '7', '6891', '2003-11-17 12:06:00', 'Dra. Gabriela Escobar Silva', (SELECT id FROM users WHERE username = 'opsdoc09'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-099');

INSERT INTO patient_data (pid, pubpid, title, language, fname, lname, mname, DOB, sex, street, city, state, postal_code, country_code, phone_home, phone_biz, phone_contact, phone_cell, email, ss, drivers_license, status, contact_relationship, ethnoracial, family_size, monthly_income, date, referrer, providerID, allow_patient_portal)
SELECT next_pid.np, 'PAHO-OPS-PATIENT-100', 'Sra.', 'Spanish', 'Teresa Beatriz', 'Cárdenas Ramírez', '', '1944-5-22', 'Female', 'Calle Colón 2475', 'La Esperanza', 'Oriente', '53561', 'OPS', '(06) 7716-7543', '(06) 7716-7543', '(06) 7716-7543', '(9) 3818-1081', 'teresa.cardenas@correo.ops', '41235431', 'L527390476', 'married', 'Friend', 'Indígena', '10', '6590', '2003-11-17 12:06:00', 'Dr. Mauricio Villalobos Campos', (SELECT id FROM users WHERE username = 'opsdoc10'), 'YES'
FROM (SELECT COALESCE(MAX(pid), 0) + 1 AS np FROM patient_data) next_pid
WHERE NOT EXISTS (SELECT 1 FROM patient_data WHERE pubpid = 'PAHO-OPS-PATIENT-100');


-- ============================================================
-- G. patient_access_onsite - portal credentials
-- ============================================================
-- portal_pwd_status = 1 means no forced password change on next
-- login. portal_login_username is BINARY-compared during portal
-- login. pid is looked up by pubpid so the row always links to the
-- patient created in section F, whatever pid was allocated.

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops001', 'ops001', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-001'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops001');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops002', 'ops002', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-002'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops002');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops003', 'ops003', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-003'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops003');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops004', 'ops004', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-004'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops004');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops005', 'ops005', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-005'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops005');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops006', 'ops006', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-006'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops006');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops007', 'ops007', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-007'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops007');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops008', 'ops008', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-008'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops008');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops009', 'ops009', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-009'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops009');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops010', 'ops010', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-010'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops010');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops011', 'ops011', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-011'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops011');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops012', 'ops012', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-012'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops012');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops013', 'ops013', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-013'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops013');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops014', 'ops014', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-014'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops014');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops015', 'ops015', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-015'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops015');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops016', 'ops016', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-016'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops016');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops017', 'ops017', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-017'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops017');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops018', 'ops018', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-018'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops018');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops019', 'ops019', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-019'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops019');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops020', 'ops020', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-020'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops020');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops021', 'ops021', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-021'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops021');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops022', 'ops022', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-022'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops022');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops023', 'ops023', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-023'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops023');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops024', 'ops024', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-024'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops024');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops025', 'ops025', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-025'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops025');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops026', 'ops026', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-026'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops026');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops027', 'ops027', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-027'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops027');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops028', 'ops028', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-028'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops028');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops029', 'ops029', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-029'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops029');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops030', 'ops030', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-030'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops030');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops031', 'ops031', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-031'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops031');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops032', 'ops032', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-032'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops032');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops033', 'ops033', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-033'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops033');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops034', 'ops034', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-034'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops034');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops035', 'ops035', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-035'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops035');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops036', 'ops036', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-036'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops036');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops037', 'ops037', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-037'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops037');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops038', 'ops038', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-038'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops038');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops039', 'ops039', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-039'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops039');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops040', 'ops040', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-040'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops040');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops041', 'ops041', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-041'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops041');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops042', 'ops042', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-042'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops042');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops043', 'ops043', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-043'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops043');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops044', 'ops044', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-044'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops044');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops045', 'ops045', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-045'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops045');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops046', 'ops046', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-046'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops046');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops047', 'ops047', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-047'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops047');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops048', 'ops048', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-048'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops048');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops049', 'ops049', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-049'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops049');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops050', 'ops050', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-050'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops050');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops051', 'ops051', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-051'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops051');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops052', 'ops052', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-052'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops052');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops053', 'ops053', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-053'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops053');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops054', 'ops054', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-054'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops054');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops055', 'ops055', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-055'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops055');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops056', 'ops056', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-056'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops056');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops057', 'ops057', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-057'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops057');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops058', 'ops058', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-058'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops058');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops059', 'ops059', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-059'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops059');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops060', 'ops060', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-060'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops060');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops061', 'ops061', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-061'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops061');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops062', 'ops062', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-062'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops062');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops063', 'ops063', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-063'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops063');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops064', 'ops064', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-064'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops064');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops065', 'ops065', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-065'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops065');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops066', 'ops066', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-066'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops066');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops067', 'ops067', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-067'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops067');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops068', 'ops068', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-068'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops068');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops069', 'ops069', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-069'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops069');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops070', 'ops070', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-070'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops070');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops071', 'ops071', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-071'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops071');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops072', 'ops072', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-072'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops072');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops073', 'ops073', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-073'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops073');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops074', 'ops074', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-074'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops074');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops075', 'ops075', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-075'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops075');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops076', 'ops076', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-076'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops076');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops077', 'ops077', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-077'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops077');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops078', 'ops078', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-078'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops078');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops079', 'ops079', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-079'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops079');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops080', 'ops080', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-080'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops080');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops081', 'ops081', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-081'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops081');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops082', 'ops082', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-082'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops082');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops083', 'ops083', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-083'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops083');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops084', 'ops084', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-084'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops084');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops085', 'ops085', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-085'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops085');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops086', 'ops086', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-086'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops086');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops087', 'ops087', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-087'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops087');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops088', 'ops088', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-088'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops088');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops089', 'ops089', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-089'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops089');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops090', 'ops090', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-090'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops090');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops091', 'ops091', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-091'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops091');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops092', 'ops092', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-092'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops092');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops093', 'ops093', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-093'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops093');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops094', 'ops094', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-094'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops094');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops095', 'ops095', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-095'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops095');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops096', 'ops096', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-096'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops096');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops097', 'ops097', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-097'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops097');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops098', 'ops098', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-098'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops098');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops099', 'ops099', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-099'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops099');

INSERT INTO patient_access_onsite (pid, portal_username, portal_login_username, portal_pwd, portal_pwd_status)
SELECT p.pid, 'ops100', 'ops100', '$2y$12$rGygOMjH20Zl1WRKIIQmlOJ4Tuev2b2k6sew02V0XTjV5WL34QYUi', 1
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-100'
  AND NOT EXISTS (SELECT 1 FROM patient_access_onsite WHERE portal_login_username = 'ops100');


-- ============================================================
-- H. insurance_companies - carriers
-- ============================================================
-- id has no AUTO_INCREMENT, so it uses the MAX(id)+1 derived-table
-- pattern. Idempotency guard is on name, and section J resolves the
-- carrier by name rather than by a hardcoded id.
-- ins_type_code replaces the freeb_type column of pre-6.x schemas.
-- x12_default_partner_id is left NULL: the ids carried by the source
-- dump refer to partners that do not exist in this database.

INSERT INTO insurance_companies (id, name, attn, cms_id, ins_type_code, x12_receiver_id, x12_default_partner_id, alt_cms_id)
SELECT next_ic.np, 'Aseguradora Andina S.A.', NULL, '6413', 3, '0', NULL, ''
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM insurance_companies) next_ic
WHERE NOT EXISTS (SELECT 1 FROM insurance_companies WHERE name = 'Aseguradora Andina S.A.');

INSERT INTO insurance_companies (id, name, attn, cms_id, ins_type_code, x12_receiver_id, x12_default_partner_id, alt_cms_id)
SELECT next_ic.np, 'Seguros del Pacífico', NULL, '95373', 3, '8134', NULL, ''
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM insurance_companies) next_ic
WHERE NOT EXISTS (SELECT 1 FROM insurance_companies WHERE name = 'Seguros del Pacífico');

INSERT INTO insurance_companies (id, name, attn, cms_id, ins_type_code, x12_receiver_id, x12_default_partner_id, alt_cms_id)
SELECT next_ic.np, 'Salud Integral S.A.', NULL, '43692', 3, '8134', NULL, ''
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM insurance_companies) next_ic
WHERE NOT EXISTS (SELECT 1 FROM insurance_companies WHERE name = 'Salud Integral S.A.');

INSERT INTO insurance_companies (id, name, attn, cms_id, ins_type_code, x12_receiver_id, x12_default_partner_id, alt_cms_id)
SELECT next_ic.np, 'Mutual Latinoamericana', NULL, '1488', 3, '8134', NULL, ''
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM insurance_companies) next_ic
WHERE NOT EXISTS (SELECT 1 FROM insurance_companies WHERE name = 'Mutual Latinoamericana');

INSERT INTO insurance_companies (id, name, attn, cms_id, ins_type_code, x12_receiver_id, x12_default_partner_id, alt_cms_id)
SELECT next_ic.np, 'Previsión Regional S.A.', NULL, '76111', 3, '9675', NULL, ''
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM insurance_companies) next_ic
WHERE NOT EXISTS (SELECT 1 FROM insurance_companies WHERE name = 'Previsión Regional S.A.');

INSERT INTO insurance_companies (id, name, attn, cms_id, ins_type_code, x12_receiver_id, x12_default_partner_id, alt_cms_id)
SELECT next_ic.np, 'Cruz Verde Salud', NULL, '6084', 3, '0', NULL, ''
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM insurance_companies) next_ic
WHERE NOT EXISTS (SELECT 1 FROM insurance_companies WHERE name = 'Cruz Verde Salud');

INSERT INTO insurance_companies (id, name, attn, cms_id, ins_type_code, x12_receiver_id, x12_default_partner_id, alt_cms_id)
SELECT next_ic.np, 'Aseguradora del Litoral', NULL, '31911', 3, '0', NULL, ''
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM insurance_companies) next_ic
WHERE NOT EXISTS (SELECT 1 FROM insurance_companies WHERE name = 'Aseguradora del Litoral');

INSERT INTO insurance_companies (id, name, attn, cms_id, ins_type_code, x12_receiver_id, x12_default_partner_id, alt_cms_id)
SELECT next_ic.np, 'Seguros Bolívar Salud', NULL, '93740', 3, '9675', NULL, ''
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM insurance_companies) next_ic
WHERE NOT EXISTS (SELECT 1 FROM insurance_companies WHERE name = 'Seguros Bolívar Salud');

INSERT INTO insurance_companies (id, name, attn, cms_id, ins_type_code, x12_receiver_id, x12_default_partner_id, alt_cms_id)
SELECT next_ic.np, 'Planes de Salud Unidos', NULL, '66445', 3, '8134', NULL, ''
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM insurance_companies) next_ic
WHERE NOT EXISTS (SELECT 1 FROM insurance_companies WHERE name = 'Planes de Salud Unidos');

INSERT INTO insurance_companies (id, name, attn, cms_id, ins_type_code, x12_receiver_id, x12_default_partner_id, alt_cms_id)
SELECT next_ic.np, 'Cobertura Nacional S.A.', NULL, '92777', 3, '9675', NULL, ''
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM insurance_companies) next_ic
WHERE NOT EXISTS (SELECT 1 FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.');


-- ============================================================
-- I. x12_partners - clearinghouse partners
-- ============================================================
-- Same MAX(id)+1 allocation and name guard as section H. The ISA
-- columns not listed here are NOT NULL with defaults, so they are
-- left to the schema.

INSERT INTO x12_partners (id, name, id_number, x12_sender_id, x12_receiver_id, processing_format, x12_isa05, x12_isa07, x12_isa14, x12_isa15, x12_gs02, x12_per06)
SELECT next_x12.np, 'Integradores del Sur S.A.', '830682610', 'DemoClinc123', '0', 'cms', 'ZZ', '01', '1', 'P', 'AV07121', 'P3524'
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM x12_partners) next_x12
WHERE NOT EXISTS (SELECT 1 FROM x12_partners WHERE name = 'Integradores del Sur S.A.');

INSERT INTO x12_partners (id, name, id_number, x12_sender_id, x12_receiver_id, processing_format, x12_isa05, x12_isa07, x12_isa14, x12_isa15, x12_gs02, x12_per06)
SELECT next_x12.np, 'Red Integradora Regional', '830682610', 'DemoClinc123', '0', 'cms', 'ZZ', '01', '1', 'P', 'AV02771', 'P9413'
FROM (SELECT COALESCE(MAX(id), 0) + 1 AS np FROM x12_partners) next_x12
WHERE NOT EXISTS (SELECT 1 FROM x12_partners WHERE name = 'Red Integradora Regional');


-- ============================================================
-- J. insurance_data - coverage per patient
-- ============================================================
-- id is AUTO_INCREMENT and omitted. pid is resolved from pubpid and
-- provider from the carrier name, so no id is hardcoded. Every
-- subscriber_relationship in the source is 'self', so subscriber
-- details are copied from the patient. Guard is (pid, type): each
-- patient holds one primary, one secondary and one tertiary row.

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '389927515', '853493137', 'Bustamante Vega', '', 'María Elena', 'self', '62197530', '1932-5-22', 'Av. Independencia 2569', '10916', 'Punta Serena', 'Costa Sur', 'OPS', '(03) 3114-8954', 'Servicios Bolívar S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-001'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '323528062', '658789452', 'Bustamante Vega', '', 'María Elena', 'self', '62197530', '1932-5-22', 'Av. Independencia 2569', '10916', 'Punta Serena', 'Costa Sur', 'OPS', '(03) 3114-8954', 'Servicios Bolívar S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-001'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '64022991', '740002262', 'Bustamante Vega', '', 'María Elena', 'self', '62197530', '1932-5-22', 'Av. Independencia 2569', '10916', 'Punta Serena', 'Costa Sur', 'OPS', '(03) 3114-8954', 'Servicios Bolívar S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-001'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '284738873', '181771512', 'Moreno Sánchez', '', 'Elena', 'self', '41856149', '1931-6-4', 'Calle Sucre 3168', '60317', 'San Cristóbal', 'Costa Sur', 'OPS', '(06) 4877-6762', 'Ferretería Central', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-002'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '202259919', '133613337', 'Moreno Sánchez', '', 'Elena', 'self', '41856149', '1931-6-4', 'Calle Sucre 3168', '60317', 'San Cristóbal', 'Costa Sur', 'OPS', '(06) 4877-6762', 'Ferretería Central', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-002'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '329519959', '396411517', 'Moreno Sánchez', '', 'Elena', 'self', '41856149', '1931-6-4', 'Calle Sucre 3168', '60317', 'San Cristóbal', 'Costa Sur', 'OPS', '(06) 4877-6762', 'Ferretería Central', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-002'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '738425177', '577437489', 'Bustamante García', '', 'Carmen Beatriz', 'self', '53183612', '2007-5-22', 'Calle Colón 4940', '61621', 'San Rafael', 'Norte', 'OPS', '(04) 3002-3325', 'Cooperativa Los Robles', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-003'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '558171333', '330173085', 'Bustamante García', '', 'Carmen Beatriz', 'self', '53183612', '2007-5-22', 'Calle Colón 4940', '61621', 'San Rafael', 'Norte', 'OPS', '(04) 3002-3325', 'Cooperativa Los Robles', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-003'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '911030382', '516212438', 'Bustamante García', '', 'Carmen Beatriz', 'self', '53183612', '2007-5-22', 'Calle Colón 4940', '61621', 'San Rafael', 'Norte', 'OPS', '(04) 3002-3325', 'Cooperativa Los Robles', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-003'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '331953899', '710865222', 'Delgado Fuentes', '', 'Consuelo Fernanda', 'self', '90897683', '1973-8-5', 'Jr. Bolívar 2651', '63941', 'Valle Verde', 'Valle', 'OPS', '(05) 6691-5235', 'Textiles del Valle S.A.', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-004'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '463100003', '477977988', 'Delgado Fuentes', '', 'Consuelo Fernanda', 'self', '90897683', '1973-8-5', 'Jr. Bolívar 2651', '63941', 'Valle Verde', 'Valle', 'OPS', '(05) 6691-5235', 'Textiles del Valle S.A.', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-004'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '17892763', '714029179', 'Delgado Fuentes', '', 'Consuelo Fernanda', 'self', '90897683', '1973-8-5', 'Jr. Bolívar 2651', '63941', 'Valle Verde', 'Valle', 'OPS', '(05) 6691-5235', 'Textiles del Valle S.A.', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-004'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', 0, '0', '400864978', '325046278', 'Ortiz Vega', '', 'Elena', 'self', '40663282', '2003-2-11', 'Carrera 62 No. 97-14', '59982', 'Nueva Aurora', 'Oriente', 'OPS', '(09) 3705-9765', 'Comercial San Miguel', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-005'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '655354896', '924686982', 'Ortiz Vega', '', 'Elena', 'self', '40663282', '2003-2-11', 'Carrera 62 No. 97-14', '59982', 'Nueva Aurora', 'Oriente', 'OPS', '(09) 3705-9765', 'Comercial San Miguel', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-005'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '13008306', '147243731', 'Ortiz Vega', '', 'Elena', 'self', '40663282', '2003-2-11', 'Carrera 62 No. 97-14', '59982', 'Nueva Aurora', 'Oriente', 'OPS', '(09) 3705-9765', 'Comercial San Miguel', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-005'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '473633295', '512918028', 'Ramírez Gutiérrez', '', 'Marcela Fernanda', 'self', '11171765', '1965-6-9', 'Av. Libertador 2092', '77317', 'San Rafael', 'Norte', 'OPS', '(03) 6521-8482', 'Pesquera Costa Sur', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-006'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '86615669', '249555883', 'Ramírez Gutiérrez', '', 'Marcela Fernanda', 'self', '11171765', '1965-6-9', 'Av. Libertador 2092', '77317', 'San Rafael', 'Norte', 'OPS', '(03) 6521-8482', 'Pesquera Costa Sur', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-006'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '432855620', '166474891', 'Ramírez Gutiérrez', '', 'Marcela Fernanda', 'self', '11171765', '1965-6-9', 'Av. Libertador 2092', '77317', 'San Rafael', 'Norte', 'OPS', '(03) 6521-8482', 'Pesquera Costa Sur', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-006'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '746800909', '729337980', 'Campos Ramos', '', 'Emilio', 'self', '94749844', '2010-11-6', 'Av. Central 3142', '31963', 'Ciudad Bolívar', 'Norte', 'OPS', '(08) 6031-1495', 'Servicios Bolívar S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-007'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '846765346', '975823020', 'Campos Ramos', '', 'Emilio', 'self', '94749844', '2010-11-6', 'Av. Central 3142', '31963', 'Ciudad Bolívar', 'Norte', 'OPS', '(08) 6031-1495', 'Servicios Bolívar S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-007'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '185051665', '715199402', 'Campos Ramos', '', 'Emilio', 'self', '94749844', '2010-11-6', 'Av. Central 3142', '31963', 'Ciudad Bolívar', 'Norte', 'OPS', '(08) 6031-1495', 'Servicios Bolívar S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-007'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '744427321', '440327514', 'Contreras Silva', '', 'Tomás Alberto', 'self', '85104216', '1967-11-15', 'Jr. Bolívar 4404', '21540', 'Puerto Alegre', 'Litoral', 'OPS', '(07) 3080-4628', 'Minera Punta Serena', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-008'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '261447770', '891771116', 'Contreras Silva', '', 'Tomás Alberto', 'self', '85104216', '1967-11-15', 'Jr. Bolívar 4404', '21540', 'Puerto Alegre', 'Litoral', 'OPS', '(07) 3080-4628', 'Minera Punta Serena', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-008'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '344341751', '497591716', 'Contreras Silva', '', 'Tomás Alberto', 'self', '85104216', '1967-11-15', 'Jr. Bolívar 4404', '21540', 'Puerto Alegre', 'Litoral', 'OPS', '(07) 3080-4628', 'Minera Punta Serena', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-008'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '782197416', '738952580', 'Cárdenas Álvarez', '', 'Ángela Fernanda', 'self', '71471851', '1997-1-21', 'Calle Sucre 3170', '31034', 'Santa Lucía', 'Central', 'OPS', '(06) 8396-7209', 'Minera Punta Serena', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-009'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '259749209', '824828561', 'Cárdenas Álvarez', '', 'Ángela Fernanda', 'self', '71471851', '1997-1-21', 'Calle Sucre 3170', '31034', 'Santa Lucía', 'Central', 'OPS', '(06) 8396-7209', 'Minera Punta Serena', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-009'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '241454682', '142758537', 'Cárdenas Álvarez', '', 'Ángela Fernanda', 'self', '71471851', '1997-1-21', 'Calle Sucre 3170', '31034', 'Santa Lucía', 'Central', 'OPS', '(06) 8396-7209', 'Minera Punta Serena', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-009'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '754576954', '454406186', 'Cárdenas Gutiérrez', '', 'Adriana Isabel', 'self', '65237414', '1974-3-27', 'Av. San Martín 4552', '39833', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6326-2303', 'Ferretería Central', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-010'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '372469215', '325838232', 'Cárdenas Gutiérrez', '', 'Adriana Isabel', 'self', '65237414', '1974-3-27', 'Av. San Martín 4552', '39833', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6326-2303', 'Ferretería Central', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-010'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '460176478', '27562672', 'Cárdenas Gutiérrez', '', 'Adriana Isabel', 'self', '65237414', '1974-3-27', 'Av. San Martín 4552', '39833', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6326-2303', 'Ferretería Central', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-010'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '397456339', '264883654', 'Ramos Herrera', '', 'José Enrique', 'self', '78418567', '2009-6-27', 'Calle 72 No. 64-16', '10790', 'Valle Verde', 'Valle', 'OPS', '(05) 3381-8171', 'Comercial San Miguel', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-011'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '618364635', '465041236', 'Ramos Herrera', '', 'José Enrique', 'self', '78418567', '2009-6-27', 'Calle 72 No. 64-16', '10790', 'Valle Verde', 'Valle', 'OPS', '(05) 3381-8171', 'Comercial San Miguel', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-011'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '668001887', '489703165', 'Ramos Herrera', '', 'José Enrique', 'self', '78418567', '2009-6-27', 'Calle 72 No. 64-16', '10790', 'Valle Verde', 'Valle', 'OPS', '(05) 3381-8171', 'Comercial San Miguel', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-011'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '270032660', '302114327', 'Jiménez López', '', 'Teresa', 'self', '40326096', '1939-5-9', 'Calle Sucre 2975', '26882', 'Santa Lucía', 'Central', 'OPS', '(08) 6850-5864', 'Alimentos La Esperanza', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-012'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '447981436', '313741363', 'Jiménez López', '', 'Teresa', 'self', '40326096', '1939-5-9', 'Calle Sucre 2975', '26882', 'Santa Lucía', 'Central', 'OPS', '(08) 6850-5864', 'Alimentos La Esperanza', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-012'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '840871670', '53869977', 'Jiménez López', '', 'Teresa', 'self', '40326096', '1939-5-9', 'Calle Sucre 2975', '26882', 'Santa Lucía', 'Central', 'OPS', '(08) 6850-5864', 'Alimentos La Esperanza', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-012'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '258317977', '419680030', 'Rodríguez Núñez', '', 'Fernanda Isabel', 'self', '16238184', '1988-1-11', 'Calle Colón 3805', '50067', 'Villa Nueva', 'Litoral', 'OPS', '(05) 5775-8374', 'Agroindustrias del Norte', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-013'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '214343494', '764259550', 'Rodríguez Núñez', '', 'Fernanda Isabel', 'self', '16238184', '1988-1-11', 'Calle Colón 3805', '50067', 'Villa Nueva', 'Litoral', 'OPS', '(05) 5775-8374', 'Agroindustrias del Norte', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-013'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '822180079', '713693855', 'Rodríguez Núñez', '', 'Fernanda Isabel', 'self', '16238184', '1988-1-11', 'Calle Colón 3805', '50067', 'Villa Nueva', 'Litoral', 'OPS', '(05) 5775-8374', 'Agroindustrias del Norte', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-013'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '593420560', '519870795', 'Herrera Romero', '', 'Óscar', 'self', '40744850', '1934-11-18', 'Av. Las Américas 4152', '71102', 'San Cristóbal', 'Costa Sur', 'OPS', '(09) 7664-8410', 'Agroindustrias del Norte', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-014'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '161012878', '622376634', 'Herrera Romero', '', 'Óscar', 'self', '40744850', '1934-11-18', 'Av. Las Américas 4152', '71102', 'San Cristóbal', 'Costa Sur', 'OPS', '(09) 7664-8410', 'Agroindustrias del Norte', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-014'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '514591967', '776906666', 'Herrera Romero', '', 'Óscar', 'self', '40744850', '1934-11-18', 'Av. Las Américas 4152', '71102', 'San Cristóbal', 'Costa Sur', 'OPS', '(09) 7664-8410', 'Agroindustrias del Norte', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-014'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '900570928', '64179239', 'Flores Guerrero', '', 'Julia Fernanda', 'self', '70640090', '1989-3-4', 'Calle 94 No. 23-68', '31660', 'La Esperanza', 'Oriente', 'OPS', '(06) 7523-5159', 'Editorial Nueva Aurora', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-015'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '493185051', '335967345', 'Flores Guerrero', '', 'Julia Fernanda', 'self', '70640090', '1989-3-4', 'Calle 94 No. 23-68', '31660', 'La Esperanza', 'Oriente', 'OPS', '(06) 7523-5159', 'Editorial Nueva Aurora', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-015'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '319709431', '538011726', 'Flores Guerrero', '', 'Julia Fernanda', 'self', '70640090', '1989-3-4', 'Calle 94 No. 23-68', '31660', 'La Esperanza', 'Oriente', 'OPS', '(06) 7523-5159', 'Editorial Nueva Aurora', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-015'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora Andina S.A.'), 'Aseguradora Andina S.A.', '573119378', '140673280', 'Sánchez Guerrero', '', 'Felipe Enrique', 'self', '55792334', '1967-9-25', 'Calle 12 No. 20-95', '42874', 'Valle Verde', 'Valle', 'OPS', '(09) 5290-4223', 'Editorial Nueva Aurora', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-016'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '101914782', '642535423', 'Sánchez Guerrero', '', 'Felipe Enrique', 'self', '55792334', '1967-9-25', 'Calle 12 No. 20-95', '42874', 'Valle Verde', 'Valle', 'OPS', '(09) 5290-4223', 'Editorial Nueva Aurora', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-016'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '228515486', '440134308', 'Sánchez Guerrero', '', 'Felipe Enrique', 'self', '55792334', '1967-9-25', 'Calle 12 No. 20-95', '42874', 'Valle Verde', 'Valle', 'OPS', '(09) 5290-4223', 'Editorial Nueva Aurora', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-016'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '295973676', '938253614', 'Sandoval Acosta', '', 'Silvia Cristina', 'self', '91456339', '1942-6-26', 'Jr. Bolívar 4404', '11730', 'Santa Lucía', 'Central', 'OPS', '(09) 8938-7508', 'Alimentos La Esperanza', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-017'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '416581910', '678060023', 'Sandoval Acosta', '', 'Silvia Cristina', 'self', '91456339', '1942-6-26', 'Jr. Bolívar 4404', '11730', 'Santa Lucía', 'Central', 'OPS', '(09) 8938-7508', 'Alimentos La Esperanza', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-017'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '690678062', '347565125', 'Sandoval Acosta', '', 'Silvia Cristina', 'self', '91456339', '1942-6-26', 'Jr. Bolívar 4404', '11730', 'Santa Lucía', 'Central', 'OPS', '(09) 8938-7508', 'Alimentos La Esperanza', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-017'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', 0, '0', '296202259', '287791157', 'Miranda Romero', '', 'Daniela Victoria', 'self', '30831629', '1933-8-21', 'Av. Independencia 2624', '29974', 'Ciudad Bolívar', 'Norte', 'OPS', '(03) 5814-1311', 'Ferretería Central', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-018'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '970992343', '480642401', 'Miranda Romero', '', 'Daniela Victoria', 'self', '30831629', '1933-8-21', 'Av. Independencia 2624', '29974', 'Ciudad Bolívar', 'Norte', 'OPS', '(03) 5814-1311', 'Ferretería Central', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-018'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '61777519', '419485685', 'Miranda Romero', '', 'Daniela Victoria', 'self', '30831629', '1933-8-21', 'Av. Independencia 2624', '29974', 'Ciudad Bolívar', 'Norte', 'OPS', '(03) 5814-1311', 'Ferretería Central', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-018'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', 0, '0', '362600998', '302980919', 'Vargas Molina', '', 'Jorge Antonio', 'self', '73674143', '1930-4-25', 'Carrera 5 No. 53-96', '12910', 'Ciudad Bolívar', 'Norte', 'OPS', '(03) 2086-9338', 'Editorial Nueva Aurora', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-019'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '433391351', '806403733', 'Vargas Molina', '', 'Jorge Antonio', 'self', '73674143', '1930-4-25', 'Carrera 5 No. 53-96', '12910', 'Ciudad Bolívar', 'Norte', 'OPS', '(03) 2086-9338', 'Editorial Nueva Aurora', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-019'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '250570574', '866463616', 'Vargas Molina', '', 'Jorge Antonio', 'self', '73674143', '1930-4-25', 'Carrera 5 No. 53-96', '12910', 'Ciudad Bolívar', 'Norte', 'OPS', '(03) 2086-9338', 'Editorial Nueva Aurora', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-019'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora Andina S.A.'), 'Aseguradora Andina S.A.', '459888190', '731913418', 'Vega Hernández', '', 'Valentina del Carmen', 'self', '75545029', '1948-11-12', 'Jr. Bolívar 4908', '24778', 'La Esperanza', 'Oriente', 'OPS', '(06) 2331-4849', 'Constructora Andina', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-020'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '551794416', '61804685', 'Vega Hernández', '', 'Valentina del Carmen', 'self', '75545029', '1948-11-12', 'Jr. Bolívar 4908', '24778', 'La Esperanza', 'Oriente', 'OPS', '(06) 2331-4849', 'Constructora Andina', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-020'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '837834822', '390783486', 'Vega Hernández', '', 'Valentina del Carmen', 'self', '75545029', '1948-11-12', 'Jr. Bolívar 4908', '24778', 'La Esperanza', 'Oriente', 'OPS', '(06) 2331-4849', 'Constructora Andina', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-020'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '446813084', '742847333', 'Romero Molina', '', 'Daniela del Carmen', 'self', '95448467', '1937-8-14', 'Pasaje Las Palmas 1648', '60841', 'Santa Lucía', 'Central', 'OPS', '(06) 7283-2637', 'Minera Punta Serena', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-021'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '495839013', '96831030', 'Romero Molina', '', 'Daniela del Carmen', 'self', '95448467', '1937-8-14', 'Pasaje Las Palmas 1648', '60841', 'Santa Lucía', 'Central', 'OPS', '(06) 7283-2637', 'Minera Punta Serena', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-021'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '606737730', '851099119', 'Romero Molina', '', 'Daniela del Carmen', 'self', '95448467', '1937-8-14', 'Pasaje Las Palmas 1648', '60841', 'Santa Lucía', 'Central', 'OPS', '(06) 7283-2637', 'Minera Punta Serena', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-021'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '737263677', '518156756', 'Aguilar Ramos', '', 'Rosa', 'self', '31485237', '1935-10-16', 'Pasaje Las Palmas 3426', '62756', 'Nueva Aurora', 'Oriente', 'OPS', '(02) 2182-2269', 'Ferretería Central', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-022'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '514551861', '488224186', 'Aguilar Ramos', '', 'Rosa', 'self', '31485237', '1935-10-16', 'Pasaje Las Palmas 3426', '62756', 'Nueva Aurora', 'Oriente', 'OPS', '(02) 2182-2269', 'Ferretería Central', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-022'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '927299376', '403956992', 'Aguilar Ramos', '', 'Rosa', 'self', '31485237', '1935-10-16', 'Pasaje Las Palmas 3426', '62756', 'Nueva Aurora', 'Oriente', 'OPS', '(02) 2182-2269', 'Ferretería Central', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-022'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '712810341', '259306986', 'Gómez Hernández', '', 'Raquel Elena', 'self', '31227397', '1966-6-26', 'Av. San Martín 1529', '17929', 'Villa Nueva', 'Litoral', 'OPS', '(05) 5771-5900', 'Textiles del Valle S.A.', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-023'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '102580841', '297621528', 'Gómez Hernández', '', 'Raquel Elena', 'self', '31227397', '1966-6-26', 'Av. San Martín 1529', '17929', 'Villa Nueva', 'Litoral', 'OPS', '(05) 5771-5900', 'Textiles del Valle S.A.', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-023'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '928321887', '82958942', 'Gómez Hernández', '', 'Raquel Elena', 'self', '31227397', '1966-6-26', 'Av. San Martín 1529', '17929', 'Villa Nueva', 'Litoral', 'OPS', '(05) 5771-5900', 'Textiles del Valle S.A.', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-023'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '746014746', '14988704', 'Moreno Torres', '', 'Juan', 'self', '21967648', '1978-4-22', 'Calle Colón 632', '18029', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6949-3827', 'Cooperativa Los Robles', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-024'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '681709914', '921236062', 'Moreno Torres', '', 'Juan', 'self', '21967648', '1978-4-22', 'Calle Colón 632', '18029', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6949-3827', 'Cooperativa Los Robles', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-024'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '429839025', '150167399', 'Moreno Torres', '', 'Juan', 'self', '21967648', '1978-4-22', 'Calle Colón 632', '18029', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6949-3827', 'Cooperativa Los Robles', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-024'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '622503774', '268847072', 'Miranda Cruz', '', 'Tomás', 'self', '67949190', '1964-2-21', 'Av. Libertador 3821', '76872', 'Villa Nueva', 'Litoral', 'OPS', '(08) 7989-8883', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-025'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '37307219', '818259262', 'Miranda Cruz', '', 'Tomás', 'self', '67949190', '1964-2-21', 'Av. Libertador 3821', '76872', 'Villa Nueva', 'Litoral', 'OPS', '(08) 7989-8883', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-025'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '616823064', '12523469', 'Miranda Cruz', '', 'Tomás', 'self', '67949190', '1964-2-21', 'Av. Libertador 3821', '76872', 'Villa Nueva', 'Litoral', 'OPS', '(08) 7989-8883', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-025'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '186675683', '23879249', 'Mendoza Navarro', '', 'Julián Ramón', 'self', '13519970', '1976-4-9', 'Av. San Martín 3572', '68366', 'Nueva Aurora', 'Oriente', 'OPS', '(04) 5366-5532', 'Ferretería Central', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-026'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '544594724', '740533389', 'Mendoza Navarro', '', 'Julián Ramón', 'self', '13519970', '1976-4-9', 'Av. San Martín 3572', '68366', 'Nueva Aurora', 'Oriente', 'OPS', '(04) 5366-5532', 'Ferretería Central', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-026'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '321951606', '549967899', 'Mendoza Navarro', '', 'Julián Ramón', 'self', '13519970', '1976-4-9', 'Av. San Martín 3572', '68366', 'Nueva Aurora', 'Oriente', 'OPS', '(04) 5366-5532', 'Ferretería Central', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-026'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '142232328', '760516436', 'Rivera Gómez', '', 'Dolores Victoria', 'self', '89811953', '1961-2-19', 'Av. San Martín 4390', '61797', 'Valle Verde', 'Valle', 'OPS', '(02) 4161-5268', 'Cooperativa Los Robles', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-027'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '423486060', '93053433', 'Rivera Gómez', '', 'Dolores Victoria', 'self', '89811953', '1961-2-19', 'Av. San Martín 4390', '61797', 'Valle Verde', 'Valle', 'OPS', '(02) 4161-5268', 'Cooperativa Los Robles', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-027'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '321079897', '218324778', 'Rivera Gómez', '', 'Dolores Victoria', 'self', '89811953', '1961-2-19', 'Av. San Martín 4390', '61797', 'Valle Verde', 'Valle', 'OPS', '(02) 4161-5268', 'Cooperativa Los Robles', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-027'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '534460939', '696162293', 'Martínez Miranda', '', 'María de los Ángeles', 'self', '12253329', '1989-3-4', 'Pasaje Las Palmas 4206', '59364', 'Ciudad Bolívar', 'Norte', 'OPS', '(05) 3754-7723', 'Textiles del Valle S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-028'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '644997192', '39582378', 'Martínez Miranda', '', 'María de los Ángeles', 'self', '12253329', '1989-3-4', 'Pasaje Las Palmas 4206', '59364', 'Ciudad Bolívar', 'Norte', 'OPS', '(05) 3754-7723', 'Textiles del Valle S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-028'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '336043891', '680186079', 'Martínez Miranda', '', 'María de los Ángeles', 'self', '12253329', '1989-3-4', 'Pasaje Las Palmas 4206', '59364', 'Ciudad Bolívar', 'Norte', 'OPS', '(05) 3754-7723', 'Textiles del Valle S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-028'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '243425309', '951180634', 'Paredes Fuentes', '', 'Eduardo Antonio', 'self', '78289270', '1970-8-7', 'Calle Los Pinos 1123', '45400', 'Nueva Aurora', 'Oriente', 'OPS', '(05) 7824-3094', 'Textiles del Valle S.A.', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-029'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '429694541', '234701319', 'Paredes Fuentes', '', 'Eduardo Antonio', 'self', '78289270', '1970-8-7', 'Calle Los Pinos 1123', '45400', 'Nueva Aurora', 'Oriente', 'OPS', '(05) 7824-3094', 'Textiles del Valle S.A.', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-029'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '222384940', '199704703', 'Paredes Fuentes', '', 'Eduardo Antonio', 'self', '78289270', '1970-8-7', 'Calle Los Pinos 1123', '45400', 'Nueva Aurora', 'Oriente', 'OPS', '(05) 7824-3094', 'Textiles del Valle S.A.', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-029'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '973455524', '738911629', 'Flores Peña', '', 'Andrés Alberto', 'self', '16929162', '1970-5-19', 'Jr. Bolívar 2233', '28539', 'Villa Nueva', 'Litoral', 'OPS', '(04) 7625-4027', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-030'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '10754365', '381435488', 'Flores Peña', '', 'Andrés Alberto', 'self', '16929162', '1970-5-19', 'Jr. Bolívar 2233', '28539', 'Villa Nueva', 'Litoral', 'OPS', '(04) 7625-4027', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-030'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '61124543', '65948150', 'Flores Peña', '', 'Andrés Alberto', 'self', '16929162', '1970-5-19', 'Jr. Bolívar 2233', '28539', 'Villa Nueva', 'Litoral', 'OPS', '(04) 7625-4027', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-030'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '117259282', '115360352', 'Rojas Navarro', '', 'Ana Isabel', 'self', '74913182', '1985-1-10', 'Av. San Martín 4630', '53044', 'Puerto Alegre', 'Litoral', 'OPS', '(08) 5882-8958', 'Agroindustrias del Norte', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-031'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '3185909', '570918886', 'Rojas Navarro', '', 'Ana Isabel', 'self', '74913182', '1985-1-10', 'Av. San Martín 4630', '53044', 'Puerto Alegre', 'Litoral', 'OPS', '(08) 5882-8958', 'Agroindustrias del Norte', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-031'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '129092993', '144498180', 'Rojas Navarro', '', 'Ana Isabel', 'self', '74913182', '1985-1-10', 'Av. San Martín 4630', '53044', 'Puerto Alegre', 'Litoral', 'OPS', '(08) 5882-8958', 'Agroindustrias del Norte', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-031'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '181288199', '474817538', 'Flores Moreno', '', 'Adriana Victoria', 'self', '99268762', '1956-1-18', 'Av. San Martín 3665', '23489', 'Villa Nueva', 'Litoral', 'OPS', '(07) 7438-7568', 'Transportes Litoral S.A.', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-032'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '851485864', '707694971', 'Flores Moreno', '', 'Adriana Victoria', 'self', '99268762', '1956-1-18', 'Av. San Martín 3665', '23489', 'Villa Nueva', 'Litoral', 'OPS', '(07) 7438-7568', 'Transportes Litoral S.A.', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-032'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '592339801', '270417210', 'Flores Moreno', '', 'Adriana Victoria', 'self', '99268762', '1956-1-18', 'Av. San Martín 3665', '23489', 'Villa Nueva', 'Litoral', 'OPS', '(07) 7438-7568', 'Transportes Litoral S.A.', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-032'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '679756716', '152309318', 'García Rodríguez', '', 'Emilio', 'self', '49854185', '1930-6-10', 'Pasaje Las Palmas 732', '65764', 'Santa Lucía', 'Central', 'OPS', '(04) 3547-2812', 'Cooperativa Los Robles', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-033'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '969091553', '53630329', 'García Rodríguez', '', 'Emilio', 'self', '49854185', '1930-6-10', 'Pasaje Las Palmas 732', '65764', 'Santa Lucía', 'Central', 'OPS', '(04) 3547-2812', 'Cooperativa Los Robles', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-033'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '492514768', '291882827', 'García Rodríguez', '', 'Emilio', 'self', '49854185', '1930-6-10', 'Pasaje Las Palmas 732', '65764', 'Santa Lucía', 'Central', 'OPS', '(04) 3547-2812', 'Cooperativa Los Robles', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-033'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '992850393', '942989082', 'Moreno Molina', '', 'Esperanza de los Ángeles', 'self', '24833333', '1943-6-18', 'Av. Las Américas 1240', '29555', 'Punta Serena', 'Costa Sur', 'OPS', '(02) 5067-1179', 'Textiles del Valle S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-034'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '766918427', '545505794', 'Moreno Molina', '', 'Esperanza de los Ángeles', 'self', '24833333', '1943-6-18', 'Av. Las Américas 1240', '29555', 'Punta Serena', 'Costa Sur', 'OPS', '(02) 5067-1179', 'Textiles del Valle S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-034'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '459415304', '133817730', 'Moreno Molina', '', 'Esperanza de los Ángeles', 'self', '24833333', '1943-6-18', 'Av. Las Américas 1240', '29555', 'Punta Serena', 'Costa Sur', 'OPS', '(02) 5067-1179', 'Textiles del Valle S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-034'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '220314361', '203005085', 'Sánchez Campos', '', 'Verónica', 'self', '39346430', '1972-11-17', 'Av. Central 685', '13387', 'Punta Serena', 'Costa Sur', 'OPS', '(04) 9954-8510', 'Textiles del Valle S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-035'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '757351173', '110812730', 'Sánchez Campos', '', 'Verónica', 'self', '39346430', '1972-11-17', 'Av. Central 685', '13387', 'Punta Serena', 'Costa Sur', 'OPS', '(04) 9954-8510', 'Textiles del Valle S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-035'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '902325150', '756648526', 'Sánchez Campos', '', 'Verónica', 'self', '39346430', '1972-11-17', 'Av. Central 685', '13387', 'Punta Serena', 'Costa Sur', 'OPS', '(04) 9954-8510', 'Textiles del Valle S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-035'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '893430111', '662636389', 'González Campos', '', 'Valentina Victoria', 'self', '78845536', '1944-7-19', 'Av. Independencia 4506', '51967', 'Santa Lucía', 'Central', 'OPS', '(06) 5548-6362', 'Constructora Andina', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-036'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '933915717', '165976085', 'González Campos', '', 'Valentina Victoria', 'self', '78845536', '1944-7-19', 'Av. Independencia 4506', '51967', 'Santa Lucía', 'Central', 'OPS', '(06) 5548-6362', 'Constructora Andina', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-036'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '42727705', '222675783', 'González Campos', '', 'Valentina Victoria', 'self', '78845536', '1944-7-19', 'Av. Independencia 4506', '51967', 'Santa Lucía', 'Central', 'OPS', '(06) 5548-6362', 'Constructora Andina', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-036'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '353674114', '311912242', 'Moreno Castillo', '', 'Daniela del Carmen', 'self', '66011279', '1992-9-10', 'Av. Independencia 811', '33782', 'San Cristóbal', 'Costa Sur', 'OPS', '(08) 2919-8141', 'Cooperativa Los Robles', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-037'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '612549339', '285850699', 'Moreno Castillo', '', 'Daniela del Carmen', 'self', '66011279', '1992-9-10', 'Av. Independencia 811', '33782', 'San Cristóbal', 'Costa Sur', 'OPS', '(08) 2919-8141', 'Cooperativa Los Robles', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-037'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '868082366', '653582502', 'Moreno Castillo', '', 'Daniela del Carmen', 'self', '66011279', '1992-9-10', 'Av. Independencia 811', '33782', 'San Cristóbal', 'Costa Sur', 'OPS', '(08) 2919-8141', 'Cooperativa Los Robles', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-037'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '840127426', '983790430', 'Díaz Flores', '', 'Javier Manuel', 'self', '68939574', '1989-2-27', 'Jr. Bolívar 294', '58792', 'Puerto Alegre', 'Litoral', 'OPS', '(09) 3085-7660', 'Minera Punta Serena', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-038'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '230905633', '533186941', 'Díaz Flores', '', 'Javier Manuel', 'self', '68939574', '1989-2-27', 'Jr. Bolívar 294', '58792', 'Puerto Alegre', 'Litoral', 'OPS', '(09) 3085-7660', 'Minera Punta Serena', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-038'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '931766035', '929042588', 'Díaz Flores', '', 'Javier Manuel', 'self', '68939574', '1989-2-27', 'Jr. Bolívar 294', '58792', 'Puerto Alegre', 'Litoral', 'OPS', '(09) 3085-7660', 'Minera Punta Serena', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-038'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', 0, '0', '975562981', '910055534', 'Díaz Acosta', '', 'Patricia Isabel', 'self', '34323362', '2004-4-5', 'Calle 83 No. 70-35', '41407', 'Nueva Aurora', 'Oriente', 'OPS', '(04) 9590-6135', 'Alimentos La Esperanza', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-039'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '729595247', '601028280', 'Díaz Acosta', '', 'Patricia Isabel', 'self', '34323362', '2004-4-5', 'Calle 83 No. 70-35', '41407', 'Nueva Aurora', 'Oriente', 'OPS', '(04) 9590-6135', 'Alimentos La Esperanza', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-039'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '309377190', '425827729', 'Díaz Acosta', '', 'Patricia Isabel', 'self', '34323362', '2004-4-5', 'Calle 83 No. 70-35', '41407', 'Nueva Aurora', 'Oriente', 'OPS', '(04) 9590-6135', 'Alimentos La Esperanza', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-039'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', 0, '0', '484242792', '76467850', 'Aguilar Vega', '', 'Marcos', 'self', '11217553', '1997-6-19', 'Carrera 69 No. 11-93', '14618', 'Puerto Alegre', 'Litoral', 'OPS', '(03) 8938-2465', 'Transportes Litoral S.A.', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-040'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '375771125', '884590307', 'Aguilar Vega', '', 'Marcos', 'self', '11217553', '1997-6-19', 'Carrera 69 No. 11-93', '14618', 'Puerto Alegre', 'Litoral', 'OPS', '(03) 8938-2465', 'Transportes Litoral S.A.', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-040'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '683194555', '633418150', 'Aguilar Vega', '', 'Marcos', 'self', '11217553', '1997-6-19', 'Carrera 69 No. 11-93', '14618', 'Puerto Alegre', 'Litoral', 'OPS', '(03) 8938-2465', 'Transportes Litoral S.A.', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-040'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '403610867', '827339740', 'Navarro Vega', '', 'Ignacio Manuel', 'self', '96082431', '2003-2-17', 'Calle 54 No. 82-50', '80798', 'San Cristóbal', 'Costa Sur', 'OPS', '(07) 5895-2547', 'Pesquera Costa Sur', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-041'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '218528896', '699242383', 'Navarro Vega', '', 'Ignacio Manuel', 'self', '96082431', '2003-2-17', 'Calle 54 No. 82-50', '80798', 'San Cristóbal', 'Costa Sur', 'OPS', '(07) 5895-2547', 'Pesquera Costa Sur', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-041'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '15753067', '519591516', 'Navarro Vega', '', 'Ignacio Manuel', 'self', '96082431', '2003-2-17', 'Calle 54 No. 82-50', '80798', 'San Cristóbal', 'Costa Sur', 'OPS', '(07) 5895-2547', 'Pesquera Costa Sur', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-041'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '292947494', '790185987', 'Quispe Cruz', '', 'María', 'self', '42047508', '1952-1-4', 'Pasaje Las Palmas 3313', '71117', 'Los Robles', 'Valle', 'OPS', '(09) 5407-3859', 'Servicios Bolívar S.A.', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-042'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '980408962', '941873349', 'Quispe Cruz', '', 'María', 'self', '42047508', '1952-1-4', 'Pasaje Las Palmas 3313', '71117', 'Los Robles', 'Valle', 'OPS', '(09) 5407-3859', 'Servicios Bolívar S.A.', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-042'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '314104070', '520400954', 'Quispe Cruz', '', 'María', 'self', '42047508', '1952-1-4', 'Pasaje Las Palmas 3313', '71117', 'Los Robles', 'Valle', 'OPS', '(09) 5407-3859', 'Servicios Bolívar S.A.', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-042'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '725313634', '722012373', 'Rojas Acosta', '', 'Mercedes de los Ángeles', 'self', '31329987', '2007-5-28', 'Calle 74 No. 36-62', '42823', 'San Rafael', 'Norte', 'OPS', '(08) 2490-5196', 'Minera Punta Serena', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-043'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '690892135', '318945705', 'Rojas Acosta', '', 'Mercedes de los Ángeles', 'self', '31329987', '2007-5-28', 'Calle 74 No. 36-62', '42823', 'San Rafael', 'Norte', 'OPS', '(08) 2490-5196', 'Minera Punta Serena', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-043'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '353620101', '699455985', 'Rojas Acosta', '', 'Mercedes de los Ángeles', 'self', '31329987', '2007-5-28', 'Calle 74 No. 36-62', '42823', 'San Rafael', 'Norte', 'OPS', '(08) 2490-5196', 'Minera Punta Serena', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-043'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '453989585', '496645611', 'Acosta Navarro', '', 'Cecilia', 'self', '83857521', '1949-11-22', 'Calle Colón 2808', '99243', 'La Esperanza', 'Oriente', 'OPS', '(03) 4212-6294', 'Ferretería Central', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-044'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '8801436', '762198806', 'Acosta Navarro', '', 'Cecilia', 'self', '83857521', '1949-11-22', 'Calle Colón 2808', '99243', 'La Esperanza', 'Oriente', 'OPS', '(03) 4212-6294', 'Ferretería Central', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-044'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '45814652', '1439069', 'Acosta Navarro', '', 'Cecilia', 'self', '83857521', '1949-11-22', 'Calle Colón 2808', '99243', 'La Esperanza', 'Oriente', 'OPS', '(03) 4212-6294', 'Ferretería Central', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-044'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '859060196', '422359489', 'Romero Salazar', '', 'Andrés', 'self', '35033091', '1991-9-6', 'Jr. Bolívar 4969', '56693', 'San Rafael', 'Norte', 'OPS', '(06) 3665-8163', 'Comercial San Miguel', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-045'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '438488345', '299730328', 'Romero Salazar', '', 'Andrés', 'self', '35033091', '1991-9-6', 'Jr. Bolívar 4969', '56693', 'San Rafael', 'Norte', 'OPS', '(06) 3665-8163', 'Comercial San Miguel', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-045'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '288804980', '102780207', 'Romero Salazar', '', 'Andrés', 'self', '35033091', '1991-9-6', 'Jr. Bolívar 4969', '56693', 'San Rafael', 'Norte', 'OPS', '(06) 3665-8163', 'Comercial San Miguel', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-045'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '722043912', '345727290', 'Torres Chávez', '', 'Adriana', 'self', '23898273', '1971-1-28', 'Av. Las Américas 4552', '76115', 'Santa Lucía', 'Central', 'OPS', '(06) 9990-2296', 'Textiles del Valle S.A.', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-046'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '311111186', '48831096', 'Torres Chávez', '', 'Adriana', 'self', '23898273', '1971-1-28', 'Av. Las Américas 4552', '76115', 'Santa Lucía', 'Central', 'OPS', '(06) 9990-2296', 'Textiles del Valle S.A.', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-046'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '311502123', '943834784', 'Torres Chávez', '', 'Adriana', 'self', '23898273', '1971-1-28', 'Av. Las Américas 4552', '76115', 'Santa Lucía', 'Central', 'OPS', '(06) 9990-2296', 'Textiles del Valle S.A.', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-046'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora Andina S.A.'), 'Aseguradora Andina S.A.', '466609785', '172047721', 'Hernández Torres', '', 'Raquel Elena', 'self', '81751856', '1955-12-5', 'Calle 31 No. 88-89', '51200', 'Valle Verde', 'Valle', 'OPS', '(07) 5457-4553', 'Cooperativa Los Robles', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-047'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '821165600', '422937826', 'Hernández Torres', '', 'Raquel Elena', 'self', '81751856', '1955-12-5', 'Calle 31 No. 88-89', '51200', 'Valle Verde', 'Valle', 'OPS', '(07) 5457-4553', 'Cooperativa Los Robles', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-047'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '792182544', '507965584', 'Hernández Torres', '', 'Raquel Elena', 'self', '81751856', '1955-12-5', 'Calle 31 No. 88-89', '51200', 'Valle Verde', 'Valle', 'OPS', '(07) 5457-4553', 'Cooperativa Los Robles', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-047'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '551220008', '743260723', 'Fuentes Cárdenas', '', 'Mauricio Javier', 'self', '37522538', '1988-12-13', 'Pasaje Las Palmas 2549', '27462', 'Ciudad Bolívar', 'Norte', 'OPS', '(02) 4542-4783', 'Constructora Andina', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-048'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '307436627', '363786786', 'Fuentes Cárdenas', '', 'Mauricio Javier', 'self', '37522538', '1988-12-13', 'Pasaje Las Palmas 2549', '27462', 'Ciudad Bolívar', 'Norte', 'OPS', '(02) 4542-4783', 'Constructora Andina', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-048'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '519543261', '488724209', 'Fuentes Cárdenas', '', 'Mauricio Javier', 'self', '37522538', '1988-12-13', 'Pasaje Las Palmas 2549', '27462', 'Ciudad Bolívar', 'Norte', 'OPS', '(02) 4542-4783', 'Constructora Andina', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-048'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '273092113', '612126521', 'González Vargas', '', 'Fernando Antonio', 'self', '13554929', '1976-4-15', 'Av. Central 3934', '61557', 'Puerto Alegre', 'Litoral', 'OPS', '(03) 3325-1773', 'Cooperativa Los Robles', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-049'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '536571740', '608754157', 'González Vargas', '', 'Fernando Antonio', 'self', '13554929', '1976-4-15', 'Av. Central 3934', '61557', 'Puerto Alegre', 'Litoral', 'OPS', '(03) 3325-1773', 'Cooperativa Los Robles', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-049'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '136637904', '627274165', 'González Vargas', '', 'Fernando Antonio', 'self', '13554929', '1976-4-15', 'Av. Central 3934', '61557', 'Puerto Alegre', 'Litoral', 'OPS', '(03) 3325-1773', 'Cooperativa Los Robles', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-049'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora Andina S.A.'), 'Aseguradora Andina S.A.', '242709475', '924053103', 'Torres Álvarez', '', 'Sofía Victoria', 'self', '30518445', '1937-8-15', 'Calle Los Pinos 1802', '94070', 'San Cristóbal', 'Costa Sur', 'OPS', '(03) 2649-3362', 'Comercial San Miguel', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-050'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '254019660', '312439536', 'Torres Álvarez', '', 'Sofía Victoria', 'self', '30518445', '1937-8-15', 'Calle Los Pinos 1802', '94070', 'San Cristóbal', 'Costa Sur', 'OPS', '(03) 2649-3362', 'Comercial San Miguel', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-050'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '712926624', '373766412', 'Torres Álvarez', '', 'Sofía Victoria', 'self', '30518445', '1937-8-15', 'Calle Los Pinos 1802', '94070', 'San Cristóbal', 'Costa Sur', 'OPS', '(03) 2649-3362', 'Comercial San Miguel', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-050'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', 0, '0', '605858718', '413179932', 'Miranda Flores', '', 'Alejandro', 'self', '60333683', '1993-9-17', 'Carrera 30 No. 76-45', '25471', 'Valle Verde', 'Valle', 'OPS', '(04) 9620-4154', 'Editorial Nueva Aurora', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-051'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '691504260', '873855215', 'Miranda Flores', '', 'Alejandro', 'self', '60333683', '1993-9-17', 'Carrera 30 No. 76-45', '25471', 'Valle Verde', 'Valle', 'OPS', '(04) 9620-4154', 'Editorial Nueva Aurora', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-051'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '733353054', '151985705', 'Miranda Flores', '', 'Alejandro', 'self', '60333683', '1993-9-17', 'Carrera 30 No. 76-45', '25471', 'Valle Verde', 'Valle', 'OPS', '(04) 9620-4154', 'Editorial Nueva Aurora', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-051'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '551446550', '204530088', 'Núñez Morales', '', 'Carmen Isabel', 'self', '13256384', '1960-5-2', 'Calle Sucre 1992', '83137', 'La Esperanza', 'Oriente', 'OPS', '(04) 6191-9242', 'Pesquera Costa Sur', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-052'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '37165459', '985322993', 'Núñez Morales', '', 'Carmen Isabel', 'self', '13256384', '1960-5-2', 'Calle Sucre 1992', '83137', 'La Esperanza', 'Oriente', 'OPS', '(04) 6191-9242', 'Pesquera Costa Sur', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-052'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '847814399', '967904004', 'Núñez Morales', '', 'Carmen Isabel', 'self', '13256384', '1960-5-2', 'Calle Sucre 1992', '83137', 'La Esperanza', 'Oriente', 'OPS', '(04) 6191-9242', 'Pesquera Costa Sur', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-052'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', 0, '0', '844677468', '512394051', 'Ortiz García', '', 'Beatriz Victoria', 'self', '76946750', '1960-5-20', 'Calle Colón 4897', '97523', 'Villa Nueva', 'Litoral', 'OPS', '(05) 3499-1270', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-053'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '592426664', '341267738', 'Ortiz García', '', 'Beatriz Victoria', 'self', '76946750', '1960-5-20', 'Calle Colón 4897', '97523', 'Villa Nueva', 'Litoral', 'OPS', '(05) 3499-1270', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-053'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '627538936', '317216241', 'Ortiz García', '', 'Beatriz Victoria', 'self', '76946750', '1960-5-20', 'Calle Colón 4897', '97523', 'Villa Nueva', 'Litoral', 'OPS', '(05) 3499-1270', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-053'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '694416238', '130321273', 'Díaz Fuentes', '', 'Mercedes Cristina', 'self', '95980408', '1944-8-19', 'Jr. Bolívar 976', '60043', 'Los Robles', 'Valle', 'OPS', '(09) 9004-8361', 'Alimentos La Esperanza', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-054'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '137773748', '899664619', 'Díaz Fuentes', '', 'Mercedes Cristina', 'self', '95980408', '1944-8-19', 'Jr. Bolívar 976', '60043', 'Los Robles', 'Valle', 'OPS', '(09) 9004-8361', 'Alimentos La Esperanza', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-054'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '857789953', '362433473', 'Díaz Fuentes', '', 'Mercedes Cristina', 'self', '95980408', '1944-8-19', 'Jr. Bolívar 976', '60043', 'Los Robles', 'Valle', 'OPS', '(09) 9004-8361', 'Alimentos La Esperanza', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-054'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '583676346', '138879818', 'Rivera Vargas', '', 'Inés', 'self', '42167099', '1965-8-3', 'Pasaje Las Palmas 4083', '76882', 'Punta Serena', 'Costa Sur', 'OPS', '(09) 6028-9360', 'Comercial San Miguel', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-055'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '927284103', '942699462', 'Rivera Vargas', '', 'Inés', 'self', '42167099', '1965-8-3', 'Pasaje Las Palmas 4083', '76882', 'Punta Serena', 'Costa Sur', 'OPS', '(09) 6028-9360', 'Comercial San Miguel', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-055'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '788624794', '856043495', 'Rivera Vargas', '', 'Inés', 'self', '42167099', '1965-8-3', 'Pasaje Las Palmas 4083', '76882', 'Punta Serena', 'Costa Sur', 'OPS', '(09) 6028-9360', 'Comercial San Miguel', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-055'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '573692105', '958815448', 'Mendoza Álvarez', '', 'Mauricio Manuel', 'self', '94753089', '1949-9-28', 'Av. San Martín 3766', '30043', 'Ciudad Bolívar', 'Norte', 'OPS', '(07) 5712-4817', 'Textiles del Valle S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-056'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '450743138', '953231750', 'Mendoza Álvarez', '', 'Mauricio Manuel', 'self', '94753089', '1949-9-28', 'Av. San Martín 3766', '30043', 'Ciudad Bolívar', 'Norte', 'OPS', '(07) 5712-4817', 'Textiles del Valle S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-056'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '242108025', '919700453', 'Mendoza Álvarez', '', 'Mauricio Manuel', 'self', '94753089', '1949-9-28', 'Av. San Martín 3766', '30043', 'Ciudad Bolívar', 'Norte', 'OPS', '(07) 5712-4817', 'Textiles del Valle S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-056'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', 0, '0', '612224391', '124620455', 'Cruz Villalobos', '', 'Elena Isabel', 'self', '42356314', '2000-8-28', 'Av. Independencia 3632', '17735', 'La Esperanza', 'Oriente', 'OPS', '(07) 5681-4565', 'Transportes Litoral S.A.', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-057'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '769648763', '773714883', 'Cruz Villalobos', '', 'Elena Isabel', 'self', '42356314', '2000-8-28', 'Av. Independencia 3632', '17735', 'La Esperanza', 'Oriente', 'OPS', '(07) 5681-4565', 'Transportes Litoral S.A.', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-057'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '627132117', '965173659', 'Cruz Villalobos', '', 'Elena Isabel', 'self', '42356314', '2000-8-28', 'Av. Independencia 3632', '17735', 'La Esperanza', 'Oriente', 'OPS', '(07) 5681-4565', 'Transportes Litoral S.A.', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-057'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', 0, '0', '497717140', '251592151', 'Miranda Vega', '', 'Mercedes del Carmen', 'self', '36837564', '1944-1-1', 'Calle Sucre 2374', '63011', 'Nueva Aurora', 'Oriente', 'OPS', '(04) 8170-8219', 'Editorial Nueva Aurora', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-058'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '134914916', '616420478', 'Miranda Vega', '', 'Mercedes del Carmen', 'self', '36837564', '1944-1-1', 'Calle Sucre 2374', '63011', 'Nueva Aurora', 'Oriente', 'OPS', '(04) 8170-8219', 'Editorial Nueva Aurora', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-058'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '710534811', '914147857', 'Miranda Vega', '', 'Mercedes del Carmen', 'self', '36837564', '1944-1-1', 'Calle Sucre 2374', '63011', 'Nueva Aurora', 'Oriente', 'OPS', '(04) 8170-8219', 'Editorial Nueva Aurora', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-058'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '165056859', '382234865', 'Silva Escobar', '', 'Marcos', 'self', '26593215', '2000-7-27', 'Calle 15 No. 66-64', '73666', 'Villa Nueva', 'Litoral', 'OPS', '(08) 8601-2991', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-059'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '868940734', '883324380', 'Silva Escobar', '', 'Marcos', 'self', '26593215', '2000-7-27', 'Calle 15 No. 66-64', '73666', 'Villa Nueva', 'Litoral', 'OPS', '(08) 8601-2991', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-059'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '315867332', '507633227', 'Silva Escobar', '', 'Marcos', 'self', '26593215', '2000-7-27', 'Calle 15 No. 66-64', '73666', 'Villa Nueva', 'Litoral', 'OPS', '(08) 8601-2991', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-059'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '21775190', '938172300', 'Sánchez Paredes', '', 'Cecilia', 'self', '79287911', '1934-8-12', 'Av. Independencia 3118', '89423', 'Puerto Alegre', 'Litoral', 'OPS', '(04) 7763-7263', 'Transportes Litoral S.A.', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-060'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '639304365', '551558560', 'Sánchez Paredes', '', 'Cecilia', 'self', '79287911', '1934-8-12', 'Av. Independencia 3118', '89423', 'Puerto Alegre', 'Litoral', 'OPS', '(04) 7763-7263', 'Transportes Litoral S.A.', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-060'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '922357073', '491255002', 'Sánchez Paredes', '', 'Cecilia', 'self', '79287911', '1934-8-12', 'Av. Independencia 3118', '89423', 'Puerto Alegre', 'Litoral', 'OPS', '(04) 7763-7263', 'Transportes Litoral S.A.', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-060'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '866684823', '705989625', 'Jiménez Ramos', '', 'Antonio Andrés', 'self', '59061302', '1931-9-7', 'Calle 30 No. 36-47', '73796', 'Villa Nueva', 'Litoral', 'OPS', '(04) 3020-5162', 'Minera Punta Serena', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-061'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '768703171', '959736334', 'Jiménez Ramos', '', 'Antonio Andrés', 'self', '59061302', '1931-9-7', 'Calle 30 No. 36-47', '73796', 'Villa Nueva', 'Litoral', 'OPS', '(04) 3020-5162', 'Minera Punta Serena', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-061'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '499464908', '92144326', 'Jiménez Ramos', '', 'Antonio Andrés', 'self', '59061302', '1931-9-7', 'Calle 30 No. 36-47', '73796', 'Villa Nueva', 'Litoral', 'OPS', '(04) 3020-5162', 'Minera Punta Serena', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-061'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '783711383', '848628032', 'Miranda Rojas', '', 'Gustavo Eduardo', 'self', '82904149', '1975-5-23', 'Carrera 42 No. 61-45', '62932', 'Villa Nueva', 'Litoral', 'OPS', '(02) 8675-2325', 'Constructora Andina', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-062'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '152326532', '277968150', 'Miranda Rojas', '', 'Gustavo Eduardo', 'self', '82904149', '1975-5-23', 'Carrera 42 No. 61-45', '62932', 'Villa Nueva', 'Litoral', 'OPS', '(02) 8675-2325', 'Constructora Andina', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-062'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '258862537', '892766922', 'Miranda Rojas', '', 'Gustavo Eduardo', 'self', '82904149', '1975-5-23', 'Carrera 42 No. 61-45', '62932', 'Villa Nueva', 'Litoral', 'OPS', '(02) 8675-2325', 'Constructora Andina', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-062'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '868927324', '618480865', 'Cruz Fuentes', '', 'Carmen', 'self', '36028342', '1988-5-10', 'Av. Las Américas 2424', '27743', 'Puerto Alegre', 'Litoral', 'OPS', '(04) 3113-1275', 'Editorial Nueva Aurora', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-063'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '434715800', '398615860', 'Cruz Fuentes', '', 'Carmen', 'self', '36028342', '1988-5-10', 'Av. Las Américas 2424', '27743', 'Puerto Alegre', 'Litoral', 'OPS', '(04) 3113-1275', 'Editorial Nueva Aurora', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-063'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '886637567', '1881952', 'Cruz Fuentes', '', 'Carmen', 'self', '36028342', '1988-5-10', 'Av. Las Américas 2424', '27743', 'Puerto Alegre', 'Litoral', 'OPS', '(04) 3113-1275', 'Editorial Nueva Aurora', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-063'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '666062907', '905389211', 'Rojas Morales', '', 'Silvia Cristina', 'self', '60868959', '1992-6-22', 'Calle 14 No. 74-59', '10090', 'La Esperanza', 'Oriente', 'OPS', '(07) 5201-1920', 'Editorial Nueva Aurora', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-064'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '849610048', '30211240', 'Rojas Morales', '', 'Silvia Cristina', 'self', '60868959', '1992-6-22', 'Calle 14 No. 74-59', '10090', 'La Esperanza', 'Oriente', 'OPS', '(07) 5201-1920', 'Editorial Nueva Aurora', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-064'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '115736765', '702934241', 'Rojas Morales', '', 'Silvia Cristina', 'self', '60868959', '1992-6-22', 'Calle 14 No. 74-59', '10090', 'La Esperanza', 'Oriente', 'OPS', '(07) 5201-1920', 'Editorial Nueva Aurora', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-064'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora Andina S.A.'), 'Aseguradora Andina S.A.', '210604483', '547180926', 'Martínez Ramos', '', 'Verónica Isabel', 'self', '62587263', '1978-6-3', 'Jr. Bolívar 2372', '58938', 'San Cristóbal', 'Costa Sur', 'OPS', '(02) 7390-1388', 'Editorial Nueva Aurora', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-065'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '687217644', '796843668', 'Martínez Ramos', '', 'Verónica Isabel', 'self', '62587263', '1978-6-3', 'Jr. Bolívar 2372', '58938', 'San Cristóbal', 'Costa Sur', 'OPS', '(02) 7390-1388', 'Editorial Nueva Aurora', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-065'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '289150626', '783713615', 'Martínez Ramos', '', 'Verónica Isabel', 'self', '62587263', '1978-6-3', 'Jr. Bolívar 2372', '58938', 'San Cristóbal', 'Costa Sur', 'OPS', '(02) 7390-1388', 'Editorial Nueva Aurora', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-065'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '985262617', '225110215', 'Hernández Escobar', '', 'Manuel', 'self', '47648067', '2004-2-9', 'Calle 79 No. 18-71', '60544', 'La Esperanza', 'Oriente', 'OPS', '(07) 7731-1424', 'Cooperativa Los Robles', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-066'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '468211167', '785789696', 'Hernández Escobar', '', 'Manuel', 'self', '47648067', '2004-2-9', 'Calle 79 No. 18-71', '60544', 'La Esperanza', 'Oriente', 'OPS', '(07) 7731-1424', 'Cooperativa Los Robles', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-066'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '65481837', '931470316', 'Hernández Escobar', '', 'Manuel', 'self', '47648067', '2004-2-9', 'Calle 79 No. 18-71', '60544', 'La Esperanza', 'Oriente', 'OPS', '(07) 7731-1424', 'Cooperativa Los Robles', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-066'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '111375079', '854857373', 'Vargas Díaz', '', 'María Cristina', 'self', '69399330', '1971-11-12', 'Jr. Bolívar 3686', '54125', 'Los Robles', 'Valle', 'OPS', '(06) 8519-8553', 'Constructora Andina', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-067'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '611318012', '100357513', 'Vargas Díaz', '', 'María Cristina', 'self', '69399330', '1971-11-12', 'Jr. Bolívar 3686', '54125', 'Los Robles', 'Valle', 'OPS', '(06) 8519-8553', 'Constructora Andina', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-067'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '154550320', '121978793', 'Vargas Díaz', '', 'María Cristina', 'self', '69399330', '1971-11-12', 'Jr. Bolívar 3686', '54125', 'Los Robles', 'Valle', 'OPS', '(06) 8519-8553', 'Constructora Andina', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-067'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '211543801', '891455191', 'Gutiérrez López', '', 'Ramón', 'self', '72553925', '1937-2-11', 'Calle 7 No. 26-87', '55431', 'Valle Verde', 'Valle', 'OPS', '(02) 6774-7330', 'Constructora Andina', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-068'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '904793944', '491114212', 'Gutiérrez López', '', 'Ramón', 'self', '72553925', '1937-2-11', 'Calle 7 No. 26-87', '55431', 'Valle Verde', 'Valle', 'OPS', '(02) 6774-7330', 'Constructora Andina', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-068'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '944858717', '758345718', 'Gutiérrez López', '', 'Ramón', 'self', '72553925', '1937-2-11', 'Calle 7 No. 26-87', '55431', 'Valle Verde', 'Valle', 'OPS', '(02) 6774-7330', 'Constructora Andina', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-068'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '732301833', '918530116', 'Bustamante López', '', 'Sofía Beatriz', 'self', '12090639', '1965-9-6', 'Av. Las Américas 4664', '90266', 'Santa Lucía', 'Central', 'OPS', '(04) 3144-5762', 'Transportes Litoral S.A.', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-069'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '454645754', '194670566', 'Bustamante López', '', 'Sofía Beatriz', 'self', '12090639', '1965-9-6', 'Av. Las Américas 4664', '90266', 'Santa Lucía', 'Central', 'OPS', '(04) 3144-5762', 'Transportes Litoral S.A.', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-069'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '91162058', '489671927', 'Bustamante López', '', 'Sofía Beatriz', 'self', '12090639', '1965-9-6', 'Av. Las Américas 4664', '90266', 'Santa Lucía', 'Central', 'OPS', '(04) 3144-5762', 'Transportes Litoral S.A.', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-069'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '664727688', '677185540', 'Castillo Villalobos', '', 'Verónica de los Ángeles', 'self', '77143453', '1998-6-26', 'Av. Las Américas 825', '94234', 'Valle Verde', 'Valle', 'OPS', '(06) 9661-2575', 'Alimentos La Esperanza', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-070'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '920190219', '952418945', 'Castillo Villalobos', '', 'Verónica de los Ángeles', 'self', '77143453', '1998-6-26', 'Av. Las Américas 825', '94234', 'Valle Verde', 'Valle', 'OPS', '(06) 9661-2575', 'Alimentos La Esperanza', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-070'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '642619573', '532442867', 'Castillo Villalobos', '', 'Verónica de los Ángeles', 'self', '77143453', '1998-6-26', 'Av. Las Américas 825', '94234', 'Valle Verde', 'Valle', 'OPS', '(06) 9661-2575', 'Alimentos La Esperanza', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-070'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '991447821', '157327607', 'López Vega', '', 'Carlos', 'self', '43851724', '1966-2-26', 'Jr. Bolívar 2138', '31854', 'Puerto Alegre', 'Litoral', 'OPS', '(08) 6694-2244', 'Minera Punta Serena', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-071'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '658038697', '495469740', 'López Vega', '', 'Carlos', 'self', '43851724', '1966-2-26', 'Jr. Bolívar 2138', '31854', 'Puerto Alegre', 'Litoral', 'OPS', '(08) 6694-2244', 'Minera Punta Serena', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-071'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '812629908', '625146480', 'López Vega', '', 'Carlos', 'self', '43851724', '1966-2-26', 'Jr. Bolívar 2138', '31854', 'Puerto Alegre', 'Litoral', 'OPS', '(08) 6694-2244', 'Minera Punta Serena', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-071'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '931327562', '348733805', 'Ramírez Peña', '', 'Natalia del Carmen', 'self', '13607092', '1959-11-14', 'Av. Independencia 1307', '68216', 'San Cristóbal', 'Costa Sur', 'OPS', '(06) 3125-3495', 'Alimentos La Esperanza', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-072'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '427113270', '259503958', 'Ramírez Peña', '', 'Natalia del Carmen', 'self', '13607092', '1959-11-14', 'Av. Independencia 1307', '68216', 'San Cristóbal', 'Costa Sur', 'OPS', '(06) 3125-3495', 'Alimentos La Esperanza', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-072'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '39668401', '58584612', 'Ramírez Peña', '', 'Natalia del Carmen', 'self', '13607092', '1959-11-14', 'Av. Independencia 1307', '68216', 'San Cristóbal', 'Costa Sur', 'OPS', '(06) 3125-3495', 'Alimentos La Esperanza', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-072'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '977048083', '817277295', 'Rivera Cárdenas', '', 'Pilar Guadalupe', 'self', '38142991', '1951-9-20', 'Av. Central 103', '41600', 'Valle Verde', 'Valle', 'OPS', '(08) 8227-2450', 'Agroindustrias del Norte', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-073'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '496875458', '896579413', 'Rivera Cárdenas', '', 'Pilar Guadalupe', 'self', '38142991', '1951-9-20', 'Av. Central 103', '41600', 'Valle Verde', 'Valle', 'OPS', '(08) 8227-2450', 'Agroindustrias del Norte', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-073'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '521137829', '705782991', 'Rivera Cárdenas', '', 'Pilar Guadalupe', 'self', '38142991', '1951-9-20', 'Av. Central 103', '41600', 'Valle Verde', 'Valle', 'OPS', '(08) 8227-2450', 'Agroindustrias del Norte', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-073'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '405721268', '766436026', 'Peña Castillo', '', 'Juan Eduardo', 'self', '20448162', '1952-3-21', 'Calle 70 No. 25-40', '45252', 'San Rafael', 'Norte', 'OPS', '(09) 6046-1791', 'Agroindustrias del Norte', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-074'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '274273220', '301614602', 'Peña Castillo', '', 'Juan Eduardo', 'self', '20448162', '1952-3-21', 'Calle 70 No. 25-40', '45252', 'San Rafael', 'Norte', 'OPS', '(09) 6046-1791', 'Agroindustrias del Norte', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-074'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '397969330', '88901943', 'Peña Castillo', '', 'Juan Eduardo', 'self', '20448162', '1952-3-21', 'Calle 70 No. 25-40', '45252', 'San Rafael', 'Norte', 'OPS', '(09) 6046-1791', 'Agroindustrias del Norte', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-074'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora Andina S.A.'), 'Aseguradora Andina S.A.', '65194023', '493997517', 'Ramos Paredes', '', 'Teresa Beatriz', 'self', '76638945', '1992-4-15', 'Calle Sucre 2024', '59103', 'San Rafael', 'Norte', 'OPS', '(03) 5628-8797', 'Ferretería Central', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-075'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '91360359', '752585079', 'Ramos Paredes', '', 'Teresa Beatriz', 'self', '76638945', '1992-4-15', 'Calle Sucre 2024', '59103', 'San Rafael', 'Norte', 'OPS', '(03) 5628-8797', 'Ferretería Central', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-075'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '719478199', '240833150', 'Ramos Paredes', '', 'Teresa Beatriz', 'self', '76638945', '1992-4-15', 'Calle Sucre 2024', '59103', 'San Rafael', 'Norte', 'OPS', '(03) 5628-8797', 'Ferretería Central', 'Norte', 'OPS', 'San Rafael', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-075'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '848831970', '952873862', 'Rivera Cárdenas', '', 'Manuel Javier', 'self', '92913538', '1939-2-14', 'Calle Colón 2056', '26646', 'Ciudad Bolívar', 'Norte', 'OPS', '(02) 4869-6762', 'Alimentos La Esperanza', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-076'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '325138399', '144996512', 'Rivera Cárdenas', '', 'Manuel Javier', 'self', '92913538', '1939-2-14', 'Calle Colón 2056', '26646', 'Ciudad Bolívar', 'Norte', 'OPS', '(02) 4869-6762', 'Alimentos La Esperanza', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-076'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '648208447', '536552530', 'Rivera Cárdenas', '', 'Manuel Javier', 'self', '92913538', '1939-2-14', 'Calle Colón 2056', '26646', 'Ciudad Bolívar', 'Norte', 'OPS', '(02) 4869-6762', 'Alimentos La Esperanza', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-076'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora Andina S.A.'), 'Aseguradora Andina S.A.', '663714730', '454332769', 'Fuentes Contreras', '', 'Gabriela Beatriz', 'self', '11308058', '1974-7-28', 'Av. Central 2499', '53883', 'San Miguel', 'Central', 'OPS', '(02) 4509-3863', 'Constructora Andina', 'Central', 'OPS', 'San Miguel', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-077'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '462645734', '957068030', 'Fuentes Contreras', '', 'Gabriela Beatriz', 'self', '11308058', '1974-7-28', 'Av. Central 2499', '53883', 'San Miguel', 'Central', 'OPS', '(02) 4509-3863', 'Constructora Andina', 'Central', 'OPS', 'San Miguel', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-077'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '524150781', '720180416', 'Fuentes Contreras', '', 'Gabriela Beatriz', 'self', '11308058', '1974-7-28', 'Av. Central 2499', '53883', 'San Miguel', 'Central', 'OPS', '(02) 4509-3863', 'Constructora Andina', 'Central', 'OPS', 'San Miguel', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-077'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', 0, '0', '289309230', '735597923', 'Peña Fuentes', '', 'Tomás', 'self', '46819409', '1989-3-11', 'Calle Los Pinos 3906', '89824', 'Los Robles', 'Valle', 'OPS', '(09) 7928-2251', 'Agroindustrias del Norte', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-078'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '640352682', '414411328', 'Peña Fuentes', '', 'Tomás', 'self', '46819409', '1989-3-11', 'Calle Los Pinos 3906', '89824', 'Los Robles', 'Valle', 'OPS', '(09) 7928-2251', 'Agroindustrias del Norte', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-078'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '578825074', '997941643', 'Peña Fuentes', '', 'Tomás', 'self', '46819409', '1989-3-11', 'Calle Los Pinos 3906', '89824', 'Los Robles', 'Valle', 'OPS', '(09) 7928-2251', 'Agroindustrias del Norte', 'Valle', 'OPS', 'Los Robles', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-078'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '487308069', '292901500', 'Álvarez Gómez', '', 'Eduardo Enrique', 'self', '48440966', '1945-9-9', 'Carrera 18 No. 19-21', '97655', 'San Cristóbal', 'Costa Sur', 'OPS', '(04) 6351-5115', 'Editorial Nueva Aurora', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-079'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '216731392', '601578886', 'Álvarez Gómez', '', 'Eduardo Enrique', 'self', '48440966', '1945-9-9', 'Carrera 18 No. 19-21', '97655', 'San Cristóbal', 'Costa Sur', 'OPS', '(04) 6351-5115', 'Editorial Nueva Aurora', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-079'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '311753569', '772030643', 'Álvarez Gómez', '', 'Eduardo Enrique', 'self', '48440966', '1945-9-9', 'Carrera 18 No. 19-21', '97655', 'San Cristóbal', 'Costa Sur', 'OPS', '(04) 6351-5115', 'Editorial Nueva Aurora', 'Costa Sur', 'OPS', 'San Cristóbal', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-079'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora Andina S.A.'), 'Aseguradora Andina S.A.', '536937383', '449913284', 'Paredes Sánchez', '', 'Alejandra Isabel', 'self', '89535434', '1951-8-24', 'Av. Las Américas 4172', '53338', 'Santa Lucía', 'Central', 'OPS', '(04) 3795-8738', 'Agroindustrias del Norte', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-080'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '309651894', '796159242', 'Paredes Sánchez', '', 'Alejandra Isabel', 'self', '89535434', '1951-8-24', 'Av. Las Américas 4172', '53338', 'Santa Lucía', 'Central', 'OPS', '(04) 3795-8738', 'Agroindustrias del Norte', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-080'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '470809070', '292810403', 'Paredes Sánchez', '', 'Alejandra Isabel', 'self', '89535434', '1951-8-24', 'Av. Las Américas 4172', '53338', 'Santa Lucía', 'Central', 'OPS', '(04) 3795-8738', 'Agroindustrias del Norte', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-080'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '480515089', '888900713', 'Navarro López', '', 'Rosa Beatriz', 'self', '24355159', '2004-3-17', 'Calle 59 No. 98-77', '55799', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6659-8153', 'Constructora Andina', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-081'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '449634180', '185190964', 'Navarro López', '', 'Rosa Beatriz', 'self', '24355159', '2004-3-17', 'Calle 59 No. 98-77', '55799', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6659-8153', 'Constructora Andina', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-081'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '446562071', '281338553', 'Navarro López', '', 'Rosa Beatriz', 'self', '24355159', '2004-3-17', 'Calle 59 No. 98-77', '55799', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6659-8153', 'Constructora Andina', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-081'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '770725291', '724151816', 'Guerrero Fuentes', '', 'Julián Eduardo', 'self', '94402622', '1949-2-26', 'Calle Sucre 1216', '48921', 'Nueva Aurora', 'Oriente', 'OPS', '(09) 5911-6150', 'Constructora Andina', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-082'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '385643128', '113880532', 'Guerrero Fuentes', '', 'Julián Eduardo', 'self', '94402622', '1949-2-26', 'Calle Sucre 1216', '48921', 'Nueva Aurora', 'Oriente', 'OPS', '(09) 5911-6150', 'Constructora Andina', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-082'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '686863031', '517548515', 'Guerrero Fuentes', '', 'Julián Eduardo', 'self', '94402622', '1949-2-26', 'Calle Sucre 1216', '48921', 'Nueva Aurora', 'Oriente', 'OPS', '(09) 5911-6150', 'Constructora Andina', 'Oriente', 'OPS', 'Nueva Aurora', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-082'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '598304561', '707494993', 'Sandoval Chávez', '', 'Inés Beatriz', 'self', '25711163', '1979-10-6', 'Av. San Martín 1233', '44526', 'La Esperanza', 'Oriente', 'OPS', '(07) 6561-4008', 'Ferretería Central', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-083'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '953233720', '691036233', 'Sandoval Chávez', '', 'Inés Beatriz', 'self', '25711163', '1979-10-6', 'Av. San Martín 1233', '44526', 'La Esperanza', 'Oriente', 'OPS', '(07) 6561-4008', 'Ferretería Central', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-083'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '284632684', '450440176', 'Sandoval Chávez', '', 'Inés Beatriz', 'self', '25711163', '1979-10-6', 'Av. San Martín 1233', '44526', 'La Esperanza', 'Oriente', 'OPS', '(07) 6561-4008', 'Ferretería Central', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-083'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '759362669', '196878056', 'Salazar Mendoza', '', 'Francisco Eduardo', 'self', '59174427', '1940-4-18', 'Jr. Bolívar 2502', '37917', 'Punta Serena', 'Costa Sur', 'OPS', '(04) 2794-6833', 'Constructora Andina', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-084'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '709819198', '572442894', 'Salazar Mendoza', '', 'Francisco Eduardo', 'self', '59174427', '1940-4-18', 'Jr. Bolívar 2502', '37917', 'Punta Serena', 'Costa Sur', 'OPS', '(04) 2794-6833', 'Constructora Andina', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-084'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '916614298', '284514926', 'Salazar Mendoza', '', 'Francisco Eduardo', 'self', '59174427', '1940-4-18', 'Jr. Bolívar 2502', '37917', 'Punta Serena', 'Costa Sur', 'OPS', '(04) 2794-6833', 'Constructora Andina', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-084'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '721594803', '361171690', 'Vega Espinoza', '', 'Raúl', 'self', '91239038', '2006-4-27', 'Calle Los Pinos 4617', '98517', 'Santa Lucía', 'Central', 'OPS', '(07) 6002-4497', 'Comercial San Miguel', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-085'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '885185149', '147777810', 'Vega Espinoza', '', 'Raúl', 'self', '91239038', '2006-4-27', 'Calle Los Pinos 4617', '98517', 'Santa Lucía', 'Central', 'OPS', '(07) 6002-4497', 'Comercial San Miguel', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-085'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '397364513', '362007103', 'Vega Espinoza', '', 'Raúl', 'self', '91239038', '2006-4-27', 'Calle Los Pinos 4617', '98517', 'Santa Lucía', 'Central', 'OPS', '(07) 6002-4497', 'Comercial San Miguel', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-085'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '175027884', '468325087', 'Salazar Flores', '', 'Adriana Cristina', 'self', '10099857', '1948-7-28', 'Pasaje Las Palmas 459', '65975', 'Santa Lucía', 'Central', 'OPS', '(02) 2093-6247', 'Transportes Litoral S.A.', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-086'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '302433415', '427586655', 'Salazar Flores', '', 'Adriana Cristina', 'self', '10099857', '1948-7-28', 'Pasaje Las Palmas 459', '65975', 'Santa Lucía', 'Central', 'OPS', '(02) 2093-6247', 'Transportes Litoral S.A.', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-086'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '697670335', '693020438', 'Salazar Flores', '', 'Adriana Cristina', 'self', '10099857', '1948-7-28', 'Pasaje Las Palmas 459', '65975', 'Santa Lucía', 'Central', 'OPS', '(02) 2093-6247', 'Transportes Litoral S.A.', 'Central', 'OPS', 'Santa Lucía', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-086'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora Andina S.A.'), 'Aseguradora Andina S.A.', '634294930', '892341092', 'Pérez Molina', '', 'Sergio Eduardo', 'self', '79163939', '1989-11-5', 'Calle Sucre 4982', '57703', 'Punta Serena', 'Costa Sur', 'OPS', '(05) 4002-9207', 'Transportes Litoral S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-087'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '619880286', '639957389', 'Pérez Molina', '', 'Sergio Eduardo', 'self', '79163939', '1989-11-5', 'Calle Sucre 4982', '57703', 'Punta Serena', 'Costa Sur', 'OPS', '(05) 4002-9207', 'Transportes Litoral S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-087'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '889734012', '925268565', 'Pérez Molina', '', 'Sergio Eduardo', 'self', '79163939', '1989-11-5', 'Calle Sucre 4982', '57703', 'Punta Serena', 'Costa Sur', 'OPS', '(05) 4002-9207', 'Transportes Litoral S.A.', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-087'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '525464869', '999233966', 'Mendoza Navarro', '', 'Pilar Fernanda', 'self', '74898592', '1932-6-2', 'Av. Independencia 2643', '50584', 'Villa Nueva', 'Litoral', 'OPS', '(05) 6447-2916', 'Comercial San Miguel', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-088'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '734741823', '546566447', 'Mendoza Navarro', '', 'Pilar Fernanda', 'self', '74898592', '1932-6-2', 'Av. Independencia 2643', '50584', 'Villa Nueva', 'Litoral', 'OPS', '(05) 6447-2916', 'Comercial San Miguel', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-088'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '717636812', '840491954', 'Mendoza Navarro', '', 'Pilar Fernanda', 'self', '74898592', '1932-6-2', 'Av. Independencia 2643', '50584', 'Villa Nueva', 'Litoral', 'OPS', '(05) 6447-2916', 'Comercial San Miguel', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-088'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '858374966', '5832143', 'Ortiz Ramírez', '', 'José', 'self', '57372458', '1988-4-23', 'Av. Las Américas 2325', '55589', 'Ciudad Bolívar', 'Norte', 'OPS', '(08) 2154-6003', 'Constructora Andina', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-089'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '635869886', '977113497', 'Ortiz Ramírez', '', 'José', 'self', '57372458', '1988-4-23', 'Av. Las Américas 2325', '55589', 'Ciudad Bolívar', 'Norte', 'OPS', '(08) 2154-6003', 'Constructora Andina', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-089'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '950282412', '735225348', 'Ortiz Ramírez', '', 'José', 'self', '57372458', '1988-4-23', 'Av. Las Américas 2325', '55589', 'Ciudad Bolívar', 'Norte', 'OPS', '(08) 2154-6003', 'Constructora Andina', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-089'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '839853113', '112097348', 'Ramírez Peña', '', 'Javier Antonio', 'self', '29520137', '1958-6-5', 'Calle 19 No. 48-59', '69670', 'Puerto Alegre', 'Litoral', 'OPS', '(07) 6512-4363', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-090'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '229387752', '769832332', 'Ramírez Peña', '', 'Javier Antonio', 'self', '29520137', '1958-6-5', 'Calle 19 No. 48-59', '69670', 'Puerto Alegre', 'Litoral', 'OPS', '(07) 6512-4363', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-090'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '170236529', '703723618', 'Ramírez Peña', '', 'Javier Antonio', 'self', '29520137', '1958-6-5', 'Calle 19 No. 48-59', '69670', 'Puerto Alegre', 'Litoral', 'OPS', '(07) 6512-4363', 'Alimentos La Esperanza', 'Litoral', 'OPS', 'Puerto Alegre', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-090'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros del Pacífico'), 'Seguros del Pacífico', '541273963', '442236839', 'Peña González', '', 'José Manuel', 'self', '82699540', '1958-6-19', 'Jr. Bolívar 3618', '51734', 'La Esperanza', 'Oriente', 'OPS', '(05) 3454-1716', 'Transportes Litoral S.A.', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-091'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '237176092', '700874369', 'Peña González', '', 'José Manuel', 'self', '82699540', '1958-6-19', 'Jr. Bolívar 3618', '51734', 'La Esperanza', 'Oriente', 'OPS', '(05) 3454-1716', 'Transportes Litoral S.A.', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-091'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '368686974', '795431678', 'Peña González', '', 'José Manuel', 'self', '82699540', '1958-6-19', 'Jr. Bolívar 3618', '51734', 'La Esperanza', 'Oriente', 'OPS', '(05) 3454-1716', 'Transportes Litoral S.A.', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-091'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '283008906', '463097797', 'Castillo Romero', '', 'Fernanda', 'self', '96714231', '1990-9-20', 'Av. San Martín 3659', '94289', 'Ciudad Bolívar', 'Norte', 'OPS', '(04) 2801-6781', 'Servicios Bolívar S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-092'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '829926160', '997475164', 'Castillo Romero', '', 'Fernanda', 'self', '96714231', '1990-9-20', 'Av. San Martín 3659', '94289', 'Ciudad Bolívar', 'Norte', 'OPS', '(04) 2801-6781', 'Servicios Bolívar S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-092'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '165487483', '82030311', 'Castillo Romero', '', 'Fernanda', 'self', '96714231', '1990-9-20', 'Av. San Martín 3659', '94289', 'Ciudad Bolívar', 'Norte', 'OPS', '(04) 2801-6781', 'Servicios Bolívar S.A.', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-092'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '910131682', '433727212', 'Herrera Espinoza', '', 'Dolores', 'self', '61868334', '1951-2-26', 'Av. Central 3553', '20094', 'Valle Verde', 'Valle', 'OPS', '(02) 9410-6928', 'Agroindustrias del Norte', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-093'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '145998844', '952583238', 'Herrera Espinoza', '', 'Dolores', 'self', '61868334', '1951-2-26', 'Av. Central 3553', '20094', 'Valle Verde', 'Valle', 'OPS', '(02) 9410-6928', 'Agroindustrias del Norte', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-093'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '475490371', '450468264', 'Herrera Espinoza', '', 'Dolores', 'self', '61868334', '1951-2-26', 'Av. Central 3553', '20094', 'Valle Verde', 'Valle', 'OPS', '(02) 9410-6928', 'Agroindustrias del Norte', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-093'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '963093972', '174790504', 'Moreno Torres', '', 'Isabel Fernanda', 'self', '95701483', '1978-12-27', 'Av. San Martín 962', '11166', 'Villa Nueva', 'Litoral', 'OPS', '(02) 4964-6093', 'Pesquera Costa Sur', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-094'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '143132167', '259524850', 'Moreno Torres', '', 'Isabel Fernanda', 'self', '95701483', '1978-12-27', 'Av. San Martín 962', '11166', 'Villa Nueva', 'Litoral', 'OPS', '(02) 4964-6093', 'Pesquera Costa Sur', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-094'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '707653507', '745023650', 'Moreno Torres', '', 'Isabel Fernanda', 'self', '95701483', '1978-12-27', 'Av. San Martín 962', '11166', 'Villa Nueva', 'Litoral', 'OPS', '(02) 4964-6093', 'Pesquera Costa Sur', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-094'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '543448786', '959495088', 'Ortiz Pérez', '', 'Sergio Eduardo', 'self', '80993899', '2000-5-2', 'Calle Colón 866', '19472', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6952-2771', 'Pesquera Costa Sur', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-095'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '602829254', '902108138', 'Ortiz Pérez', '', 'Sergio Eduardo', 'self', '80993899', '2000-5-2', 'Calle Colón 866', '19472', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6952-2771', 'Pesquera Costa Sur', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-095'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '671708421', '550430199', 'Ortiz Pérez', '', 'Sergio Eduardo', 'self', '80993899', '2000-5-2', 'Calle Colón 866', '19472', 'Villa Nueva', 'Litoral', 'OPS', '(02) 6952-2771', 'Pesquera Costa Sur', 'Litoral', 'OPS', 'Villa Nueva', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-095'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '29797642', '555069891', 'Álvarez Ortiz', '', 'Tomás', 'self', '23921659', '1996-10-11', 'Calle Los Pinos 294', '53805', 'Ciudad Bolívar', 'Norte', 'OPS', '(05) 6467-9234', 'Pesquera Costa Sur', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-096'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '472055354', '168703867', 'Álvarez Ortiz', '', 'Tomás', 'self', '23921659', '1996-10-11', 'Calle Los Pinos 294', '53805', 'Ciudad Bolívar', 'Norte', 'OPS', '(05) 6467-9234', 'Pesquera Costa Sur', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-096'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '651122968', '461955633', 'Álvarez Ortiz', '', 'Tomás', 'self', '23921659', '1996-10-11', 'Calle Los Pinos 294', '53805', 'Ciudad Bolívar', 'Norte', 'OPS', '(05) 6467-9234', 'Pesquera Costa Sur', 'Norte', 'OPS', 'Ciudad Bolívar', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-096'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Salud Integral S.A.'), 'Salud Integral S.A.', '511748081', '740585596', 'Guerrero López', '', 'Paola Cristina', 'self', '36039686', '2002-11-26', 'Av. San Martín 1759', '82630', 'Valle Verde', 'Valle', 'OPS', '(07) 3185-4939', 'Cooperativa Los Robles', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-097'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Mutual Latinoamericana'), 'Mutual Latinoamericana', '406912613', '357374434', 'Guerrero López', '', 'Paola Cristina', 'self', '36039686', '2002-11-26', 'Av. San Martín 1759', '82630', 'Valle Verde', 'Valle', 'OPS', '(07) 3185-4939', 'Cooperativa Los Robles', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-097'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Previsión Regional S.A.'), 'Previsión Regional S.A.', '685733447', '926205805', 'Guerrero López', '', 'Paola Cristina', 'self', '36039686', '2002-11-26', 'Av. San Martín 1759', '82630', 'Valle Verde', 'Valle', 'OPS', '(07) 3185-4939', 'Cooperativa Los Robles', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-097'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Planes de Salud Unidos'), 'Planes de Salud Unidos', '527457532', '824770021', 'Pérez López', '', 'Daniela Guadalupe', 'self', '72895972', '1997-2-1', 'Calle Los Pinos 2814', '13569', 'Valle Verde', 'Valle', 'OPS', '(06) 8570-1320', 'Minera Punta Serena', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-098'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '661545767', '676006626', 'Pérez López', '', 'Daniela Guadalupe', 'self', '72895972', '1997-2-1', 'Calle Los Pinos 2814', '13569', 'Valle Verde', 'Valle', 'OPS', '(06) 8570-1320', 'Minera Punta Serena', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-098'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', 0, '0', '445367211', '10216566', 'Pérez López', '', 'Daniela Guadalupe', 'self', '72895972', '1997-2-1', 'Calle Los Pinos 2814', '13569', 'Valle Verde', 'Valle', 'OPS', '(06) 8570-1320', 'Minera Punta Serena', 'Valle', 'OPS', 'Valle Verde', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-098'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '394372797', '449112419', 'Morales Miranda', '', 'Ramón Alberto', 'self', '57588840', '1996-4-27', 'Pasaje Las Palmas 4895', '93392', 'Punta Serena', 'Costa Sur', 'OPS', '(09) 3906-8074', 'Minera Punta Serena', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Male', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-099'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', 0, '0', '260606633', '903056437', 'Morales Miranda', '', 'Ramón Alberto', 'self', '57588840', '1996-4-27', 'Pasaje Las Palmas 4895', '93392', 'Punta Serena', 'Costa Sur', 'OPS', '(09) 3906-8074', 'Minera Punta Serena', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-099'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Cobertura Nacional S.A.'), 'Cobertura Nacional S.A.', '233544753', '42580478', 'Morales Miranda', '', 'Ramón Alberto', 'self', '57588840', '1996-4-27', 'Pasaje Las Palmas 4895', '93392', 'Punta Serena', 'Costa Sur', 'OPS', '(09) 3906-8074', 'Minera Punta Serena', 'Costa Sur', 'OPS', 'Punta Serena', '', '2011-10-10', 'Male', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-099'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'primary', (SELECT id FROM insurance_companies WHERE name = 'Cruz Verde Salud'), 'Cruz Verde Salud', '163032616', '495532938', 'Cárdenas Ramírez', '', 'Teresa Beatriz', 'self', '41235431', '1944-5-22', 'Calle Colón 2475', '53561', 'La Esperanza', 'Oriente', 'OPS', '(06) 7716-7543', 'Minera Punta Serena', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'FALSE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-100'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'primary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'secondary', (SELECT id FROM insurance_companies WHERE name = 'Aseguradora del Litoral'), 'Aseguradora del Litoral', '889446665', '498713860', 'Cárdenas Ramírez', '', 'Teresa Beatriz', 'self', '41235431', '1944-5-22', 'Calle Colón 2475', '53561', 'La Esperanza', 'Oriente', 'OPS', '(06) 7716-7543', 'Minera Punta Serena', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-100'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'secondary');

INSERT INTO insurance_data (pid, type, provider, plan_name, policy_number, group_number, subscriber_lname, subscriber_mname, subscriber_fname, subscriber_relationship, subscriber_ss, subscriber_DOB, subscriber_street, subscriber_postal_code, subscriber_city, subscriber_state, subscriber_country, subscriber_phone, subscriber_employer, subscriber_employer_state, subscriber_employer_country, subscriber_employer_city, copay, date, subscriber_sex, accept_assignment)
SELECT p.pid, 'tertiary', (SELECT id FROM insurance_companies WHERE name = 'Seguros Bolívar Salud'), 'Seguros Bolívar Salud', '979825861', '116055883', 'Cárdenas Ramírez', '', 'Teresa Beatriz', 'self', '41235431', '1944-5-22', 'Calle Colón 2475', '53561', 'La Esperanza', 'Oriente', 'OPS', '(06) 7716-7543', 'Minera Punta Serena', 'Oriente', 'OPS', 'La Esperanza', '', '2011-10-10', 'Female', 'TRUE'
FROM patient_data p
WHERE p.pubpid = 'PAHO-OPS-PATIENT-100'
  AND NOT EXISTS (SELECT 1 FROM insurance_data i WHERE i.pid = p.pid AND i.type = 'tertiary');
