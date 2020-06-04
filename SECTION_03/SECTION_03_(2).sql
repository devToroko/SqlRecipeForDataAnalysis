select
	*
from
	review r;
	
select
 	count(*) as total_count
 	, count(distinct user_id) as user_count
 	, count(distinct product_id) as product_count
 	, sum(score) as sum
 	, avg(score) as avg
 	, max(score) as max
 	, min(score) as min
from 
	review r
;
	

select
  user_id
  , count(*) as total_count
  , count(distinct product_id) as product_count
  , sum(score) as sum
  , avg(score) as avg
  , max(score) as max
  , min(score) as min
from 
  review
group by
  user_id
;



select
  user_id
  , product_id
  , score
  , avg(score) over() as avg_score
  , avg(score) over(partition by user_id) as user_avg_score
  , score - avg(score) over(partition by user_id) as user_avg_score_diff
from
  review
;


select
 *
 from popular_products pp;



select
 product_id
 , score
 , row_number() over(order by score desc) as row
 , rank() over(order by score desc) as rank
 , dense_rank() over(order by score desc) as dense_rank
 -- 순서와는 관계 없지만 추가적으로 lag와 lead도 보여드리겠습니다.
 , lag(product_id) over(order by score desc) as lag1
 , lag(product_id,2) over(order by score desc) as lag2
 , lead(product_id) over(order by score desc) as lead1
 , lead(product_id,2) over(order by score desc) as lead2
from
 popular_products
order by
 row
;




select
 *
 from popular_products pp;

select
 product_id
 , score
 -- 점수 순서로 유일한 순위를 붙임
 , row_number() over(order by score desc) as row
 -- 순위 상위부터 누계 점수 계산하기
 , sum(score) 
     over(order by score desc
       rows between unbounded preceding and current row
   ) as cum_score
 -- 현재 행의 앞 뒤의 행이 가진 값을 기반으로 평균 점수 계산하기
 , avg(score) 
     over(order by score desc
 	   rows between 1 preceding and 1 following
   ) as local_avg
 -- 순위가 높은 상품 ID 추출하기
 , first_value(product_id) 
 	 over(order by score desc
 	   rows between unbounded preceding and unbounded following
   ) as first_value
 -- 순위가 낮은 상품 ID 추출하기
 , last_value(product_id) 
 	 over(order by score desc
 	   rows between unbounded preceding and unbounded following
   ) as last_value
from
 popular_products
order by 
 row
;


select
  product_id
  , row_number() over(order by score desc) as row
  , array_agg(product_id) 
  	over(order by score desc 
  		rows between unbounded preceding and unbounded following
  	) as whole_agg
  , array_agg(product_id) over(order by score desc
  		rows between unbounded preceding and current row
  	) as cum_agg
  , array_agg(product_id) over(order by score desc 
  		rows between 1 preceding and 1 following
  	) as local_agg
from
 popular_products
where category = 'action'
order by row
;


select
 category
 , product_id
 , score
 , row_number() over(partition by category order by score desc) as row
 , rank() over(partition by category order by score desc) as rank
 , dense_rank() over(partition by category order by score desc) as dense_rank
from
 popular_products
order by
 category, row
;


select 
 *
from
 ( select
 	category
 	, product_id
 	, score
 	, row_number() 
 	 	over(partition by category order by score desc) 
 	  as rank
   from popular_products
 ) popular_products_with_rank
where rank <= 2
;



select distinct
 category
 , first_value(product_id)
 	over(partition by category order by score desc 
 	  rows between unbounded preceding and unbounded following)
   as product_id
from
 popular_products
;



select * from daily_kpi dk;


select
 dt
 , max(case when indicator = 'impressions' then val end) as impressions
 , max(case when indicator = 'sessions' then val end) as sessions
 , max(case when indicator = 'users' then val end) as users
from
 daily_kpi
group by dt
order by dt
;


select * from purchase_detail_log pdl;


select
 purchase_id
 , string_agg(product_id,', ') as product_ids
 , sum(price) as amount
from purchase_detail_log
group by purchase_id
order by purchase_id
;



select * from quarterly_sales;


select
 q.year
 -- Q1 ~ Q4 까지의 레이블 이름 출력하기
 ,case 
 	when p.idx = 1 then 'q1'
 	when p.idx = 2 then 'q2'
 	when p.idx = 3 then 'q3'
 	when p.idx = 4 then 'q4'
  end as quarter
 -- Q1 에서  Q4 까지의 매출 출력하기
 , case
 	when p.idx = 1 then q.q1
 	when p.idx = 2 then q.q2
 	when p.idx = 3 then q.q3
 	when p.idx = 4 then q.q4
  end as sales
from 
 quarterly_sales as q
 cross join
 -- 행으로 전개하고 싶은 열의 수만큼 순번 테이블 만들기
 (
 			  select 1 as idx
 	union all select 2 as idx
 	union all select 3 as idx
 	union all select 4 as idx
 ) as p
;
 


select * from purchase_log pl;


DROP TABLE IF EXISTS purchase_log;
CREATE TABLE purchase_log (
    purchase_id integer
  , product_ids varchar(255)
);

INSERT INTO purchase_log
VALUES
    (100001, 'A001,A002,A003')
  , (100002, 'D001,D002')
  , (100003, 'A001')
;

select * from purchase_log;

select unnest(array['A001','A002','A003']) as purchase_id;

select
  purchase_id
  , product_id
from
  purchase_log as p
cross join 
  unnest(string_to_array(product_ids,',')) as product_id
;


select
  purchase_id
  , regexp_split_to_table(product_ids,',') as purchase_id
from
  purchase_log
;



select * from app1_mst_users amu;

select * from app2_mst_users amu;


select 'app1' as app_name, user_id, name, email from app1_mst_users
union all
select 'app2' as app_name, user_id, name, null as email from app2_mst_users;



select * from mst_categories mc;

select * from category_sales cs;

select * from product_sale_ranking psr;

select
	m.category_id
	, m."name"
	, s.sales
	, r.product_id as top_sale_product
from
	mst_categories as m
  left join
	category_sales as s
	on m.category_id = s.category_id
  left join
	product_sale_ranking as r
	on m.category_id = r.category_id
	and r.rank = 1
;


select
 m.category_id
 , m."name"
 -- 상관 서브 쿼리를 사용해 카테고리별로 매출액 추출하기
 , ( select s.sales
 	from category_sales as s
 	where m.category_id = s.category_id
 ) as sales
 -- 상관 서브쿼리를 사용해 카테고리별로 최고 매출 상품을
 -- 하나 추출하기(순위로 따로 앙ㅂ축하지 않아도 됨)
 , ( select r.product_id
 	 from product_sale_ranking as r
 	 where m.category_id = r.category_id
 	 order by sales desc
 	 limit 1
 ) as top_sale_product
from
 mst_categories as m
;



select * from mst_users_with_card_number muwcn;


select * from purchase_log pl;
select * from mst_categories mc;



DROP TABLE IF EXISTS purchase_log;
CREATE TABLE purchase_log (
    purchase_id integer
  , user_id     varchar(255)
  , amount      integer
  , stamp       varchar(255)
);

INSERT INTO purchase_log
VALUES
    (10001, 'U001', 200, '2017-01-30 10:00:00')
  , (10002, 'U001', 500, '2017-02-10 10:00:00')
  , (10003, 'U001', 200, '2017-02-12 10:00:00')
  , (10004, 'U002', 800, '2017-03-01 10:00:00')
  , (10005, 'U002', 400, '2017-03-02 10:00:00')
;


select 
	*
from 
	mst_users_with_card_number as m
  left join
  	purchase_log as p
  	on m.user_id = p.user_id 	
;


select
 	m.user_id
 	, m.card_number
 	, count(p.user_id) as purchase_count
	-- 신용 카드 번호를 등록한 경우 1, 등록하지 않은 경우 0으로 표현하기
 	, case when m.card_number is not null then 1 else 0 end as has_card
	-- 구매 이력이 있는 경우 1, 없는 경우 0으로 표현하기
 	, sign(count(p.user_id)) as has_purchased
from
	mst_users_with_card_number as m
 	left join
 	purchase_log as p
 	on m.user_id = p.user_id
group by m.user_id, m.card_number
order by user_id
;


select * from product_sales ps;


with 
product_sale_ranking as (
  select
  	category_name
  	, product_id
  	, sales
  	, row_number() over(partition by category_name order by sales desc) as rank
  from
  	product_sales
) 
select * 
from product_sale_ranking;
 	

with 
product_sale_ranking as (
  select
  	category_name
  	, product_id
  	, sales
  	, row_number() over(partition by category_name order by sales desc) as rank
  from
  	product_sales
), mst_rank as (
  select distinct rank
  from product_sale_ranking psr
)
select * from mst_rank;



with 
product_sale_ranking as (
  select
  	category_name
  	, product_id
  	, sales
  	, row_number() over(partition by category_name order by sales desc) as rank
  from
  	product_sales
)
, mst_rank as (
  select distinct rank
  from product_sale_ranking psr
)
select
  m.rank
  , r1.product_id	as dvd
  , r1.sales		as dvd_sales
  , r2.product_id	as cd
  , r2.sales		as cd_sales
  , r3.product_id	as book
  , r3.sales		as book_sales
from
	mst_rank as m
  left join
  	product_sale_ranking as r1
  	on m.rank = r1."rank"
  	and r1.category_name = 'dvd'
  left join
  	product_sale_ranking as r2
  	on m.rank = r2."rank"
  	and r2.category_name = 'cd'
  left join
  	product_sale_ranking as r3
  	on m.rank = r3.rank
  	and r3.category_name = 'book'
order by m.rank
;
	
  	
  	
with
mst_devices as (
  select 1 as device_id, 'PC' as device_name
  union all
  select 2 as device_id, 'SP' as device_name
  union all
  select 3 as device_id, '애플리케이션' as device_name
)
select * from mst_devices;



with
mst_devices as (
  select 1 as device_id, 'PC' as device_name
  union all
  select 2 as device_id, 'SP' as device_name
  union all
  select 3 as device_id, '애플리케이션' as device_name
)
select
  *
from
  mst_users as u
  left join
  mst_devices as d
  on u.register_device = d.device_id
;
select * from mst_users mu;


with
mst_devices(device_id,device_name) as (
  values
   (1, 'PC')
  ,(2, 'SP')
  ,(3, '애플리케이션')
)
select * from mst_devices;


with
series as (
  -- 1~5 까지의 순번 생성하기
  select generate_series(1,5) as idx
)
select * from series;




  	