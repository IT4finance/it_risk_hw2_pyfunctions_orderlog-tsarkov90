#импортирование библиотек

import pandas as pd
import numpy as np
import datetime as dt
import psycopg2
from dateutil.relativedelta import relativedelta

############################
#это первое задание, чтобы получить спреды на момент времени (на 1 день)
# — нужно указать одинаковые date1  и date2 для момента
# в целом это просто отображение запроса sql с нужными переменными
def spread_momentum(c, issuer, exch_me, date1, date2):
    conn_sm = open('test.sql', 'r', encoding = 'UTF-8') #был файл, на котором тестирую, стал основным :)
    read_sm = (conn_sm.read()).format(issuer = issuer, exch_me = exch_me, date_first_ddmmyyyy = date1, date_latter_ddmmyyyy = date2)
    sm = pd.read_sql_query(read_sm, c, index_col='duration')
    return(sm)

############################
#это второе задание — посчитать спред определенной срочности
#h считается в годах, меньше одного нельзя (это срочность спреда)
#в целом это просто отображение запроса sql с нужными переменными
def s_int(c, issuer, exch_me, date1, date2, h):
    conn_s = open('pls.sql', 'r', encoding = 'UTF-8') 
    read_s = (conn_s.read()).format(issuer = issuer, exch_me = exch_me, date_first_ddmmyyyy = date1, date_latter_ddmmyyyy = date2, h = h)
    s = pd.read_sql_query(read_s, c, index_col='spread_int')
    return(s)

############################
#ТРЕТЬЕ ЗАДАНИЕ ВЫПОЛНЕНО ТОЛЬКО В ЗДЕСЬ ПРИ ПОМОЩИ
#ФУНКЦИИ s_int И while
#НОВАЯ ПЕРЕМЕННАЯ f ЧАСТОТА (В МЕСЯЦАХ)
#СУТЬ — СОЗДАЕМ НОВУЮ СТРОКУ ИЗ s_int и даты каждый парсинг (прибавляю частоту к дате и получаю новую дату — новую строку)
def parsed_sp(c, issuer, exch_me, date1, date2, h, f):
    parsed = [] #пустой список, для дальнейшего пополнения и создания датафрейма
    b = [] #пустой список, для дальнейшего пополнения и создания датафрейма
    a = dt.datetime.strptime(date1, '%d.%m.%Y') #первая (то есть самая ранняя дата) в виде переменной, чтобы не сломать while
    #прибавляем к меньшей дате, пока она не станет больше или равна
    while a <= dt.datetime.strptime(date2, '%d.%m.%Y'): 
        #пополняем список спредами
        parsed.append(s_int(c, issuer, exch_me, a.strftime('%d.%m.%Y'), date2, h).index.values) 
        #пополняем список датами
        b.append(a.strftime('%d.%m.%Y')) 
        #каждое пополнение меняем дату на месячный интервал (тут как 30*на количество месяцев)
        a += dt.timedelta(days=30*f)
        #cоздаем словарь для датафрейма
    d = {'spread':parsed, 'date':b}
    #создаем датафрейм
    df = pd.DataFrame(d)
    #индекс для соответствия условию
    df1 = df.set_index('date')
    return(df1)