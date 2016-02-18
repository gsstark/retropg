show work_mem;
show sort_mem;


drop table x2;
create table x2 (j integer);
insert into x2 values (1);
insert into x2 values (2);

drop table x4;
create table x4 (j integer);
insert into x4 values (1);
insert into x4 values (2);
insert into x4 values (3);
insert into x4 values (4);

drop table x8;
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
