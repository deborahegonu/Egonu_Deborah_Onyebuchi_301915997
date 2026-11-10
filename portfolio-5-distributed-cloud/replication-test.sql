-- On the primary (port 5432):
SELECT client_addr, state, sync_state FROM pg_stat_replication;
CREATE TABLE IF NOT EXISTS repl_test(id int, note text);
INSERT INTO repl_test VALUES (1, 'written on primary');
-- On the replica (port 5433):
SELECT pg_is_in_recovery();           -- true
SELECT * FROM repl_test;              -- row appears
INSERT INTO repl_test VALUES (2,'x'); -- ERROR: read-only transaction
-- Failover: docker stop pg-primary ; docker exec -u postgres pg-replica pg_ctl promote -D /var/lib/postgresql/data
