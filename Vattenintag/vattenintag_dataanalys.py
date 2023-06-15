##====================================================##
##     Project: VATTENINTAG
##        File: vattenintag_dataanalys.py
##      Author: GOTTFRID OLSSON 
##     Created: 2023-05-17
##     Updated: 2023-06-10
##       About: Plots water intake as function of time
##              during the day. 
##====================================================##



# LIBRARIES #
import numpy as np
import pandas as pd
import statistics as stat
import matplotlib
import matplotlib.dates as mdates
import matplotlib.pyplot as plt
from datetime import datetime



# READ CSV #
CSV_filename = 'VATTENINTAG [2023-06-14] - DATA.csv'
CSV = pd.read_csv(CSV_filename, delimiter=',')
header = CSV.columns
print(CSV_filename, CSV)


# FUNCTIONS #
def get_minutes_from_hhmm_bruteforce(hours_minutes):
    # time format: 'hh:mm'
    hours, minutes = hours_minutes[0:2], hours_minutes[3:5]
    hours, minutes = int(hours), int(minutes)
    minutes_from_midnight = hours*60 + minutes
    return minutes_from_midnight


def convert_date_and_time_to_datetime(date, time):
    """ Date format: 'yyyy-mm-dd'

        Time format: 'hh:mm:ss' (or 'hh:mm')

           Requires:    'import datetime from datetime'
    """
    return datetime.fromisoformat(date+'T'+time)


def standard_setup_matplotlib(LaTeX=True, figsize_cm=(16, 9), font_size_axis=13, font_size_tick=11, font_size_legend=9):
    figsize_inch = (figsize_cm[0]/2.54, figsize_cm[1]/2.54)
    matplotlib.rcParams.update({
        "text.usetex": LaTeX,
        "font.family": "serif", 
        "font.serif" : ["Computer Modern Roman"],
        "figure.figsize": figsize_inch
    })
    matplotlib.rc('font',   size=font_size_axis)      
    matplotlib.rc('axes',   titlesize=font_size_axis) 
    matplotlib.rc('axes',   labelsize=font_size_axis)
    matplotlib.rc('xtick',  labelsize=font_size_tick)
    matplotlib.rc('ytick',  labelsize=font_size_tick)
    matplotlib.rc('legend', fontsize=font_size_legend)



# SETUP MATPLOTLIB #
standard_setup_matplotlib(figsize_cm=(16, 12))



# Arrays and variables
date  = CSV[header[0]] # time  = CSV[header[1]], # water_intake = CSV[header[2]]
date_unique = list([set(date)][0]) # picks the unique dates and puts them into a list
date_unique.sort()                 # orders the strings 
water_intake_per_day = []

fig, ax = plt.subplots()
day_cheat, day_after_cheat = date_unique[0], date_unique[1] # to plot with same hh:mm for a certain day we need to cheat to say that the day is the same for all dates
x_lims = [convert_date_and_time_to_datetime(day_cheat, '05:30'), convert_date_and_time_to_datetime(day_after_cheat, '00:30')]
y_lims = [0, 6]

for i, day in enumerate(date_unique):

    # Pick out data for the day
    time_of_day = CSV.loc[CSV[header[0]] == day, header[1]]
    datetimes_of_day = [convert_date_and_time_to_datetime(day_cheat, time) for time in time_of_day]
    water_intake = CSV.loc[CSV[header[0]] == day, header[2]]
    water_cumsum = np.cumsum(water_intake/10) # convert from dl to L, make shape same as for datetimes_of_day to plot
    water_intake_per_day.append(np.max(water_cumsum)) 

    # Check for update on lims  
    if np.min(water_cumsum) < y_lims[0]: y_lims[0] = np.min(water_cumsum)
    if np.max(water_cumsum) > y_lims[1]: y_lims[1] = np.max(water_cumsum)

    # Plot
    ax.plot(datetimes_of_day, water_cumsum, 's-', label=day)


# Calculate 
num_unique_days = len(date_unique)
total_water_intake = np.sum(water_intake_per_day)
average_total_water_intake = total_water_intake / num_unique_days
stdev_total_water_intake   = stat.stdev(water_intake_per_day)
#print(average_total_water_intake, stdev_total_water_intake)
y_lims = [y_lims[0]-0.5, y_lims[1]+0.5]
num_unique_days = len(date_unique)
final_date = date[len(date)-1]
average_total_water_intake = total_water_intake / num_unique_days


# Plot settings
ax.set_xlabel('Tid på dygnet')
ax.set_ylabel('Kumulativt vattenintag (L)')
ax.set_xlim(x_lims[0], x_lims[1])
ax.set_ylim(y_lims[0], y_lims[1])
ax.xaxis.set_major_locator(mdates.HourLocator(interval=2)) #get tick every 30 minutes: MinuteLocator(interval=30) #this works! 2023-05-27
ax.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M')) #to get 'hh:mm'

plt.grid()
plt.legend()
handles, labels = ax.get_legend_handles_labels()
ax.legend([handles[0]], [f'Olika dagar från {date_unique[0]} till {date_unique[-1]}'], loc = 'best')
plt.title(f'Medelvärde totalt vattenintag per dag: {average_total_water_intake:.2f} L (baserat på {num_unique_days} dagar)')
plt.tight_layout()
plt.savefig(f'Vattenintag [{final_date}].pdf')
plt.show()


# TODO:
# med plt.text elr ngt, plotta Q1-Q4 i boxplot med textrutor vid sidan av själva boxen!

quartiles = np.percentile(water_intake_per_day, [0, 25, 50, 75, 100], method='normal_unbiased')
quartile_explanation_Text = ['Min', 'Splits the data into 25 percent below and 75 percent above this value', 'Median', 'Splits the data into 75 percent below and 25 percent above this value', 'Max']
for i, Q in enumerate(quartiles):
    print(f"Quartile {i}: {Q:.1f} L/dag ({quartile_explanation_Text[i]})")
#sprint(quartiles)

# BOXPLOT #
plt.boxplot(water_intake_per_day, labels=["Gottfrid"])#, notch=False, meanline=True, manage_ticks=True)
plt.ylim(2.5, 6.5)
plt.xlabel('')
plt.ylabel('Totalt vattenintag per dag (L)')

# TODO: fixa exakt plot y-pos för texterna

for i in range(len(quartiles)):
    x_coord_text = 1.125
    y_coord_text = quartiles[i] - 0.05
    text = f'Q{i} = {quartiles[i]:.1f}'
    plt.text(x_coord_text, y_coord_text, text)
plt.grid()
plt.savefig(f'Vattenintag - Boxplot [{final_date}].pdf')
plt.show()


# OLD, SAVED IF I EVER LOOK FOR IT
#handles, labels = ax.get_legend_handles_labels()
#display_labels = [num_unique_days]
#ax.legend([handle for i,handle in enumerate(handles) if i in display_labels],
#          [label for i,label in enumerate(labels) if i in display_labels], loc = 'best')