-- 怎么创建view?

create or replace VIEW Q1(pid, firstname, lastname) as
    -- put your code
select pid, firstname, lastname
from person;
;

create or replace VIEW Q2(pid, firstname, lastname) as
    -- put your code
select pid, firstname, lastname
from person;
;

create or replace VIEW Q3(pid, firstname, lastname) as
    -- put your code
select pid, firstname, lastname
from person;
;


-- 怎么使用view?
select *
from Q1;


-- Q1思路
select *
from person;

-- 谁是staff?
select *
from staff;

-- 谁是client
select *
from client;

-- 谁不是staff?
select pid, firstname, lastname
from person
where not exists(select * from staff where pid = person.pid);

--谁不是client?
select pid, firstname, lastname
from person
where not exists(select * from client where pid = person.pid);

-- 放在一起
select pid, firstname, lastname
from person
where not exists(select * from staff where pid = person.pid)
  and not exists(select * from client where pid = person.pid);

-- 如何排序 (ascending/descending)
select pid, firstname
from person
order by pid;
select pid, firstname
from person
order by pid DESC;


-- Q2
-- JOIN 用法
select *
from insured_by;
select *
from insured_item;
select *
from policy;

select DISTINCT p.pid, p.firstname, p.lastname
from client
         join insured_by ib on client.cid = ib.cid
         join person p on client.pid = p.pid;


SELECT distinct p.pid, firstname
FROM insured_by
         join client c on insured_by.cid = c.cid
         join person p on c.pid = p.pid;


-- Q3
select *
from policy;
select brand, insured_item.id, p.pno, rate
from insured_item
         join policy p on insured_item.id = p.id
         join coverage c on p.pno = c.pno
         join rating_record rr on c.coid = rr.coid;

-- 如何计算求和？
select brand, insured_item.id, p.pno, sum(rate)
from insured_item
         join policy p on insured_item.id = p.id
         join coverage c on p.pno = c.pno
         join rating_record rr on c.coid = rr.coid
where rr.status = 'A'
group by brand, insured_item.id, p.pno;



select brand, insured_item.id, p.pno, sum(rate)
from insured_item
         join policy p on insured_item.id = p.id
         join coverage c on p.pno = c.pno
         join rating_record rr on c.coid = rr.coid
where rr.status = 'A'
group by brand, insured_item.id, p.pno
order by brand, sum;


-- Q4
-- list all the staff
select p.pid, firstname, lastname
from staff
         join person p on staff.pid = p.pid;

-- Enforced policies
-- 所有成功执行的policy
select *
from staff
         join policy p on staff.sid = p.sid
where status = 'E';

-- 成功销售过的员工有哪些？
select pid, firstname, lastname
from person
where pid in (select staff.pid
              from staff
                       join policy p on staff.sid = p.sid
              where status = 'E');

-- 参与过rate的员工有哪些？
select distinct p.pid, firstname, lastname
from rated_by
         join staff s on s.sid = rated_by.sid
         join person p on p.pid = s.pid
         join policy p2 on s.sid = p2.sid
where p2.status = 'E';

-- 参加过written的员工？
select p.pid, firstname, lastname
from underwritten_by
         join staff s on s.sid = underwritten_by.sid
         join person p on s.pid = p.pid;

-- 没参加过任何Enforced的policy的员工有哪些？
-- select * from .. where not exist () and not exist()  and not exist();


-- Q5
-- count 用法
select suburb, count(*)
from person
group by suburb;

select suburb, count(*)
from client
         join insured_by ib on client.cid = ib.cid
         join policy p on p.pno = ib.pno
         join person p2 on p2.pid = client.pid
where p.status = 'E'
group by suburb;


-- Q6

-- all related

-- rate的员工是谁？ sid
select *
from rated_by;

-- 编写的staff是谁： sid
select *
from underwritten_by;

-- 卖出去的staff是谁： sid
select *
from policy;

select *
from policy p
         join staff s on p.sid = s.sid; -- sold by



select p.pno as policy, p.sid as staff, firstname, lastname
from policy p
         join staff s on p.sid = s.sid
         join person p2 on s.pid = p2.pid
order by policy; -- sold by


-- 谁评分的
select *
from rated_by
         join staff s on s.sid = rated_by.sid; -- rated by

select p.pno, rated_by.sid, firstname, lastname
from rated_by
         join rating_record rr on rr.rid = rated_by.rid
         join coverage c on rr.coid = c.coid
         join policy p on c.pno = p.pno
         join staff s on rated_by.sid = s.sid
         join person p2 on s.pid = p2.pid group by p.pno,rated_by.sid,firstname,lastname order by pno; -- rated by


select *
from underwritten_by
         join staff s on underwritten_by.sid = s.sid;
-- underwritten by
-- todo


-- Q7
select *
from rated_by
         join rating_record rr on rr.rid = rated_by.rid; -- rated date
with rated_date as (select p.pno, rdate
                    from rated_by
                             join rating_record rr on rr.rid = rated_by.rid
                             join coverage c on rr.coid = c.coid
                             join policy p on c.pno = p.pno) -- rated date
select pno, max(rdate) - min(rdate) as timediff
from rated_date
group by pno;

select *
from underwritten_by
         join underwriting_record ur on ur.urid = underwritten_by.urid; -- underwrittendate
select p.pno, wdate
from underwritten_by
         join underwriting_record ur on ur.urid = underwritten_by.urid
         join policy p on ur.pno = p.pno;


with temp as (select * from policy)
select pno from temp;

-- underwrittendate
-- 参照上面， 自己想办法

