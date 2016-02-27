set work_mem=32768;
set sort_mem=32768;

show work_mem;
show sort_mem;
show lc_collate;
show server_encoding;
show client_encoding;
\encoding

select now();

vacuum;

\timing
select count(*) from x1;
select count(*) from x2;
select count(*) from x3;
select count(*) from x4;
select count(*) from x8;
select count(*) as warmup_x4 from t;
select count(*) as warmup_x4 from t;
select count(*) from x1;
select count(*) from x2;
select count(*) from x3;
select count(*) from x4;
select count(*) from x8;
checkpoint;
\! sync
\! sleep 5
select count(*) as warmup_x4 from t,x4;

select count(*) as seqscan_x4 from t,x4;
select count(*) as seqscan_x4 from t,x4;
select count(*) as seqscan_x4 from t,x4;
select count(*) as seqscan_x4 from t,x4;

select i as sort_text_x4    from t,x4 order by word  offset 1485661;
select i as sort_binary_x4  from t,x4 order by wordb offset 1485661;
select i as sort_integer_x4 from t,x4 order by i     offset 1485661;
select i as sort_float_x4   from t,x4 order by f     offset 1485661;

select i as sort_text_x4    from t,x4 order by word  offset 1485661;
select i as sort_binary_x4  from t,x4 order by wordb offset 1485661;
select i as sort_integer_x4 from t,x4 order by i     offset 1485661;
select i as sort_float_x4   from t,x4 order by f     offset 1485661;

select i as sort_integer_x4 from t,x4 order by i     offset 1485661;
select i as sort_float_x4   from t,x4 order by f     offset 1485661;
select i as sort_text_x4    from t,x4 order by word  offset 1485661;
select i as sort_binary_x4  from t,x4 order by wordb offset 1485661;

select i as sort_t100_x4  from t,x4 order by word  offset 99  limit 1;
select i as sort_t100_x4  from t,x4 order by word  offset 99  limit 1;
select i as sort_t100_x4  from t,x4 order by word  offset 99  limit 1;

select count(*) as seqscan_x4 from t,x4;
select count(*) as seqscan_x4 from t,x4;
