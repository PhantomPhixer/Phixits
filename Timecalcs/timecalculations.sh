#!/bin/bash

# testing out time calculation
deferAllow3=7


curentDateTime=$(date +%Y:%d:%m::%H:%M)
#curentDateTime=$(date -v-300d +%Y:%d:%m::%H:%M)

currentTimeClean=$(echo $curentDateTime | sed 's/://g')
echo "*** $currentTimeClean"


dateReadable=$(date -j -f "%Y%d%m%H%M" $currentTimeClean +"%d %m")
timeReadable=$(date -j -f "%Y%d%m%H%M" $currentTimeClean +"%H %S")
#monthNumber=$(date -j -f "%Y%d%m%H%M" $currentTimeClean +"%m")
#monthNumber=$(date +"%m")

#dayNumber=$(date -j -f "%Y%d%m%H%M" $currentTimeClean +"%u")
dayNumber=$(date +"%u")
echo "day number is $dayNumber"
#echo "** date readable is $dateReadable"
#echo "** time readable is $timeReadable"


# list of months. ZERO is first value as array numbering starts with zero
month_list=(ZERO Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
day_list=(ZERO Mon Tue Wed Thur Fri Sat Sun)

# convert month number into month word
#month=$(echo ${month_list[$monthNumber]})
#echo "Month is $month"
#day=$(echo ${day_list[$dayNumber]})
#echo "**** Day now  is $day ****"





echo "now it is $curentDateTime"

currentDay=$(date +%Y:%d:%m)
echo "today is $currentDay"

echo "***********************"
deferBackstop=$(date -v+"$deferAllow3"d +%Y:%d:%m::%H:%M)
echo "three days is $deferBackstop"

backstopDateClean=$(echo $deferBackstop | sed 's/://g')
echo "** Day clean is $backstopDateClean"
dayNumber=$(date -j -f "%Y%d%m%H%M" $backstopDateClean +"%d")
dayInteger=$(date -j -f "%Y%d%m%H%M" $backstopDateClean +"%u")
monthNumber=$(date -j -f "%Y%d%m%H%M" $backstopDateClean +"%m")
echo "*************"
echo "day is $dayNumber"
echo "day ineteger is $dayInteger"
echo "Month is $monthNumber"
day=$(echo ${day_list[$dayInteger]})
echo "Day name is $day"
month=$(echo ${month_list[$monthNumber]})
echo "Month is $month"

echo "date in $deferAllow3 days is $day $dayNumber $month"
echo "*************************"





exit 0

threedaysinseconds=$(date -v+"$deferAllow3"d +%s)
echo "three days in seconds is $threedaysinseconds"
threeDaysInNum=$(date -v+"$deferAllow3"d "+%u")
threeDaysInWords=$(echo ${day_list[$threeDaysInNum]})
echo "**** Day now  is $day ****"
echo "**** Day 3 is $threeDaysInWords *****"

todayinsecs=$(date +%s)
#todayinsecs=$(date -v+4d +%s)
echo "now in secs : $todayinsecs"


exit 0

deferal1hr=$(date -v+1H +%Y:%d:%m::%H:%M)
echo "+1hr is $deferal1hr"

deferal3hr=$(date -v+3H +%Y:%d:%m::%H:%M)
echo "+3 hr is $deferal3hr"

deferal1day=$(date -v+1d +%Y:%d:%m::%H:%M)
echo "+1 day is $deferal1day"

deferal20mins=$(date -v+20M +%Y:%d:%m::%H:%M)
echo "+20 min is $deferal20mins"

if [ "$todayinsecs" -gt "$threedaysinseconds" ]; then
	echo "tempus fugit"
else
	echo "still time"
fi

