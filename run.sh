clear
set -e

dropdb -U edoardo sqlegends; createdb -U edoardo sqlegends;  psql -U edoardo -d sqlegends -f db/schema.sql
psql -U edoardo -d sqlegends -f db/seed.sql
psql -U edoardo -d sqlegends -f db/queries.sql