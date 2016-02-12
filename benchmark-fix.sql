show work_mem;
show sort_mem;
alter table t rename to t_old;
create table t as (select * from t_old order by random());
select pg_relation_size('t');
\timing
vacuum freeze t;
select count(*) from t;
select count(*) from (select * from t order by word) as foo;
select count(*) from (select * from t order by word) as foo;
select count(*) from (select * from t order by word) as foo;
explain analyze select * from t order by word;
