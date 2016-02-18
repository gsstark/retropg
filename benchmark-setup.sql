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
-- c.f. REL7_3~975
set lc_numeric='C';
copy t from '/home/stark/src/retropg/data';

create table x2 (j integer);
insert into x2 values (1);
insert into x2 values (2);

create table x4 (j integer);
insert into x4 values (1);
insert into x4 values (2);
insert into x4 values (3);
insert into x4 values (4);

create table x8 (j integer);
insert into x8 values (1);
insert into x8 values (2);
insert into x8 values (3);
insert into x8 values (4);
insert into x8 values (5);
insert into x8 values (6);
insert into x8 values (7);
insert into x8 values (8);

vacuum;
vacuum;
vacuum freeze;

select pg_relation_size('t');
\l+

