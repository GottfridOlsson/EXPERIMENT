# created: 2023-05-17

# LIBRARIES #
import numpy as np
import pandas as pd
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import FuncFormatter, MultipleLocator

def get_minutes_from_hhmm_bruteforce(hours_minutes):
    # time format: 'hh:mm'
    hours, minutes = hours_minutes[0:2], hours_minutes[3:5]
    hours, minutes = int(hours), int(minutes)
    minutes_from_midnight = hours*60 + minutes
    return minutes_from_midnight

matplotlib.rcParams.update({
    "text.usetex": True,
    "font.family": "serif", 
    "font.serif" : ["Computer Modern Roman"]
})
matplotlib.rc('font',   size=11)      #2022-06-21: not sure what the difference is, to test later on!
matplotlib.rc('axes',   titlesize=13) #2022-06-21: not sure what the difference is, to test later on!
matplotlib.rc('axes',   labelsize=13) #2022-06-21: not sure what the difference is, to test later on!
matplotlib.rc('xtick',  labelsize=11)
matplotlib.rc('ytick',  labelsize=11)
matplotlib.rc('legend', fontsize=9)


# READ CSV #
CSV = pd.read_csv('vattenintag_data.csv', delimiter=',')
header = CSV.columns

# Arrays 
date  = CSV[header[0]]
time  = CSV[header[1]]
water_intake = CSV[header[2]]

date_unique = list([set(date)][0]) # picks the unique dates and puts them into a list

total_water_intake, total_slope_fit, total_intercept_fit = 0, 0, 0
fig, ax = plt.subplots(figsize=(16/2.54, 12/2.54))
for i, day in enumerate(date_unique):
    time_of_day = CSV.loc[CSV[header[0]] == day, header[1]]
    minutes = [get_minutes_from_hhmm_bruteforce(time) for time in time_of_day]
    hours = [minute/60 for minute in minutes]
    water_intake = CSV.loc[CSV[header[0]] == day, header[2]]
    water_cumsum = np.cumsum(water_intake/10)

    # Fit line
    coeffs = np.polyfit(hours, water_cumsum, 1)
    total_slope_fit += coeffs[0]
    total_intercept_fit += coeffs[1]
    total_water_intake += np.max(water_cumsum)

    ax.plot(hours, water_cumsum, 's-', label=day)
    #ax.plot(hours, water_cumsum, 'k-', linewidth=1, label=day)

x_lims = [5.5, 22.5]
y_lims = [-0.5, 6.5]
num_unique_days = len(date_unique)
average_total_water_intake = total_water_intake / num_unique_days
average_slope_fit = total_slope_fit/num_unique_days
average_intercept_fit = total_intercept_fit/num_unique_days
x_fit = np.linspace(x_lims[0]+0.5, x_lims[1]-0.5)
y_fit = average_slope_fit*x_fit + average_intercept_fit
ax.plot(x_fit, y_fit, 'k--', label=f'Medelvärde linjär anpassning\n$$y(h)={average_slope_fit:.2f}h{average_intercept_fit:.2f}$$')

ax.set_xlabel('Tid på dagen (h)')
ax.set_ylabel('Kumulativt vattenintag (L)')
ax.set_xlim(x_lims[0], x_lims[1])
ax.set_ylim(y_lims[0], y_lims[1])
plt.grid()
plt.legend()
plt.tight_layout()
final_date = date[len(date)-1]
plt.savefig(f'Vattenintag [{final_date}].pdf')
plt.show()


num_unique_days = len(date_unique)
average_total_water_intake = total_water_intake / num_unique_days
print('\n')
print(f'Average total water intake:    {average_total_water_intake:.2f} L     (based on {num_unique_days} days)')
print(f'Average water intake per hour: {average_slope_fit:.2f} L/h   (based on {num_unique_days} days)')