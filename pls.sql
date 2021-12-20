-- t2 это таблица из первого задания. с комментариями см. test.sql
WITH t2 AS(WITH T1 AS(SELECT MIN(days_to_maturity) tdtm, MIN(days_to_call) mdtc, isin, issuer, g_spread_interpolated, date_trading
           FROM bond_quotes
           WHERE issuer LIKE '{issuer}'
           AND exch_me LIKE '{exch_me}'
           AND (to_date(left(date_trading,10), 'DD.MM.YYYY') >= to_date('{date_first_ddmmyyyy}', 'DD.MM.YYYY'))
           AND (to_date(left(date_trading,10), 'DD.MM.YYYY') <= to_date('{date_latter_ddmmyyyy}', 'DD.MM.YYYY'))
           GROUP BY isin, issuer, g_spread_interpolated, date_trading)
           
SELECT CASE WHEN tdtm <= mdtc AND mdtc IS NOT NULL 
        THEN tdtm
        WHEN mdtc IS NULL
        THEN tdtm 
        ELSE mdtc
        END AS duration,
        g_spread_interpolated,
        date_trading,
        isin,
        issuer
FROM T1),
-----------------------------------------------------------------------------              
        -- создаю таблицу со сроком, который прямо над нужной срочностью    
        t3 AS(SELECT duration min_above, -- минимальный срок над h
              -(('{h}')::int)*365+duration::int above_weigh, -- дюрация - количество лет, для определения веса
              issuer, -- эмитент
              g_spread_interpolated gsi, -- СОКРАЩЕННОЕ НАЗВАНИЕ
              
              -- наиболее важная часть, по сути еще одна таблица, в которой идет сортировка по 
              -- минимальные положительные (чтобы не было такого, что duration меньше, а показывает как больше),
              -- NULLIF — условие, чтобы были внизу все отрицательные
              -- row_number() нумирует строки (у меня получается по убыванию с положительной, можно будет взять 1 строку)
              row_number() over(ORDER BY NULLIF((('{h}')::int)*365-duration::int, ABS(-(('{h}')::int)*365+duration::int)), -(('{h}')::int)*365+duration::int) rn   
              
              FROM t2
              GROUP BY issuer, g_spread_interpolated, duration),
-----------------------------------------------------------------------------                      
        -- таблица со сроком, который прямо под нужной срочностью
        t4 AS(SELECT duration max_below, -- максимальный срок под h
              (('{h}')::int)*365-duration::int below_weigh, -- вес для средневзвешенного (weight пишется, в конце увидел)
              issuer, -- эмитент
              g_spread_interpolated gsi, -- доходность
              
              -- номера строк, по убывающей срочности, чтобы потом выбрать саму большую 
              row_number() over(ORDER BY duration DESC) rn  
              
              FROM t2
              WHERE duration < (('{h}')::int)*365 -- ограничивающее условие, чтобы было под
              GROUP BY issuer, g_spread_interpolated, duration),
-----------------------------------------------------------------------------              
        t5 AS(SELECT g_spread_interpolated gsi, -- насколько понял, нужно максимальное значение из всего, эта таблица для этого
              issuer, -- эмитент
              
              -- номера строк где сначала идут положительные числа спреда доходности по убыванию, потом отрицательные
              row_number() over(ORDER BY NULLIF(-g_spread_interpolated, ABS(g_spread_interpolated)), g_spread_interpolated DESC) rn
              
              FROM t2
              WHERE duration < (('{h}')::int)*365 -- ограничивающее условие
              GROUP BY issuer, g_spread_interpolated)
-----------------------------------------------------------------------------
-- составление финальной таблицы со средневзвешенным спредом
SELECT CASE WHEN t3.min_above >= (('{h}')::int)*365 AND t4.max_below < (('{h}')::int)*365 AND above_weigh > 0 AND below_weigh > 0 -- условия для расчета по первой формуле
        THEN (t3.gsi*t4.below_weigh+t4.gsi*t3.above_weigh)/(t3.min_above-t4.max_below)
        WHEN t4.max_below < (('{h}')::int)*365 AND (t3.min_above IS NULL OR t3.min_above < (('{h}')::int)*365 OR t3.above_weigh<0) -- условия для максимального значения
        THEN t5.gsi
        ELSE t3.gsi
        END AS spread_int
FROM t3 
JOIN t4 ON t3.issuer=t4.issuer -- ключи не важны, так как row_number() возьмет необходимые данные
JOIN t5 ON t5.issuer = t3.issuer
WHERE t3.rn = 1 AND t4.rn = 1 AND t5.rn=1

             