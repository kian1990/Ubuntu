select from_unixtime(unix_timestamp(concat('2024', '-','04', '-','03',' ','00:00:00'),'yyyy-MM-dd hh:mm:ss'));
select from_unixtime(unix_timestamp(),'yyyy-MM-dd');
select date_format(to_date(concat('2024','-','04','-','03')),'yyyyMMdd');
select unix_timestamp('20240407','yyyyMMdd')
select unix_timestamp('1970-01-01 08:00:00');
select datediff(current_date,'1990-08-02');
select cast(web_id as string) from web;
set hivevar:test = 12345;
select ${test}

-- 查询截取出生年月字段
select substr(web_id,7,8) from web;

-- 查询出生年月并进行字符串拼接
select concat(substr(web_id,7,4),'-',substr(web_id,11,2),'-',substr(web_id,13,2)) from web;
select concat_ws('-',substr(web_id,7,4),substr(web_id,11,2),substr(web_id,13,2)) from web;

-- 查询出生年月并转换成时间戳
select unix_timestamp(substr(web_id,7,8),'yyyyMMdd') from web;

-- 查询出生年月并计算出生天数
select datediff(current_date,concat(substr(web_id,7,4),'-',substr(web_id,11,2),'-',substr(web_id,13,2))) from web;
select datediff(current_date,concat_ws('-',substr(web_id,7,4),substr(web_id,11,2),substr(web_id,13,2))) from web;

-- 年龄18岁的出生年月
select concat(year(current_date)-18,'-',lpad(month(current_date),2,'0'),'-',lpad(day(current_date),2,'0'));

-- 年龄18岁的时间戳
select unix_timestamp(concat(year(current_date)-18,lpad(month(current_date),2,'0'),lpad(day(current_date),2,'0')),'yyyyMMdd');

-- 年龄18岁的出生天数
select datediff(current_date,concat(year(current_date)-18,'-',month(current_date),'-',day(current_date)));

-- 通过出生天数查询大于18岁的项目
select datediff(current_date,concat_ws('-',substr(web_id,7,4),substr(web_id,11,2),substr(web_id,13,2))) as web_day from web group by datediff(current_date,concat_ws('-',substr(web_id,7,4),substr(web_id,11,2),substr(web_id,13,2))) having web_day >= 6575;

-- 通过时间戳查询大于18岁的项目
select unix_timestamp(concat(substr(web_id,7,4),'-',substr(web_id,11,2),'-',substr(web_id,13,2),' ','00:00:00')) as web_timestamp from web group by unix_timestamp(concat(substr(web_id,7,4),'-',substr(web_id,11,2),'-',substr(web_id,13,2),' ','00:00:00')) having web_timestamp <= 1144339200;

-- 查询所有大于18岁的项目
select web_ranking,web_id,web_url,web_type,datediff(current_date,concat_ws('-',substr(web_id,7,4),substr(web_id,11,2),substr(web_id,13,2))) as web_day from web group by web_ranking,web_id,web_url,web_type,datediff(current_date,concat_ws('-',substr(web_id,7,4),substr(web_id,11,2),substr(web_id,13,2))) having web_day >= 6575;
select web_ranking,web_id,web_url,web_type,unix_timestamp(substr(web_id,7,8),'yyyyMMdd') as web_timestamp from web group by web_ranking,web_id,web_url,web_type,unix_timestamp(substr(web_id,7,8),'yyyyMMdd') having web_timestamp <= 1144425600;

-- 将查询结果写入表
create table if not exists web18(web_ranking int,web_id bigint,web_url string,web_type string,web_day bigint);
insert overwrite table web18 select web_ranking,web_id,web_url,web_type,datediff(current_date,concat_ws('-',substr(web_id,7,4),substr(web_id,11,2),substr(web_id,13,2))) as web_day from web group by web_ranking,web_id,web_url,web_type,datediff(current_date,concat_ws('-',substr(web_id,7,4),substr(web_id,11,2),substr(web_id,13,2))) having web_day >= 6575;


create table if not exists web1(web_ranking int,web_id bigint,web_url string,web_type string,web_date date);
insert overwrite table web1 select web_ranking,web_id,web_url,web_type,concat_ws('-',substr(web_id,7,4),substr(web_id,11,2),substr(web_id,13,2)) from web;
