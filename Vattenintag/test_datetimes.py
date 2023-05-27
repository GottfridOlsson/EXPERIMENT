import matplotlib.pyplot as plt
import datetime
import matplotlib.dates as mdates
import numpy as np
from datetime import datetime
test_date = datetime.fromisoformat('2019-12-04'+'T'+'21:39')
print(test_date)

datetimes = np.array([
    datetime.datetime(2021, 2, 24, 14, 30), datetime.datetime(2021, 2, 24, 16, 30),
    datetime.datetime(2021, 2, 24, 18, 50), datetime.datetime(2021, 2, 24, 21, 30),
    datetime.datetime(2021, 2, 25, 14, 30), datetime.datetime(2021, 2, 25, 16, 30),
    datetime.datetime(2021, 2, 25, 18, 50), datetime.datetime(2021, 2, 25, 21, 30)
])
runs = np.array([0, 81, 117, 211, 211, 257, 349, 387])
print(datetimes)

print(np.shape(datetimes), np.shape(runs))
ax = plt.axes()
ax.plot(datetimes, runs)
ax.set_title('Eng vs Ind, 3rd Test, Ahmedabad')
ax.set_ylabel('Runs Scored')
ax.set_xlabel('Time of Day')
# Re-format the x-axis
ax.set_xticks(datetimes)
ax.set_xticklabels(datetimes, rotation=30, ha='right')
fmt = mdates.DateFormatter('%H:%M')
ax.xaxis.set_major_formatter(fmt)
plt.subplots_adjust(bottom=0.15)

plt.show()