# example plot matplotlib with datetime module
# wtih xticks as 'hh:mm'

import matplotlib.pyplot as plt
import datetime
import matplotlib.dates as mdates
import numpy as np



from datetime import datetime

date = '2023-05-26'
times = ['10:10', '11:11', '12:30', '12:58', '13:30', '14:00', '16:00']

datetimes = np.array([datetime.fromisoformat(date + 'T'+ time) for time in times])
print(datetimes)

x_data = datetimes
y_data = np.array([0, 1, 2, 3, 4, 5, 6])

ax = plt.axes()

print(np.shape(x_data), np.shape(y_data))
ax.plot(x_data, y_data)
ax.set_ylabel('y-axis')
ax.set_xlabel('Time of Day (hh:mm)')

# Re-format the x-axis
ax.xaxis.set_major_formatter(mdates.DateFormatter('%H:%M'))

plt.show()