show work_mem;
show sort_mem;
create table t (pk serial, word  text);
copy t (word) from '/usr/share/dict/words';
select pg_relation_size('t');
\timing
vacuum freeze t;
select count(*) from t;
select count(*) from (select * from t order by word) as foo;
select count(*) from (select * from t order by word) as foo;
select count(*) from (select * from t order by word) as foo;
explain analyze select * from t order by word;
