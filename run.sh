clear
set -e

dropdb -U edoardo sqlegends; createdb -U edoardo sqlegends
psql -U edoardo -d sqlegends -f db/schema.sql
python3 main.py; psql -U edoardo -d sqlegends -f db/queries.sql