-- 의원 리텐션
SELECT period
,first_value(cohort_retained) over (order by period) as cohort_size
,cohort_retained
,cohort_retained * 1.0 / first_value(cohort_retained) over (order by period) as pct_retained
FROM
(
    SELECT coalesce(date_part('year',age(c.date,a.first_term)),0) as period
    ,count(distinct a.id_bioguide) as cohort_retained
    FROM
    (
        SELECT id_bioguide, min(term_start) as first_term
        FROM legislators_terms
        GROUP BY 1
    ) a
    JOIN legislators_terms b on a.id_bioguide = b.id_bioguide
    LEFT JOIN date_dim c on c.date between b.term_start and b.term_end
    GROUP BY 1
) aa
;

-- 첫 임기 시작 세기별 의원 리텐션
SELECT first_century
,period
,first_value(cohort_retained) over (partition by first_century order by period) as cohort_size
,cohort_retained
,cohort_retained * 1.0 / 
 first_value(cohort_retained) over (partition by first_century order by period) as pct_retained
FROM
(
    SELECT date_part('century',a.first_term) as first_century
    ,coalesce(date_part('year',age(c.date,a.first_term)),0) as period
    ,count(distinct a.id_bioguide) as cohort_retained
     FROM
    (
            SELECT id_bioguide, min(term_start) as first_term
            FROM legislators_terms 
            GROUP BY 1
    ) a
    JOIN legislators_terms b on a.id_bioguide = b.id_bioguide 
    LEFT JOIN date_dim c on c.date between b.term_start and b.term_end 
    GROUP BY 1,2
) aa
ORDER BY 1,2
;

-- 첫 임기 수행 주별 의원 리텐션(전체  의원 수 기준 상위 5개 주)
SELECT first_state
,period
,first_value(cohort_retained) over (partition by first_state order by period) as cohort_size
,cohort_retained
,cohort_retained * 1.0 / first_value(cohort_retained) over (partition by first_state order by period) as pct_retained
FROM
(
        SELECT a.first_state
        ,coalesce(date_part('year',age(c.date,a.first_term)),0) as period
        ,count(distinct a.id_bioguide) as cohort_retained
        FROM
        (
                SELECT distinct id_bioguide
                ,min(term_start) over (partition by id_bioguide) as first_term
                ,first_value(state) over (partition by id_bioguide order by term_start) as first_state
                FROM legislators_terms 
        ) a
        JOIN legislators_terms b on a.id_bioguide = b.id_bioguide 
        LEFT JOIN date_dim c on c.date between b.term_start and b.term_end 
        GROUP BY 1,2
) aa
ORDER BY 1,2
;

-- 성별에 따른 의원 리텐션
SELECT gender
,period
,first_value(cohort_retained) over (partition by gender order by period) as cohort_size
,cohort_retained
,cohort_retained * 1.0 / first_value(cohort_retained) over (partition by gender order by period) as pct_retained
FROM
(
    SELECT d.gender
    ,coalesce(date_part('year',age(c.date,a.first_term)),0) as period
    ,count(distinct a.id_bioguide) as cohort_retained
     FROM
    (
        SELECT id_bioguide, min(term_start) as first_term
         FROM legislators_terms 
         GROUP BY 1
    ) a
    JOIN legislators_terms b on a.id_bioguide = b.id_bioguide 
    LEFT JOIN date_dim c on c.date between b.term_start and b.term_end 
    JOIN legislators d on a.id_bioguide = d.id_bioguide
    GROUP BY 1,2
) aa
ORDER BY 2,1
;

-- 성별에 따른 리텐션(1917~1999년의 코호트)
SELECT gender
,period
,first_value(cohort_retained) over (partition by gender order by period) as cohort_size
,cohort_retained
,cohort_retained * 1.0 / first_value(cohort_retained) over (partition by gender order by period) as pct_retained
FROM
(
    SELECT d.gender
    ,coalesce(date_part('year',age(c.date,a.first_term)),0) as period
     ,count(distinct a.id_bioguide) as cohort_retained
     FROM
    (
        SELECT id_bioguide, min(term_start) as first_term
        FROM legislators_terms 
        GROUP BY 1
    ) a
    JOIN legislators_terms b on a.id_bioguide = b.id_bioguide 
    LEFT JOIN date_dim c on c.date between b.term_start and b.term_end 
    JOIN legislators d on a.id_bioguide = d.id_bioguide
    WHERE a.first_term between '1917-01-01' and '1999-12-31'
    GROUP BY 1,2
) aa
ORDER BY 2,1
;
