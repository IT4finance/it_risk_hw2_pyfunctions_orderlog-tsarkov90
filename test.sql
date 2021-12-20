-- SQL ЗАПРОС ДЛЯ ВЫПОЛНЕНИЯ ПЕРВОГО ЗАДАНИЯ --
-- РАБОТАЕТ ТОЛЬКО С ЗАДАННЫМИ ПЕРЕМЕННЫМИ (СМ. ТЕТРАДКУ ИЛИ ПОМЕНЯТЬ ТУТ)

-- БЕРУ МИНИМАЛЬНЫЕ ДНИ ДО ИСПОЛНЕНИЯ И ОТЗЫВА, ЧТОБЫ НАЙТИ СРОК ДО ПОГАШЕНИЯ (У МЕНЯ НАЗЫВАЕТСЯ duration)
WITH T1 AS(SELECT MIN(days_to_maturity) tdtm, MIN(days_to_call) mdtc, isin, issuer, g_spread_interpolated, date_trading
           FROM bond_quotes
           WHERE issuer LIKE '{issuer}' -- эмитент, LIKE для удобства
           AND exch_me LIKE '{exch_me}' -- источник информации, LIKE для удобства
           -- условия по дате сделаны для интервала
           -- чтобы получить момент поставьте одинаковые даты
           AND (to_date(left(date_trading,10), 'DD.MM.YYYY') >= to_date('{date_first_ddmmyyyy}', 'DD.MM.YYYY'))
           AND (to_date(left(date_trading,10), 'DD.MM.YYYY') <= to_date('{date_latter_ddmmyyyy}', 'DD.MM.YYYY'))
           GROUP BY isin, issuer, g_spread_interpolated, date_trading)
           
SELECT CASE WHEN tdtm <= mdtc AND mdtc IS NOT NULL -- условие для минимального из двух (to maturity и to call) 
        THEN tdtm
        WHEN mdtc IS NULL
        THEN tdtm 
        ELSE mdtc
        END AS duration,
        g_spread_interpolated
FROM T1
