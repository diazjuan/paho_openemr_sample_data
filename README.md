# PAHO Sample Data Loader for OpenEMR

OpenEMR custom module that loads PAHO-curated sample data (patients, providers, etc.) into the database by running a bundled SQL script from an admin-only Configure page.

## Installation

1. Place this module under `custom_modules/` in your OpenEMR install.
2. Log in to OpenEMR as an admin.
3. Go to **Modules → Manage Modules**.
4. Find **PAHO Sample Data Loader** under "Unregistered" and click **Register**, then **Install**, then **Enable**.

## Usage

1. **Modules → Manage Modules**, click **Configure** on the **PAHO Sample Data Loader** row.
2. Click **Run**.
3. The page reports success or error and the execution duration.

The bundled SQL is expected to be idempotent (INSERTs guarded by `NOT EXISTS`, UPDATEs scoped by id), so re-running is safe.

## Updating sample data

Edit `sql/paio/sql_sample_data.sql` (or pull updates from the repo) and click **Run** again.

## Safety

The module does **not** create automatic backups. If you want a rollback, take a manual database backup (e.g. `mysqldump`) before clicking **Run**.

## License

GPL-3.0. See [`LICENSE`](LICENSE).
