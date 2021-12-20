Skip to content
Search or jump to…
Pull requests
Issues
Marketplace
Explore
 
@demak0v 
IT4finance
/
it_risk_hw1_sql_bonds-demak0v
Private
Code
Issues
Pull requests
1
Actions
Projects
Security
Insights
Settings
it_risk_hw1_sql_bonds-demak0v/HW_1.1.sql
@demak0v
demak0v Загрузил дз.
…
Latest commit 22a9eea 14 days ago
 History
 1 contributor
49 lines (42 sloc)  1.38 KB
   
-- Задание 1
-- Данные загружены, переменные даны, папка public.
-- я делал в колабе и не знаю, как должен выглядеть sql не в питоне, надеюсь, ошибок немного.

DROP TABLE IF EXISTS public.bond_quotes;
CREATE TABLE public.bond_quotes
( currency char(4) NOT NULL,
  date_trading varchar(30) NOT NULL,
  exch_me varchar(100) NOT NULL,
  bid_price real,
  ask_price real,
  opening_price real,
  indicative_price real,
  indicative_price_type varchar(20),
  turnover real,
  number_of_trades smallint, 
  coupon real, 
  ytm_ind real,
  coupon_accum real,
  option_date varchar(30),
  duration_option real,
  trade_regime varchar(500),
  ISIN varchar(20),
  g_spread varchar(30),
  state_bank bool,
  issuer varchar(50),
  days_to_maturity integer NOT NULL,
  total_days_to_maturity integer NOT NULL,
  days_to_call integer,
  callable BOOL NOT NULL,
  g_spread_interpolated real,
  rf_interpolated real
)
WITH (
    OIDS=FALSE
)
TABLESPACE pg_default;

ALTER TABLE public.bond_quotes
        OWNER to postgres;

-- На всякий случай изменить формат даты для Маков

ALTER DATABASE postgres SET datestyle TO "ISO, DMY";         

-- Загрузить данные

copy public.bond_quotes FROM '/content/bond_quotes.csv'  DELIMITER ';' CSV HEADER ENCODING 'WIN1251';
	
© 2021 GitHub, Inc.
Terms
Privacy
Security
Status
Docs
Contact GitHub
Pricing
API
Training
Blog
About
Loading complete