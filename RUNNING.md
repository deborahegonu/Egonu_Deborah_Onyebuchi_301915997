# Running the portfolio with Docker only

Run all commands from the repo root (the folder containing docker-compose.yml). Use Git Bash, WSL or macOS/Linux terminal for the `bash -c` lines; in PowerShell use the interactive `psql` shell instead (see the end).

```bash
docker compose up -d                      # start PostgreSQL, MongoDB, Redis
docker compose ps                         # all three should be "running"
```

## Portfolio 1
```bash
docker compose exec postgres bash -c "psql -U postgres -d naijamart -f /work/portfolio-1-database-design/*_P1_Schema.sql"
docker compose exec postgres bash -c "psql -U postgres -d naijamart -f /work/portfolio-1-database-design/*_P1_SampleData.sql"
docker compose exec postgres bash -c "psql -U postgres -d naijamart -f /work/portfolio-1-database-design/*_P1_ConstraintTests.sql"
```

## Portfolio 2
```bash
docker compose exec postgres bash -c "psql -U postgres -d naijamart -f /work/portfolio-2-query-optimisation/*_P2_Queries.sql"
# Run this one LAST: it replaces the sample data with 200,000 synthetic orders
docker compose exec postgres bash -c "psql -U postgres -d naijamart -f /work/portfolio-2-query-optimisation/*_P2_Optimisation.sql" > plans.txt
```
(Rerun the two Portfolio 1 load commands afterwards to restore the sample data before Portfolio 3.)

## Portfolio 3 (two terminals)
```bash
# Terminal 1 and Terminal 2, each:
docker compose exec postgres psql -U postgres -d naijamart
```
Then paste the lines from the SessionA and SessionB files, and set stock first:
`UPDATE naijamart.inventory SET stock_qty = 1 WHERE product_id = 1;`

For the commit/rollback example:
```bash
docker compose exec postgres bash -c "psql -U postgres -d naijamart -f /work/portfolio-3-transactions-concurrency/*_P3_Transactions.sql"
```

## Portfolio 4
```bash
docker compose exec mongo bash -c "mongosh naijamart /work/portfolio-4-nosql/*_P4_MongoDB.js"
docker compose exec redis redis-cli          # paste the Redis commands from the P4 README
```

## Portfolio 5 (separate stack)
PostgreSQL in this stack uses port 5432, which the replication demo also needs, so stop it first:
```bash
docker compose down
cd portfolio-5-distributed-cloud
docker compose up -d                                    # primary (5432) + replica (5433)
docker compose exec pg-primary psql -U postgres naijamart   # run the primary part of replication-test.sql
docker compose exec pg-replica psql -U postgres naijamart   # run the replica part
docker compose down
docker compose -f docker-compose-mongo-shards.yml up -d
bash mongo-shard-setup.sh
```

## Optional: GUI and ER diagram
```bash
docker compose --profile gui up -d
```
Open http://localhost:8080 (admin@example.com / admin), register a server with host `postgres`, user `postgres`, password `secret`, then right-click the naijamart database and choose ERD Tool.

## PowerShell users
Skip the `bash -c` lines. Open a psql shell and use `\i` with the full path inside the container:
```powershell
docker compose exec postgres psql -U postgres -d naijamart
```
```sql
\i /work/portfolio-1-database-design/Egonu_Deborah_Onyebuchi_301915997_P1_Schema.sql
```
(use your real prefix in the file name).
