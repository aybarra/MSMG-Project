import pandas as pd
import numpy as np
import csv



def get_data(filename):
    df = pd.DataFrame()

    df_temp = pd.read_csv(filename)
    # for symbol in symbols:
    #     df_temp = pd.read_csv(symbol_to_path(symbol), index_col='Date',
    #             parse_dates=True, usecols=['Date', 'Adj Close'], na_values=['nan'])
    #     df_temp = df_temp.rename(columns={'Adj Close': symbol})
    #     df = df.join(df_temp)
    #     if symbol == 'SPY':  # drop dates SPY did not trade
    #         df = df.dropna(subset=["SPY"])

    return df

if __name__ == "__main__":
	df = get_data('msmg_project experiment-spreadsheet2.csv')
	print df