from datetime import datetime, timedelta

my_gps = 1271067822.00200

# utc = 1980-01-06UTC + (gps - (leap_count(2020) - leap_count(1980)))
utc = datetime(1980, 1, 6) + timedelta(seconds=my_gps - (38 - 19))