# LIBRARIES #
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from datetime import datetime


def get_minutes_from_hhmm_bruteforce(hours_minutes):
    # time format: 'hh:mm'
    hours, minutes = hours_minutes[0:2], hours_minutes[3:5]
    hours, minutes = int(hours), int(minutes)
    minutes_from_midnight = hours*60 + minutes
    return minutes_from_midnight



# READ CSV #
CSV = pd.read_csv('vattenintag_data.csv', delimiter=',')
header = CSV.columns

# Arrays 
date  = CSV[header[0]]
time  = CSV[header[1]]
water_intake = CSV[header[2]]

date_unique = list([set(date)][0]) # picks the unique dates and puts them into a list


fig, ax = plt.subplots()
for i, day in enumerate(date_unique):
    time_of_day = CSV.loc[CSV[header[0]] == day, header[1]]
    minutes = [get_minutes_from_hhmm_bruteforce(time) for time in time_of_day]
    water_intake = CSV.loc[CSV[header[0]] == day, header[2]]
    water_cumsum = np.cumsum(water_intake)


    ax.plot(minutes, water_cumsum, 'o-', label=day)

plt.legend()
plt.show()

