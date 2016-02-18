set work_mem=65536;
set sort_mem=65536;

show work_mem;
show sort_mem;
show lc_collate;
show server_encoding;
show client_encoding;
\encoding

select now();

vacuum;
\timing
select count(*) as garbage from t;

select count(*) as sort_text    from (select * from t order by word) as foo;
select count(*) as sort_binary  from (select * from t order by wordb) as foo;
select count(*) as sort_integer from (select * from t order by i) as foo;
select count(*) as sort_float   from (select * from t order by f) as foo;

select count(*) as sort_text    from (select * from t order by word) as foo;
select count(*) as sort_binary  from (select * from t order by wordb) as foo;
select count(*) as sort_integer from (select * from t order by i) as foo;
select count(*) as sort_float   from (select * from t order by f) as foo;

select count(*) as sort2_text    from (select * from t union all select * from t order by word) as foo;
select count(*) as sort2_binary  from (select * from t union all select * from t order by wordb) as foo;
select count(*) as sort2_integer from (select * from t union all select * from t order by i) as foo;
select count(*) as sort2_float   from (select * from t union all select * from t order by f) as foo;


select count(*) as sort_t10     from (select * from t order by word limit 10) as foo;
select count(*) as sort_t100    from (select * from t order by word limit 100) as foo;
select count(*) as sort_t1000   from (select * from t order by word limit 1000) as foo;
select count(*) as sort_t10     from (select * from t order by word limit 10) as foo;
select count(*) as sort_t100    from (select * from t order by word limit 100) as foo;
select count(*) as sort_i10     from (select * from t order by i limit 10) as foo;
select count(*) as sort_i100    from (select * from t order by i limit 100) as foo;
select count(*) as sort_i1000   from (select * from t order by i limit 1000) as foo;
select count(*) as sort_i10     from (select * from t order by i limit 10) as foo;
select count(*) as sort_i100    from (select * from t order by i limit 100) as foo;
