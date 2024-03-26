CREATE TABLE IF NOT EXISTS web (
  ranking INT COMMENT '排名',
  url STRING COMMENT '网址',
  type STRING COMMENT '类型'
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

load data local inpath "/root/web.csv" into table web;

INSERT INTO web VALUES ('1','https://www.google.com/','搜索引擎');
INSERT INTO web VALUES ('2','https://www.youtube.com/','视频分享');
INSERT INTO web VALUES ('3','https://www.facebook.com/','社交网络');
INSERT INTO web VALUES ('4','https://twitter.com/','社交网络');
INSERT INTO web VALUES ('5','https://www.amazon.com/','电商');
INSERT INTO web VALUES ('6','https://www.baidu.com/','搜索引擎');
INSERT INTO web VALUES ('7','https://www.wikipedia.org/','百科全书');
INSERT INTO web VALUES ('8','https://www.instagram.com/','社交网络');
INSERT INTO web VALUES ('9','https://www.yahoo.com/','门户网站');
INSERT INTO web VALUES ('10','https://www.reddit.com/','社交新闻');
INSERT INTO web VALUES ('11','https://www.tiktok.com/','短视频');
INSERT INTO web VALUES ('12','https://www.microsoft.com/','软件和科技');
INSERT INTO web VALUES ('13','https://www.apple.com/','软件和科技');
INSERT INTO web VALUES ('14','https://www.netflix.com/','流媒体');
INSERT INTO web VALUES ('15','https://www.ebay.com/','电商');
INSERT INTO web VALUES ('16','https://www.pinterest.com/','社交分享');
INSERT INTO web VALUES ('17','https://www.linkedin.com/','职业社交');
INSERT INTO web VALUES ('18','https://open.spotify.com/','流媒体');
INSERT INTO web VALUES ('19','https://www.quora.com/','问答');
INSERT INTO web VALUES ('20','https://www.dailymotion.com/','视频分享');