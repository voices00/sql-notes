-- 查询"01"课程比"02"课程成绩高的学生的信息及课程分数
SELECT st.*,sc1.score AS ‘语文’,sc2.score ‘数学’ 
FROM student st
	LEFT JOIN sc sc1 ON sc1.sid = st.sid 
	AND sc1.cid = '01'
	LEFT JOIN sc sc2 ON sc2.sid = st.sid 
	AND sc2.cid = '02' 
WHERE
	sc1.score > sc2.score;
	
--  查询学生选课存在" 01 "课程但可能不存在" 02 "课程的情况（不存在时显示为 null）
SELECT t1.*,t2.* 
FROM
	( SELECT * FROM sc WHERE cid = "01" ) AS t1
	LEFT JOIN ( SELECT * FROM sc WHERE cid = "02" ) AS t2 ON t1.sid = t2.sid;
	
-- 查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
SELECT st.sid,st.sname,avg( sc.score ) 
FROM sc
	JOIN student st ON sc.sid = st.sid 
GROUP BY sc.sid 
HAVING avg( sc.score ) > 60;

-- 查询在 SC 表存在成绩的学生信息
SELECT st.*
FROM student st
RIGHT JOIN sc on sc.sid = st.sid
GROUP BY sc.sid

-- 查询所有同学的学生编号、学生姓名、选课总数、所有课程的成绩总和
SELECT st.sid as 学生编号,st.sname as 学生姓名,COUNT(sc.cid) as 选课总数,SUM(sc.score) as 课程成绩总和
FROM student st
LEFT JOIN sc on sc.sid = st.sid
GROUP BY sc.sid

-- 查询「李」姓老师的数量
SELECT COUNT(teacher.tid)
FROM teacher
WHERE teacher.tname LIKE '李%'

-- 查询学过「张三」老师授课的同学的信息
SELECT st.*,t.tname FROM 
    (SELECT d.sid,c.tname FROM 
        (SELECT a.tname,b.cid FROM teacher AS a
            JOIN course AS b 
            ON a.tid = b.tid
                WHERE a.tname = '张三') AS c
        JOIN sc AS d
        ON c.cid = d.cid) AS t
JOIN student AS st
ON t.sid = st.sid

-- 查询没有学全所有课程的同学的信息
SELECT st.*,count(sc.cid) AS 所学课程数
FROM student AS st
LEFT JOIN sc AS sc
ON st.sid = sc.sid
GROUP BY st.sid
HAVING COUNT(sc.cid)< (SELECT COUNT(c.cid) FROM course as c);

-- 查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
SELECT st.*
FROM student st 
LEFT JOIN sc on st.sid = sc.sid
WHERE sc.cid in (SELECT sc.cid FROM sc WHERE sc.sid = '01' )
GROUP BY st.sid
						
-- 查询和" 01 "号的同学学习的课程完全相同的其他同学的信息
select st.* from student st
left join sc sc1 on sc1.sid=st.sid
group by st.sid
having group_concat(sc1.cid) = 
(
select group_concat(sc2.cid) from student st2
left join sc sc2 on sc2.sid=st2.sid
where st2.sid ='01'
) AND st.sid != '01'

-- 查询没学过"张三"老师讲授的任一门课程的学生姓名
SELECT st.sname
FROM student st
WHERE st.sid NOT IN 
(
	SELECT sc.sid FROM sc
	LEFT JOIN course on course.cid = sc.cid
	LEFT JOIN teacher on teacher.tid = course.tid 
	WHERE teacher.tname = '张三'
)

-- 查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩
SELECT st.sid,st.sname,AVG(sc.score) as 平均成绩
FROM student st
LEFT JOIN sc on sc.sid = st.sid
WHERE sc.score < 60
GROUP BY st.sid
HAVING  COUNT(sc.cid)>=2

-- 查询" 01 "课程分数小于 60，按分数降序排列的学生信息
SELECT st.*,sc.score as 01课程分数
FROM student st
RIGHT JOIN sc on st.sid = sc.sid
WHERE sc.score < 60 AND sc.cid = '01'
ORDER BY sc.score DESC

-- 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩
select st.sid,st.sname,avg(sc4.score) “平均分”,sc.score “语文”,sc2.score “数学”,sc3.score “英语” from student st
left join sc on sc.sid=st.sid and sc.cid='01'
left join sc sc2 on sc2.sid=st.sid and sc2.cid='02'
left join sc sc3 on sc3.sid=st.sid and sc3.cid='03'
left join sc sc4 on sc4.sid=st.sid
group by st.sid
order by SUM(sc4.score) desc

-- 查询各科成绩最高分、最低分和平均分
SELECT sc.cid,MAX(sc.score),MIN(sc.score),AVG(sc.score)
FROM sc
GROUP BY sc.cid

-- 按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺
select *, rank() over(partition by cid order by score desc) AS ranked from sc;

-- 查询学生的总成绩，并进行排名，总分重复时不保留名次空缺
SELECT a.*,dense_rank() over(ORDER BY a.total_socre DESC) AS Ranked FROM
(SELECT *,SUM(score) AS total_socre FROM sc GROUP BY sid) AS a;


-- 统计各科成绩各分数段人数：课程编号，[100-85)，[85-70)，[70-60)，[60-0] 及所占百分比
SELECT cid AS 课程ID, 
SUM(CASE WHEN score <= 60 THEN 1 ELSE 0 END)/count(sid) AS 百分比1,
SUM(CASE WHEN score >60 AND score <=70 THEN 1 ELSE 0 END)/count(sid) AS 百分比2,
SUM(CASE WHEN score >70 AND score <=85 THEN 1 ELSE 0 END)/count(sid) AS 百分比3,
SUM(CASE WHEN score >85 THEN 1 ELSE 0 END)/count(sid) AS 百分比4
FROM sc GROUP BY cid ORDER BY cid

-- 查询各科成绩前三名的记录
SELECT * FROM
(SELECT *,rank() over(PARTITION by cid ORDER BY score desc) as ranked FROM sc) as a
WHERE a.ranked <=3;
