-- 创建表
CREATE TABLE IF NOT EXISTS test (
  test_id INT,
  test_name STRING,
  test_date DATE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- 清空表
truncate table test;

-- 从文件导入数据
load data local inpath "/root/test.csv" into table test;

-- 通过语句导入数据
INSERT INTO test VALUES (1,'搜索引擎','2000-01-08');
INSERT INTO test VALUES (2,'视频分享','2001-02-08');
INSERT INTO test VALUES (3,'社交网络','2002-03-08');
INSERT INTO test VALUES (4,'社交网络','2003-04-08');
INSERT INTO test VALUES (5,'电商','2004-05-08');
INSERT INTO test VALUES (6,'搜索引擎','2005-06-08');
INSERT INTO test VALUES (7,'百科全书','2006-07-08');
INSERT INTO test VALUES (8,'社交网络','2007-08-08');
INSERT INTO test VALUES (9,'门户网站','2008-09-08');
INSERT INTO test VALUES (10,'社交新闻','2009-10-08');
