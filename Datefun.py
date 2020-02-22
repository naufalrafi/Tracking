import numpy as np
import datetime as dt


def doy(YR, MO, D):
    # The function DOY calculates the day of the year for the specified date. The calculation uses the rules for the
    # Gregorian calendar and is valid from the inception of that calendar system.
    month_days_comm = np.array([31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31])  # No. of days in months of common year
    day_number = 0  # Place holder value for the day number of the year
    for i in range(0, MO-1):
        day_number = day_number + month_days_comm[i]

    day_number = day_number + D

    if np.mod(YR, 4) == 0 & MO > 2:
        day_number = day_number + 1

    return day_number


def frcofd(HR, MI, SE):
    # The function frcofd calculates the fraction of a day at the specified input time.
    day_fraction = (HR + MI/60 + SE/3600)/24  # Fraction of the day

    return day_fraction

def rafiDateTimeFunc(days_J2000, hours_midnight):
    year = int(days_J2000/365.35) # Calculate the year

    # Remove past years
    num_days_year = 0
    for i in range(0, year):
        if i == 0 or np.mod(i,4) == 0:
            num_days_year = num_days_year + 366
        else:
            num_days_year = num_days_year + 365

    day_in_year = days_J2000 - num_days_year + 1 # Day of the year
    TLE_format = year*1000 + day_in_year + hours_midnight/24 # Set to TLE format 
    print(TLE_format)
    print(ep2dat(TLE_format))


def ep2dat(tle_timedate):
    # The function ep2dat converts an Epoch (date format in TLE) to text string CDATE - UTC standard calendar date and
    # time in format: YYYY-MM-DD HH:MM:SS
    dig_year = np.int(tle_timedate/1000)  # Last two digits of the year
    wou_year = tle_timedate - dig_year*1000 # Portion of TLE with only month, day, and time
    month_days_comm = np.array([31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31])  # No. of days in months of common year

    # Compute the current year
    if dig_year > 50:
        year = 1900 + dig_year
    else:
        year = 2000 + dig_year

    # Compute the current month
    count = 0
    teste = wou_year
    while teste > 0:
        teste = teste - month_days_comm[count]
        count = count + 1
    month = count - 1

    # Compute the current day
    day_temp = wou_year
    for i in range(0 , month):
        day_temp = day_temp - month_days_comm[i]
    day = np.int(day_temp)

    # Compute the current time
    day_frac = day_temp - day  # Fraction of the day
    day_secs = day_frac*86400  # Number of seconds of the day

    hrs = np.int(day_secs/3600)  # Hours of the day
    mns = np.int((day_secs - hrs*3600)/60) # Minutes of the day
    sec = (day_secs - hrs*3600 - mns*60) # Seconds of the day

    # Assemble the date-time string
    date_string = str(year) + '-'

    # The following if-statements add a zero in front of a number if the value is less than 10. This is done such that
    # the double digit format is respected.
    month = month + 1
    if month < 10:
        date_string = date_string + '0' + str(month) + '-'
    else:
        date_string = date_string + str(month) + '-'

    if day < 10:
        date_string = date_string + '0' + str(day) + ' '
    else:
        date_string = date_string + str(day) + ' '

    if hrs < 10:
        date_string = date_string + '0' + str(hrs) + ':'
    else:
        date_string = date_string + str(hrs) + ':'

    if mns < 10:
        date_string = date_string + '0' + str(mns) + ':'
    else:
        date_string = date_string + str(mns) + ':'

    if sec < 10:
        date_string = date_string + '0' + str(sec)
    else:
        date_string = date_string + str(sec)

    return date_string

def curday():
    current_date_time = dt.datetime.now()
    date_string = str(current_date_time)

    return date_string


rafiDateTimeFunc(7024, 12+6.127236111)
rafiDateTimeFunc(3347, 12+6.018069444)
