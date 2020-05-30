select
	*
from mst_users;

select
	user_id
	, case
		when register_device = 1 then '데스크톱'
		when register_device = 2 then '스마트폰'
		when register_device = 3 then '애플리케이션'
	  end as device_name
from mst_users;




select * from access_log;












-- 코드 5-2 래퍼러 도메인을 추출하는 쿼리
select
	stamp
	, substring(referrer from 'https?://([^/]*)') as reffer_host
from access_log;


select
	stamp
	, url
	, substring(url from '//[^/]+([^?#]+)') as path
	, substring(url from 'id=([^&]*)') as id
from 
	access_log al;



select
	stamp
	, url
	, split_part(substring(url from '//[^/]+([^?#]+)' ), '/',2) as path1
	, split_part(substring(url from '//[^/]+([^?#]+)' ), '/',3) as path2
from access_log al;



select 
	current_date as dt
	, current_timestamp as stamp
	, localtimestamp as stamp_with_local
;


select
	cast('2016-01-30' as date) as dt
	, cast('2016-01-30 12:00:00' as timestamp) as stamp;




select 
	stamp
	, extract(year from stamp) as year
	, extract(month from stamp) as month
	, extract(day from stamp) as day
	, extract(hour from stamp) as hour
from 
	(select cast('2020-05-30 12:00:00' as timestamp) as stamp) as t;



select 
	stamp
	, substring(stamp, 1, 4) as year
	, substring(stamp, 6, 2) as month
	, substring(stamp, 9, 2) as day
	, substring(stamp, 12, 2) as hour
from
	(select cast('2020-05-30 12:00:00' as text) as stamp) as t;






select * from purchase_log_with_coupon plwc;

select
	purchase_id
	, amount
	, coupon
	, amount - coupon as discount_amount1
	, amount - coalesce(coupon,0) as discount_amount2
from 
	purchase_log_with_coupon plwc
;



select * from mst_user_location;


select
	user_id
	, concat(pref_name,city_name) as pref_city_1
	, pref_name || city_name as pref_city_2
from 
	mst_user_location mul;


select * from quarterly_sales;


select 
	year
	, q1
	, q2
	, case
		when q1 < q2 then '+'
		when q1 = q2 then ' '
		else '-'
	  end as judge_q1_q2
	, q2 - q1 as diff_q2_q1
	, sign(q2 - q1) as sign_q2_q1
from 
	quarterly_sales
order by
	year
;



-- 코드 6-3
select 
	year
	, greatest(q1,q2,q3,q4) as greatest_sales
	, least(q1,q2,q3,q4) as least_sales
from 
	quarterly_sales
order by
	year;


select
	year
	, (q1 + q2 + q3 + q4) / 4 as average
from
	quarterly_sales
order by
	year;



select
	year
	, (coalesce(q1,0) + coalesce(q2,0) + coalesce(q3,0) + coalesce(q4,0) ) / 4 
		as average
from 
	quarterly_sales
order by
	year;



select
	year
	, (coalesce(q1,0) + coalesce(q2,0) + coalesce(q3,0) + coalesce(q4,0) ) 
	/ (sign(coalesce(q1,0)) + sign(coalesce(q2,0)) + sign(coalesce(q3,0)) + sign(coalesce(q4,0)))
		as average
from 
	quarterly_sales
order by
	year;



select * from advertising_stats;


select
	dt
	, ad_id
	, clicks / impressions as ctr
	, cast(clicks as double precision) / impressions as ctr2
	, 100.0 * clicks / impressions as ctr_as_percent
from
	advertising_stats 
where
	dt = '2017-04-01'
order by
	dt, ad_id;



select
	dt
	, ad_id
	, case
		when impressions > 0 then 100.0 * clicks / impressions
	  end as ctr_as_percent_by_case
	, 100.0 * clicks / nullif(impressions,0) as ctr_as_percent_by_null
from advertising_stats
order by dt, ad_id;


select * from location_2d;

select
	sqrt(power(x1 - x2,2) + power(y1 - y2,2)) as dist
	-- PostgreSQL에서 제공하는  point 자료형과 <-> 연산자를 쓰면 위와 동일한 계산을 사용한다.
	, point(x1,y1) <-> point(x2,y2) as dist_2
from 
	location_2d;




select * from mst_users_with_dates;

select 
	user_id
	-- PostgreSQL 의 경우 interval 자료형의 데이터에 사칙 연산 적용
	, register_stamp::timestamp as register_stamp
	, register_stamp::timestamp + '1 hour'::interval as after_1_hour
	, register_stamp::timestamp - '30 minutes'::interval as before_30_minutes
	, register_stamp::date as register_date
	, (register_stamp::date + '1 day'::interval)::date as after_1_day
	, (register_stamp::date - '1 month'::interval)::date as before_1_month
from 
	mst_users_with_dates
;





select
	cast('2016-01-30' as date) as dt
	, cast('2016-01-30 12:00:00' as timestamp) as stamp
	-- PostgreSQL, RedShift 의 경우 'value::type' 사용도 가능, value에는 컬럼이름도 가능
	, '2020-01-30'::date as dt_2
	, '2020-01-30'::timestamp as stamp_2;






select
	user_id
	, current_date as today
	, register_stamp::date as register_date
	, current_date - register_stamp::date as diff_days
from mst_users_with_dates
;



select
	user_id
	, current_date as today
	, register_stamp::date as register_date
	, birth_date::date as birth_date1
	, extract(year from age(birth_date::date)) as current_age
	, extract(year from age(register_stamp::date,birth_date::date)) as register_age
from 
	mst_users_with_dates
;


select * from mst_users_with_dates muwd;



select
	user_id
	, substring(register_stamp,1,10) as register_date
	, birth_date
	-- 등록 시점의 나이 계산하기
	,floor(
		(  cast(replace(substring(register_stamp,1,10),'-','') as integer)
			- cast(replace(birth_date,'-','') as integer)
		) / 10000
	) as register_age
	-- 현재 시점의 나이 계산하기
	, floor(
		(  cast(replace(cast(current_date as text),'-','') as integer)
			- cast(replace(birth_date,'-','') as integer)
		) / 10000
	) as current_age
from 
	mst_users_with_dates
;



select
	cast('127.0.0.1' as inet) < cast('127.0.0.2' as inet) as lt
	, cast('127.0.0.1' as inet) > cast('127.0.0.2' as inet) as gt
;



select cast('127.0.0.1' as inet) << cast('127.0.0.0/8' as inet) as is_contained;


select 
	ip
	, cast(split_part(ip,'.',1) as integer) as ip_part_1
	, cast(split_part(ip,'.',2) as integer) as ip_part_2
	, cast(split_part(ip,'.',3) as integer) as ip_part_3
	, cast(split_part(ip,'.',4) as integer) as ip_part_4
from 
--	(select '192.168.0.1' as ip) as t
	(select cast('192.168.0.1' as text) as ip) as t;
;



select
	ip
	, cast(split_part(ip,'.',1) as integer) * 2^24 
	+ cast(split_part(ip,'.',2) as integer) * 2^16 
	+ cast(split_part(ip,'.',3) as integer) * 2^8 
	+ cast(split_part(ip,'.',4) as integer) * 2^0
	as ip_integer
from 
--	(select '192.168.0.1' as ip) as t
	(select cast('192.168.0.1' as text) as ip) as t
;



select 
	ip
	,  lpad(split_part(ip,'.',1),3,'0') 
	|| lpad(split_part(ip,'.',2),3,'0')
	|| lpad(split_part(ip,'.',3),3,'0')
	|| lpad(split_part(ip,'.',4),3,'0')
	as ip_padding
from 
--	(select '192.168.0.1' as ip) as t
	(select cast('192.168.0.1' as text) as ip) as t
;
	

