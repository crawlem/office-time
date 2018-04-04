require 'csv'
require 'time'
require 'date'
require 'erb'
require 'business_time'

# Work out the right filename for our website
def get_filename(year, month)
	folder = year == nil ? '.' : './_c' + year.to_s
	filename = month == nil ? 'index' : month.to_s
	extension = 'md'
	return folder + "/" + filename + "." + extension
end

def get_title(year, month)
	title = month == nil ? year : Date::ABBR_MONTHNAMES[month] + " " + year.to_s
	return title
end

def busiest_day(weekdays)
	return weekdays.index(weekdays.max)
end

def get_start(earliest, year=nil, month=nil)
	startdate = earliest
	if year == nil
		# startdate = Date.parse("2017-05-15")
		# enddate = Date.new
	elsif month == nil
		if year > earliest.year
			startdate = Time.new(year, 1, 1, 0, 0, 0)
		end
	else
		if Date.new(year, month, 1) > earliest
			startdate = Time.new(year, month, 1, 0, 0, 0)
		end
	end
	return startdate
end

def get_end(latest, year=nil, month=nil)
	enddate = latest
	if year == nil
		# startdate = Date.parse("2017-05-15")
		# enddate = Date.new
	elsif month == nil
		if year < latest.year
			enddate = Time.new(year, 12, 31, 23, 59, 59)	
		end
	else
		temp = Date.new(year, month, -1)
		if temp < latest
			enddate = Time.new(year, month, temp.day, 23, 59, 59)
		end
	end
	return enddate
end

def business_days(start_date, end_date)
	s = Date.parse(start_date.to_s)
	e = Date.parse(end_date.to_s)
	days = s.business_days_until(e) + 1
	return days
end

def business_hours(start_date, end_date)
	hours = start_date.business_time_until(end_date)
	val = (hours / 60 / 60).round
	return val
end

# Generate the file
def output_file(days, hours, weekdays, business_days, business_hours, year=nil, month=nil)
	if days > 0
		filename = get_filename(year, month)
		title = get_title(year, month)
		day = Date::DAYNAMES[busiest_day(weekdays)+1]

		content = ERB.new("---\nlayout: default\ntitle: <%= title %>\nyear: <%= year %>\nmonth: <%= month %>\ndaysInOffice: <%= days %>\npossibleDays: <%= business_days %>\nhoursInOffice: <%= hours %>\npossibleHours: <%= business_hours %>\nbusiestDay: <%= day %>\nhoursMon: <%= weekdays[0] %>\nhoursTue: <%= weekdays[1]%>\nhoursWed: <%= weekdays[2]%>\nhoursThu: <%= weekdays[3]%>\nhoursFri: <%= weekdays[4]%>\nlongestDay: 11 hours\naverageDay: 7 hours\n---\n").result(binding)

		File.write(filename, content)
	end
end

# Public holidays
BusinessTime::Config.holidays << Date.parse("29 May 2017")
BusinessTime::Config.holidays << Date.parse("28 Aug 2017")
BusinessTime::Config.holidays << Date.parse("25 Dec 2017")
BusinessTime::Config.holidays << Date.parse("26 Dec 2017")

BusinessTime::Config.holidays << Date.parse("1 Jan 2018")
BusinessTime::Config.holidays << Date.parse("30 Mar 2018")
BusinessTime::Config.holidays << Date.parse("2 Apr 2018")
BusinessTime::Config.holidays << Date.parse("7 May 2018")
BusinessTime::Config.holidays << Date.parse("28 May 2018")
BusinessTime::Config.holidays << Date.parse("27 Aug 2018")
BusinessTime::Config.holidays << Date.parse("25 Dec 2018")
BusinessTime::Config.holidays << Date.parse("26 Dec 2018")

BusinessTime::Config.holidays << Date.parse("1 Jan 2019")

# Vacation
BusinessTime::Config.holidays << Date.parse("31 Jul 2017")
BusinessTime::Config.holidays << Date.parse("1 Aug 2017")
BusinessTime::Config.holidays << Date.parse("2 Aug 2017")
BusinessTime::Config.holidays << Date.parse("3 Aug 2017")
BusinessTime::Config.holidays << Date.parse("4 Aug 2017")
BusinessTime::Config.holidays << Date.parse("7 Aug 2017")
BusinessTime::Config.holidays << Date.parse("8 Aug 2017")
BusinessTime::Config.holidays << Date.parse("9 Aug 2017")
BusinessTime::Config.holidays << Date.parse("10 Aug 2017")
BusinessTime::Config.holidays << Date.parse("11 Aug 2017")
BusinessTime::Config.holidays << Date.parse("18 Oct 2017")
BusinessTime::Config.holidays << Date.parse("6 Nov 2017")
BusinessTime::Config.holidays << Date.parse("23 Nov 2017")
BusinessTime::Config.holidays << Date.parse("24 Nov 2017")
BusinessTime::Config.holidays << Date.parse("22 Dec 2017")
BusinessTime::Config.holidays << Date.parse("27 Dec 2017")
BusinessTime::Config.holidays << Date.parse("28 Dec 2017")
BusinessTime::Config.holidays << Date.parse("29 Dec 2017")

BusinessTime::Config.holidays << Date.parse("2 Jan 2018")
BusinessTime::Config.holidays << Date.parse("3 Jan 2018")
BusinessTime::Config.holidays << Date.parse("4 Jan 2018")
BusinessTime::Config.holidays << Date.parse("5 Jan 2018")
BusinessTime::Config.holidays << Date.parse("23 Feb 2018")
BusinessTime::Config.holidays << Date.parse("6 Apr 2018")
BusinessTime::Config.holidays << Date.parse("11 Apr 2018")

days = 0
duration = 0

years = Hash.new

arrived = ''
left = ''

earliest = Time.new
latest = Time.new

# Parse the CSV file
CSV.foreach('/Users/crawleym/Downloads/locations.csv') do |row|
	date = Time.strptime(row[0], "%B %d, %Y at %H:%M%p")
	flag = row[1].partition(" ").first
	
	unless years.key?(date.year)
		if left != ''
			years[left.year]['duration'] = (duration / 60).round
		else
			earliest = date
		end
		years[date.year] = Hash.new
		years[date.year]['duration'] = 0
		years[date.year]['weekdays'] = [0, 0, 0, 0, 0]
		years[date.year]['days'] = 0

		years[date.year]['months'] = Hash.new
		years[date.year]['months'][1] = Hash.new
		years[date.year]['months'][2] = Hash.new
		years[date.year]['months'][3] = Hash.new
		years[date.year]['months'][4] = Hash.new
		years[date.year]['months'][5] = Hash.new
		years[date.year]['months'][6] = Hash.new
		years[date.year]['months'][7] = Hash.new
		years[date.year]['months'][8] = Hash.new
		years[date.year]['months'][9] = Hash.new
		years[date.year]['months'][10] = Hash.new
		years[date.year]['months'][11] = Hash.new
		years[date.year]['months'][12] = Hash.new

		years[date.year]['months'][1]['days'] = 0
		years[date.year]['months'][2]['days'] = 0
		years[date.year]['months'][3]['days'] = 0
		years[date.year]['months'][4]['days'] = 0
		years[date.year]['months'][5]['days'] = 0
		years[date.year]['months'][6]['days'] = 0
		years[date.year]['months'][7]['days'] = 0
		years[date.year]['months'][8]['days'] = 0
		years[date.year]['months'][9]['days'] = 0
		years[date.year]['months'][10]['days'] = 0
		years[date.year]['months'][11]['days'] = 0
		years[date.year]['months'][12]['days'] = 0

		years[date.year]['months'][1]['weekdays'] = [0,0,0,0,0]
		years[date.year]['months'][2]['weekdays'] = [0,0,0,0,0]
		years[date.year]['months'][3]['weekdays'] = [0,0,0,0,0]
		years[date.year]['months'][4]['weekdays'] = [0,0,0,0,0]
		years[date.year]['months'][5]['weekdays'] = [0,0,0,0,0]
		years[date.year]['months'][6]['weekdays'] = [0,0,0,0,0]
		years[date.year]['months'][7]['weekdays'] = [0,0,0,0,0]
		years[date.year]['months'][8]['weekdays'] = [0,0,0,0,0]
		years[date.year]['months'][9]['weekdays'] = [0,0,0,0,0]
		years[date.year]['months'][10]['weekdays'] = [0,0,0,0,0]
		years[date.year]['months'][11]['weekdays'] = [0,0,0,0,0]
		years[date.year]['months'][12]['weekdays'] = [0,0,0,0,0]

		years[date.year]['months'][1]['duration'] = 0
		years[date.year]['months'][2]['duration'] = 0
		years[date.year]['months'][3]['duration'] = 0
		years[date.year]['months'][4]['duration'] = 0
		years[date.year]['months'][5]['duration'] = 0
		years[date.year]['months'][6]['duration'] = 0
		years[date.year]['months'][7]['duration'] = 0
		years[date.year]['months'][8]['duration'] = 0
		years[date.year]['months'][9]['duration'] = 0
		years[date.year]['months'][10]['duration'] = 0
		years[date.year]['months'][11]['duration'] = 0
		years[date.year]['months'][12]['duration'] = 0

		duration = 0
	end

	if flag == 'Arrived' 
		arrived = date
		if left == '' or date.to_date - left.to_date > 0
			years[date.year]['days'] += 1
			years[date.year]['months'][date.month]['days'] += 1
		end
	end
	if flag == 'Left'
		left = date
		mins = (left - arrived) / 60
		years[left.year]['weekdays'][left.wday-1] += (mins / 60).round
		years[left.year]['months'][left.month]['weekdays'][left.wday-1] += (mins / 60).round
		years[left.year]['months'][left.month]['duration'] += (mins / 60).round
		duration += mins
	end
end

latest = Time.new(left.year, left.month, left.day, left.hour, left.min, left.sec)
years[left.year]['duration'] = (duration / 60).round
puts years

# Write each year to a file and sum overall as we go
days = 0
duration = 0
weekdays = [0, 0, 0, 0, 0]
years.each do |key,value|
	start_date = get_start(earliest, key)
	end_date = get_end(latest, key)
	puts key.to_s + " start " + start_date.to_s + " (" + start_date.zone + ") end " + end_date.to_s + " (" + end_date.zone + ")"
	output_file(value['days'], value['duration'], value['weekdays'], business_days(start_date, end_date
		), business_hours(start_date, end_date), key)

	# Write each month of this year
	value['months'].each do |x,y|
		start_date = get_start(earliest, key, x)
		end_date = get_end(latest, key, x)
		if y['days'] > 0
			puts Date::ABBR_MONTHNAMES[x] + " start " + start_date.to_s + " (" + start_date.zone + ") end " + end_date.to_s + " (" + end_date.zone + ")"
		end
		output_file(y['days'], y['duration'], y['weekdays'], business_days(start_date, end_date), business_hours(start_date, end_date), key, x)
	end

	# Totals for the main index page (all years)
	days += value['days']
	duration += value['duration']
	weekdays[0] += value['weekdays'][0]
	weekdays[1] += value['weekdays'][1]
	weekdays[2] += value['weekdays'][2]
	weekdays[3] += value['weekdays'][3]
	weekdays[4] += value['weekdays'][4]
end

# Write the main index page (all years)
start_date = get_start(earliest)
end_date = get_end(latest)
output_file(days, duration, weekdays, business_days(start_date, end_date), business_hours(start_date, end_date))