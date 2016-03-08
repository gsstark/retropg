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
select count(*) from x2;
select count(*) from x4;
select count(*) from x8;
select count(*) as warmup from t;
select count(*) as warmup from t;
select count(*) from x2;
select count(*) from x4;
select count(*) from x8;
checkpoint;
\! sync
\! sync
\! sleep 10
select count(*) as warmup_x8 from t,x8;

select count(*) as seqscan_x8 from t,x8;
select count(*) as seqscan_x8 from t,x8;
select count(*) as seqscan_x8 from t,x8;
select count(*) as seqscan_x8 from t,x8;

select i as sort_text_x8    from t,x8 order by word  offset 11885295;
select i as sort_binary_x8  from t,x8 order by wordb offset 11885295;
select i as sort_integer_x8 from t,x8 order by i     offset 11885295;
select i as sort_float_x8   from t,x8 order by f     offset 11885295;
select i as sort_t100_x8    from t,x8 order by word  offset 99  limit 1;

select i as sort_text_x8    from t,x8 order by word  offset 11885295;
select i as sort_binary_x8  from t,x8 order by wordb offset 11885295;
select i as sort_integer_x8 from t,x8 order by i     offset 11885295;
select i as sort_float_x8   from t,x8 order by f     offset 11885295;
select i as sort_t100_x8    from t,x8 order by word  offset 99  limit 1;

select count(*) as seqscan_x8 from t,x8;
select count(*) as seqscan_x8 from t,x8;

set work_mem=8192000;
set sort_mem=8192000;

show work_mem;
show sort_mem;

select i as sort_text_x8_bigmem    from t,x8 order by word  offset 11885295;
select i as sort_text_x8_bigmem    from t,x8 order by word  offset 11885295;
