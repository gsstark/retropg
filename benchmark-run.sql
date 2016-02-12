set work_mem=20480;
set sort_mem=20480;

show work_mem;
show sort_mem;
\timing

select now();

vacuum freeze t;
select count(*) as garbage from t;
select count(*) as garbage from t;
explain analyze select * from t order by word;
explain analyze select count(*) from (select * from t union all select * from t order by word) as foo;

select count(*) from (select * from t order by word) as foo;

select count(*) from (select * from t order by word) as foo;

select count(*) from (select * from t
            union all select * from t
       order by word) as foo;
select count(*) from (select * from t
            union all select * from t
       order by word) as foo;

select count(*) from (select * from t
            union all select * from t
            union all select * from t
            union all select * from t
       order by word) as foo;
select count(*) from (select * from t cross join (select pk as j from t limit 4) as foo) as foo;

--select count(*) from (select * from t cross join (select pk as j from t limit 32) as foo) as foo;
select count(*) from (select * from t cross join (select pk as j from t limit 64) as foo order by word) as foo;
--select count(*) from (select * from t cross join (select pk as j from t limit 128) as foo) as foo;


select count(*) from (select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
            union all select * from t
       order by word) as foo;



