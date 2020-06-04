# SECTION 04 - 매출을 파악하기 위한 데이터 추출

<br>

<br>

<br>

<br>

## 9강 - 시계열 기반으로 데이터 집계하기

<br>

매일 매출을 단순하게 수치로만 확인하면 장기적인 관점에서 어떤 경향이 있는지 알 수 없습니다.<br>하지만 시계열로 매출 금액을 집계하면 어떤 규칙성을 찾을 수도 있으며, 어떤 기간과 비교했을 때 변화폭을 확인 할 수도 있습니다.

<br>

추가로 이번 9강에서는 데이터 집약 + 변화를 이해하기 쉽게 표현할 수 있는 리포팅 방법과 관련된 내용도 소개합니다.

<br>

<br>

<br>

**샘플 데이터**

2014~2015 년까지 2년에 걸친 매출 데이터를 샘플로 설명하겠습니다.

<br>

**데이터 9 - 1**  purchase_log 테이블
| dt         | order_id | user_id    | purchase_amount |
| ---------- | -------- | ---------- | --------------- |
| 2014-01-01 | 1        | rhwpvvitou | 13900           |
| 2014-01-01 | 2        | hqnwoamzic | 10616           |
| 2014-01-02 | 3        | tzlmqryunr | 21156           |
| 2014-01-02 | 4        | wkmqqwbyai | 14893           |
| 2014-01-03 | 5        | ciecbedwbq | 13054           |
| 2014-01-03 | 6        | svgnbqsagx | 24384           |
| 2014-01-03 | 7        | dfgqftdocu | 15591           |
| 2014-01-04 | 8        | sbgqlzkvyn | 3025            |
| 2014-01-04 | 9        | lbedmngbol | 24215           |
| 2014-01-04 | 10       | itlvssbsgx | 2059            |
| 2014-01-05 | 11       | jqcmmguhik | 4235            |
| 2014-01-05 | 12       | jgotcrfeyn | 28013           |
| 2014-01-05 | 13       | pgeojzoshx | 16008           |
| 2014-01-06 | 14       | msjberhxnx | 1980            |
| 2014-01-06 | 15       | tlhbolohte | 23494           |
| 2014-01-06 | 16       | gbchhkcotf | 3966            |
| 2014-01-07 | 17       | zfmbpvpzvu | 28159           |
| 2014-01-07 | 18       | yauwzpaxtx | 8715            |
| 2014-01-07 | 19       | uyqboqfgex | 10805           |
| 2014-01-08 | 20       | hiqdkrzcpq | 3462            |
| 2014-01-08 | 21       | zosbvlylpv | 13999           |
| 2014-01-08 | 22       | bwfbchzgnl | 2299            |
| 2014-01-09 | 23       | zzgauelgrt | 16475           |
| 2014-01-09 | 24       | qrzfcwecge | 6469            |
| 2014-01-10 | 25       | njbpsrvvcq | 16584           |
| 2014-01-10 | 26       | cyxfgumkst | 11339           |

<br>

<br>

<br>

<br>

### [ 1 ]  날짜별 매출 집계하기

매출을 집계하는 업무에서는 가로 축에 날짜, 세로 축에 금액을 표현하는 그래프를 사용합니다.<br> 날짜별로 매출을 집계하고, 동시에 평균 구매액을 집계하고, 다음 그림과 같은 리포트를 생성하는 SQL을 소개합니다.

<br>

**코드 9 - 1**  날짜별 매출과 평균 구매액을 집계하는 쿼리

```sql
select
   dt
  ,count(*) as purchase_count
  ,sum(purchase_amount) as total_amount
  ,avg(purchase_amount) as avg_amount
from purchase_log
group by dt
order by dt;
```

<br>

| dt         | purchase_count | total_amount | avg_amount             |
| ---------- | -------------- | ------------ | ---------------------- |
| 2014-01-01 | 2              | 24516        | 12258.0000000000000000 |
| 2014-01-02 | 2              | 36049        | 18024.500000000000     |
| 2014-01-03 | 3              | 53029        | 17676.333333333333     |
| 2014-01-04 | 3              | 29299        | 9766.3333333333333333  |
| 2014-01-05 | 3              | 48256        | 16085.333333333333     |
| 2014-01-06 | 3              | 29440        | 9813.3333333333333333  |
| 2014-01-07 | 3              | 47679        | 15893.000000000000     |
| 2014-01-08 | 3              | 19760        | 6586.6666666666666667  |
| 2014-01-09 | 2              | 22944        | 11472.0000000000000000 |
| 2014-01-10 | 2              | 27923        | 13961.5000000000000000 |

<br>

<br>

<br>

<br>

### [ 2 ]  이동평균을 사용한 날짜별 추이 보기

위처럼 나온 결과로 그래프를 그리면 매출이 상승하는 경향이 있는지,, 하락하는 경향이 있는지 판단하기 어려운데, 이러한 경우에는 7일 동안의 평균 매출을 사용한 '7일 이동 평균'으로 표현하는 것이 좋습니다.

<br>

코드 9 - 2  날짜별 매출과 7일 이동평균을 집계하는 쿼리

```sql
select 
  dt
  ,sum(purchase_amount) as total_amount
  ,avg(sum(purchase_amount)) over(order by dt rows between 6 preceding and current row)
   as seven_day_avg
  ,case
  	when
  	  7 = count(*)
  	  over(order by dt rows between 6 preceding and current row)
  	then 
  	  avg(sum(purchase_amount)) over(order by dt rows between 6 preceding and current row)
  	end 
  	as seven_day_avg_strict
from purchase_log
group by dt
order by dt
;
```

<br>

| dt         | total_amount | seven_day_avg      | seven_day_avg_strict |
| ---------- | ------------ | ------------------ | -------------------- |
| 2014-01-01 | 24516        | 24516.000000000000 |                      |
| 2014-01-02 | 36049        | 30282.500000000000 |                      |
| 2014-01-03 | 53029        | 37864.666666666667 |                      |
| 2014-01-04 | 29299        | 35723.250000000000 |                      |
| 2014-01-05 | 48256        | 38229.800000000000 |                      |
| 2014-01-06 | 29440        | 36764.833333333333 |                      |
| 2014-01-07 | 47679        | 38324.000000000000 | 38324.000000000000   |
| 2014-01-08 | 19760        | 37644.571428571429 | 37644.571428571429   |
| 2014-01-09 | 22944        | 35772.428571428571 | 35772.428571428571   |
| 2014-01-10 | 27923        | 32185.857142857143 | 32185.857142857143   |

<br>

참고로 코드 예의 seven_day_av 는 과거 7일분의 데이터를 추출할 수 없는 첫 번째 6일간에 대해 해당 6일만을 가지고 평균을 구하고 있습니다. 

만약 7일의 데이터가 모두 있는  경우에만 7일 이동평균을 구하고자 한다면, seven_day_avg_strict를 사용하기 바랍니다.

<br>

<br>

<br>

<br>

### [ 3 ]  당월 매출 누계 구하기

날짜별로 매출을 집계하고, 해당 월의 누계를 구하는 리포트를 만드는 방법에 대해 알아보겠습니다.

<br>

**코드 9 - 3**  날짜별 매출과 당월 누계 매출을 집계하는 쿼리

```sql
select
  dt
  -- 연-월 추출하기
  , substring(dt,1,7) as year_month
  , sum(purchase_amount) as total
  , sum(sum(purchase_amount))
  		over(partition by substring(dt,1,7) order by dt rows unbounded preceding)
  	as agg_amount
from purchase_log
group by dt
order by dt;
```

<br>

| dt         | year_month | total | agg_amount |
| ---------- | ---------- | ----- | ---------- |
| 2014-01-01 | 2014-01    | 24516 | 24516      |
| 2014-01-02 | 2014-01    | 36049 | 60565      |
| 2014-01-03 | 2014-01    | 53029 | 113594     |
| 2014-01-04 | 2014-01    | 29299 | 142893     |
| 2014-01-05 | 2014-01    | 48256 | 191149     |
| 2014-01-06 | 2014-01    | 29440 | 220589     |
| 2014-01-07 | 2014-01    | 47679 | 268268     |
| 2014-01-08 | 2014-01    | 19760 | 288028     |
| 2014-01-09 | 2014-01    | 22944 | 310972     |
| 2014-01-10 | 2014-01    | 27923 | 338895     |

<br>

이 쿼리에서는 날짜별과 매출과 월별 누계 매출을 동시에 집계하고자 substring 함수를 사용해 날짜에서 '연과 월' 부분을 추출했습니다. <br>

이어서 group by dt 로 날짜별로 집계한 합계 금액 SUM(purchase_amount) 에 SUM 윈도 함수를 적용해서, SUM(SUM(purchase_amount)) over(order by dt) 로 날짜 순서대로 누계 매출을 계산합니다. 

추가로 매월 누계를 구하기 위해 over 구에  PARTITION BY substring(dt,1,7) 을 추가해 월별로 파티션을 생성했습니다.

<br>

그런데 위 코드는 가독성 측면에서 좋지 않으니 아래와 같은 과정들로 수정해 나가보겠습니다.

<br>

**코드 9 - 4**  날짜별 매출을 일시 테이블로 만드는 쿼리

```sql
with
daily_purchase as (
	 select
	    dt
	  , substring(dt,1,4) as year
	  , substring(dt,6,2) as month
	  , substring(dt,9,2) as date
	  , sum(purchase_amount) as purchase_amount
	 from purchase_log
	 group by dt
)
select 
	*
from 
	daily_purchase
order by dt
;
```

<br>

| dt         | year_month | total | agg_amount |
| ---------- | ---------- | ----- | ---------- |
| 2014-01-01 | 2014-01    | 24516 | 24516      |
| 2014-01-02 | 2014-01    | 36049 | 60565      |
| 2014-01-03 | 2014-01    | 53029 | 113594     |
| 2014-01-04 | 2014-01    | 29299 | 142893     |
| 2014-01-05 | 2014-01    | 48256 | 191149     |
| 2014-01-06 | 2014-01    | 29440 | 220589     |
| 2014-01-07 | 2014-01    | 47679 | 268268     |
| 2014-01-08 | 2014-01    | 19760 | 288028     |
| 2014-01-09 | 2014-01    | 22944 | 310972     |
| 2014-01-10 | 2014-01    | 27923 | 338895     |

<br>

<br>

<br>

날짜를 연,월,일로 분할하고 날짜별로 합계 금액을 계산한 일시 테이블을 daily_purchase 라고 부릅시다.

다음 코드는 daily_purchase 테이블을 사용해 당월 매출 누계를 집계하는 쿼리입니다.

<br>

<br>

**코드 9 - 5**  daily_purchase 테이블에 대해 당월 누계 매출을 집계하는 쿼리

```sql
with
daily_purchase as (
   select
      dt
    , substring(dt,1,4) as year
    , substring(dt,6,2) as month
    , substring(dt,9,2) as date
    , sum(purchase_amount) as purchase_amount
 from purchase_log
 group by dt
)
select 
	dt
  , concat(year,'-',month) as year_month
  , purchase_amount
  , sum(purchase_amount)
  	 over(partition by year, month order by dt rows unbounded preceding)
  	as agg_amount
from daily_purchase
order by dt
;
```

<br>

| dt         | year_month | purchase_amount | agg_amount |
| ---------- | ---------- | --------------- | ---------- |
| 2014-01-01 | 2014-01    | 24516           | 24516      |
| 2014-01-02 | 2014-01    | 36049           | 60565      |
| 2014-01-03 | 2014-01    | 53029           | 113594     |
| 2014-01-04 | 2014-01    | 29299           | 142893     |
| 2014-01-05 | 2014-01    | 48256           | 191149     |
| 2014-01-06 | 2014-01    | 29440           | 220589     |
| 2014-01-07 | 2014-01    | 47679           | 268268     |
| 2014-01-08 | 2014-01    | 19760           | 288028     |
| 2014-01-09 | 2014-01    | 22944           | 310972     |
| 2014-01-10 | 2014-01    | 27923           | 338895     |

<br>

이전보다 많이 정돈되었습니다.

<br>

<br>

<br>

<br>

### [ 4 ] 월별 매출의 작대비 구하기

이번에는 월별매출 추이를 추출해서 작년의 해당 월의 매출과 비교해봅시다.<br>

2014년과 2015년의 월별 매출을  각각 계산하고, 월로 결합해서 작대비를 계산하는 방법도 있지만, 

이번 절에서는 Join을 사용하지 않고 작대비를 계산하는 방법으로 해보겠습니다.

<bR>

일단 대상 데이터는 2014년과 2015년 데이터를 포함해 집계하고, 월마다 GROUP BY를 적용해서 매출액을 계산합니다.

매출액을 계산할 때 SUM 함수 내부에 CASE 식을 사용해서 2014년과 2015년 로그를 각각 압축하면, 2014년과 2015년의<br>월별 매출을 각각 다른 컬럼으로 출력할 수 있습니다.

<br>

**코드 9 - 6**  월별 매출과 작대비를 계산하는 쿼리

```sql
with
daily_purchase as (
   select
      dt
    , substring(dt,1,4) as year
    , substring(dt,6,2) as month
    , substring(dt,9,2) as date
    , sum(purchase_amount) as purchase_amount
 from purchase_log
 group by dt
)
select
	month
	, sum(case year when '2014' then purchase_amount end) as amount_2014
	, sum(case year when '2015' then purchase_amount end) as amount_2015
	, trunc(100.0
	  * sum(case year when '2015' then purchase_amount end)
	  / sum(case year when '2014' then purchase_amount end),2)
	  as rate
from
	daily_purchase
group by month
order by month
;
```

<br>

| month | amount_2014 | amount_2015 | rate   |
| ----- | ----------- | ----------- | ------ |
| 01    | 13900       | 22111       | 159.07 |
| 02    | 28469       | 11965       | 42.02  |
| 03    | 18899       | 20215       | 106.96 |
| 04    | 12394       | 11792       | 95.14  |
| 05    | 2282        | 18087       | 792.59 |
| 06    | 10180       | 18859       | 185.25 |
| 07    | 4027        | 14919       | 370.47 |
| 08    | 6243        | 12906       | 206.72 |
| 09    | 3832        | 5696        | 148.64 |
| 10    | 6716        | 13398       | 199.49 |
| 11    | 16444       | 6213        | 37.78  |
| 12    | 29199       | 26024       | 89.12  |

<br>

<br>

<br>

<br>

<br>

### [ 5 ]  Z 차트로 업적의 추이 확인하기

p.150 부터







