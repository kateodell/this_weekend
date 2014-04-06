require 'faraday'

class EventFinder
  def self.get_events_for_zip(zip)
    location = get_location(zip)
    events = get_events_for_this_weekend(location)
    add_weather_info(events)
    events
  end

  private

  def self.get_location(zip)
    response = Faraday.get "https://maps.googleapis.com/maps/api/geocode/json?address=#{zip}&sensor=false"
    json_response = JSON.parse(response.body)
    json_response['results'][0]['geometry']['location']
  end

  def self.get_events_for_this_weekend(location)
    response = Faraday.get "http://ws.audioscrobbler.com/2.0/?method=geo.getevents&lat=#{location['lat']}&long=#{location['lng']}&api_key=04631c3f45f0c39aa13c86571820d2f5&format=json&limit=100"
    events = JSON.parse(response.body)['events']['event']
    events_this_weekend = events.select { |event|  is_this_weekend(event['startDate'])  }
  end

  def self.is_this_weekend(date_string)
    date = Date.parse(date_string)
    monday = Date.today.beginning_of_week
    this_weekend = [monday+4.days, monday+5.days, monday+6.days]
    this_weekend.include?(date)
  end

  def self.add_weather_info(events)
    all_zips =
    events.each do |event|
      lat = event['venue']['location']['geo:point']['geo:lat']
      lng = event['venue']['location']['geo:point']['geo:long']
      response = Faraday.get "http://api.openweathermap.org/data/2.5/forecast/daily?lat=#{lat}&lon=#{lng}&cnt=7&mode=json&units=imperial"
      weather_for_week = JSON.parse(response.body)['list']
        days_until_event = (Date.parse(event['startDate']) - Date.today).to_i
      weather_for_day = weather_for_week[days_until_event]
      event['weather'] = weather_for_day['temp'].merge(weather_for_day['weather'].first)
    end
  end
end
