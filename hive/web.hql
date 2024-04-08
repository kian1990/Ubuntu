-- 创建表
CREATE TABLE IF NOT EXISTS web (
  web_ranking INT,
  web_id BIGINT,
  web_url STRING,
  web_type STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- 清空表
truncate table web;

-- 从文件导入数据
load data local inpath "/root/web.csv" into table web;

-- 通过语句导入数据
INSERT INTO web VALUES (1,421282199801130018,'https://www.google.com/','搜索引擎');
INSERT INTO web VALUES (2,421282199202290018,'https://www.youtube.com/','视频分享');
INSERT INTO web VALUES (3,421282200103120018,'https://www.facebook.com/','社交网络');
INSERT INTO web VALUES (4,421282198504030018,'https://twitter.com/','社交网络');
INSERT INTO web VALUES (5,421282197506050018,'https://www.amazon.com/','电商');
INSERT INTO web VALUES (6,421282196809120018,'https://www.baidu.com/','搜索引擎');
INSERT INTO web VALUES (7,421282197212310018,'https://www.wikipedia.org/','百科全书');
INSERT INTO web VALUES (8,421282199309070018,'https://www.instagram.com/','社交网络');
INSERT INTO web VALUES (9,421282199507080018,'https://www.yahoo.com/','门户网站');
INSERT INTO web VALUES (10,421282199611060018,'https://www.reddit.com/','社交新闻');
INSERT INTO web VALUES (11,421282196807220018,'https://www.tiktok.com/','短视频');
INSERT INTO web VALUES (12,421282197909300018,'https://www.microsoft.com/','软件和科技');
INSERT INTO web VALUES (13,421282198310310018,'https://www.apple.com/','软件和科技');
INSERT INTO web VALUES (14,421282198911300018,'https://www.netflix.com/','流媒体');
INSERT INTO web VALUES (15,421282200205030018,'https://www.ebay.com/','电商');
INSERT INTO web VALUES (16,421282199412290018,'https://www.pinterest.com/','社交分享');
INSERT INTO web VALUES (17,421282195909240018,'https://www.linkedin.com/','职业社交');
INSERT INTO web VALUES (18,421282201007120018,'https://open.spotify.com/','流媒体');
INSERT INTO web VALUES (19,421282202006050018,'https://www.quora.com/','问答');
INSERT INTO web VALUES (20,421282202109040018,'https://www.dailymotion.com/','视频分享');
