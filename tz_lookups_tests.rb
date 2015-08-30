require 'rack/test'
require 'test/unit'

OUTER_APP = Rack::Builder.parse_file('config.ru').first

# test data taken from pytzwhere (https://github.com/pegler/pytzwhere/blob/master/tests/test_locations.py)
Location = Struct.new(:lat, :lng, :name, :time_zone_id)
TEST_LOCATIONS = [
  Location.new(35.295953, -89.662186, 'Arlington, TN', 'America/Chicago'),
  Location.new(33.58, -85.85, 'Memphis, TN', 'America/Chicago'),
  Location.new(61.17, -150.02, 'Anchorage, AK', 'America/Anchorage'),
  Location.new(44.12, -123.22, 'Eugene, OR', 'America/Los_Angeles'),
  Location.new(42.652647, -73.756371, 'Albany, NY', 'America/New_York'),
  Location.new(55.743749, 37.6207923, 'Moscow', 'Europe/Moscow'),
  Location.new(34.104255, -118.4055591, 'Los Angeles', 'America/Los_Angeles'),
  Location.new(55.743749, 37.6207923, 'Moscow', 'Europe/Moscow'),
  Location.new(39.194991, -106.8294024, 'Aspen, Colorado', 'America/Denver'),
  Location.new(50.438114, 30.5179595, 'Kiev', 'Europe/Kiev'),
  Location.new(12.936873, 77.6909136, 'Jogupalya', 'Asia/Kolkata'),
  Location.new(38.889144, -77.0398235, 'Washington DC', 'America/New_York'),
  Location.new(59.932490, 30.3164291, 'St Petersburg', 'Europe/Moscow'),
  Location.new(50.300624, 127.559166, 'Blagoveshchensk', 'Asia/Yakutsk'),
  Location.new(42.439370, -71.0700416, 'Boston', 'America/New_York'),
  Location.new(41.84937, -87.6611995, 'Chicago', 'America/Chicago'),
  Location.new(28.626873, -81.7584514, 'Orlando', 'America/New_York'),
  Location.new(47.610615, -122.3324847, 'Seattle', 'America/Los_Angeles'),
  Location.new(51.499990, -0.1353549, 'London', 'Europe/London'),
  Location.new(51.256241, -0.8186531, 'Church Crookham', 'Europe/London'),
  Location.new(51.292215, -0.8002638, 'Fleet', 'Europe/London'),
  Location.new(48.868743, 2.3237586, 'Paris', 'Europe/Paris'),
  Location.new(22.158114, 113.5504603, 'Macau', 'Asia/Macau'),
  Location.new(56.833123, 60.6097054, 'Russia', 'Asia/Yekaterinburg'),
  Location.new(60.887496, 26.6375756, 'Salo', 'Europe/Helsinki'),
  Location.new(52.799992, -1.8524408, 'Staffordshire', 'Europe/London'),
  Location.new(5.016666, 115.0666667, 'Muara', 'Asia/Brunei'),
  Location.new(-41.466666, -72.95, 'Puerto Montt seaport', 'America/Santiago'),
  Location.new(34.566666, 33.0333333, 'Akrotiri seaport', 'Asia/Nicosia'),
  Location.new(37.466666, 126.6166667, 'Inchon seaport', 'Asia/Seoul'),
  Location.new(42.8, 132.8833333, 'Nakhodka seaport', 'Asia/Vladivostok'),
  Location.new(50.26, -5.051, 'Truro', 'Europe/London'),
]

class TestApp < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  def test_heartbeat
    get '/status'
    assert last_response.ok?
    assert_equal 'OK', last_response.body
  end

  def test_missing_api_key
    get '/time_zone?lat=%s&lng=%s' % [48.8567, 2.348692]
    assert last_response.unauthorized?
  end

  def test_missing_lat_lng
    get '/time_zone?api_key=%s' % ['THE_API_KEY']
    assert last_response.bad_request?

    get '/time_zone?lat=%s&api_key=%s' % [48.8567, 'THE_API_KEY']
    assert last_response.bad_request?

    get '/time_zone?lng=%s&api_key=%s' % [2.348692, 'THE_API_KEY']
    assert last_response.bad_request?
  end

  def test_from_email
    get '/time_zone?lat=%s&lng=%s&api_key=%s' % [48.8567, 2.348692, 'THE_API_KEY']
    assert_equal 200, last_response.status

    # ?!? email said 'America/New_York', database  (and internet) say Europe/Paris?
    # http://www.latlong.net/c/?lat=48.8567&long=2.348692
    assert_equal 'Europe/Paris', extract_tz_from_body(last_response.body)
  end

  def test_pytzwhere_data
    TEST_LOCATIONS.each do |location|
      get '/time_zone?lat=%s&lng=%s&api_key=%s' % [location.lat, location.lng, 'THE_API_KEY']

      assert_equal 200, last_response.status
      assert_equal location.time_zone_id, extract_tz_from_body(last_response.body)
    end
  end

  def extract_tz_from_body(body)
    JSON.parse(body.to_s)['time_zone_id']
  end
end
