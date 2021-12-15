import pandas as pd
import time


def get_dom_from_raw(raw_frame):
    """
    Функция, преобразующая срез по заявкам до какого-то времени в биржевой стакан.

    :param raw_frame: `DataFrame`, имеющий столбцы `buysell` (тип заявки B/S), `order_no` (номер заявки), `price` (цена заявки), `remaining_volume` (неисполненный объём заявки)

    :returns: `DataFrame` вида (buy - price - sell), представляющий собой биржевой стакан

    """

    buy = raw_frame[(raw_frame['buysell'] == 'B') & (raw_frame['remaining_volume'] > 0.0)]
    sell = raw_frame[(raw_frame['buysell'] == 'S') & (raw_frame['remaining_volume'] > 0.0)]
    buy = (buy[['price', 'remaining_volume']].groupby(by='price').sum()).rename(columns={'remaining_volume': 'buy'})
    sell = (sell[['price', 'remaining_volume']].groupby(by='price').sum()).rename(columns={'remaining_volume': 'sell'})

    dom = (pd.merge(buy, sell, how='outer', on='price')).sort_values(by='price', ascending=False).fillna(0)

    bid = buy.index.max()
    ask = sell.index.min()
    return dom, bid, ask