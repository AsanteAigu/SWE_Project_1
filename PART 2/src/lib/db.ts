import { Pool } from "pg";

declare global {
  // eslint-disable-next-line no-var
  var _pgPool: Pool | undefined;
}

function createPool() {
  // Read lazily (not validated here) so builds/page-data collection don't
  // require a real DATABASE_URL. Missing/invalid values fail at query time.
  return new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false },
  });
}

// Reuse the pool across hot reloads in dev instead of opening a new one per request.
const pool = global._pgPool ?? createPool();
if (process.env.NODE_ENV !== "production") {
  global._pgPool = pool;
}

export default pool;
