\encoding
\l+

-- -- Done on a modern version of Postgres (in UTF8 encoding):
-- create table t (word text, wordb bytea, i integer, f float);
-- copy t(word) from '/usr/share/dict/ukrainian';
-- create sequence i;
-- update t set wordb=word::bytea, i = nextval('i'), f = random();
-- set bytea_output='escape';
-- copy tt to '/home/stark/src/retropg/data'

create table t (word text, wordb bytea, i integer, f float);
copy t from '/home/stark/src/retropg/data';

vacuum;
vacuum;
vacuum freeze;

select pg_relation_size('t');
\l+

