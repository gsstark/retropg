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
select count(*) as warmup from t;
select count(*) as warmup from t;
checkpoint;
\! sync
\! sleep 5
select count(*) as warmup from t;

select count(*) as seqscan from t;
select count(*) as seqscan from t;
select count(*) as seqscan from t;
select count(*) as seqscan from t;

select i as sort_text    from t order by word  offset 1485661;
select i as sort_binary  from t order by wordb offset 1485661;
select i as sort_integer from t order by i     offset 1485661;
select i as sort_float   from t order by f     offset 1485661;

select i as sort_text    from t order by word  offset 1485661;
select i as sort_binary  from t order by wordb offset 1485661;
select i as sort_integer from t order by i     offset 1485661;
select i as sort_float   from t order by f     offset 1485661;

select i as sort_integer from t order by i     offset 1485661;
select i as sort_float   from t order by f     offset 1485661;
select i as sort_text    from t order by word  offset 1485661;
select i as sort_binary  from t order by wordb offset 1485661;

-- select i as sort2_text    from t,x2 order by word  offset 2971323;
-- select i as sort2_binary  from t,x2 order by wordb offset 2971323;
-- select i as sort2_integer from t,x2 order by i     offset 2971323;
-- select i as sort2_float   from t,x2 order by f     offset 2971323;

-- select i as sort4_text    from t,x4 order by word  offset 5942647;
-- select i as sort4_binary  from t,x4 order by wordb offset 5942647;
-- select i as sort4_integer from t,x4 order by i     offset 5942647;
-- select i as sort4_float   from t,x4 order by f     offset 5942647;

-- select i as sort8_text    from t,x8 order by word  offset 11885295;
-- select i as sort8_binary  from t,x8 order by wordb offset 11885295;
-- select i as sort8_integer from t,x8 order by i     offset 11885295;
-- select i as sort8_float   from t,x8 order by f     offset 11885295;

-- select i as sort_t10   from t order by word  offset 9   limit 1;
select i as sort_t100  from t order by word  offset 99  limit 1;
select i as sort_t100  from t order by word  offset 99  limit 1;
select i as sort_t100  from t order by word  offset 99  limit 1;
-- select i as sort_t1000 from t order by word  offset 999 limit 1;

select count(*) as seqscan from t;
select count(*) as seqscan from t;
