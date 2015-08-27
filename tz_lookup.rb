require 'json'
require 'roda'
require 'sequel'

DB = Sequel.postgres(
    :host => 'localhost',
    :user => 'tzlookup',
    :password => 'swordfish2',
    :database =>'tzlookup',
    :max_connections => 16
)
QUERY = "SELECT tzid FROM tz_world WHERE ST_Intersects(ST_GeomFromText('POINT(? ?)', 4326), geom);"

class TzLookup < Roda
    plugin :halt
    plugin :heartbeat, :path=>'/status'
    plugin :json
    plugin :param_matchers

    def findTimeZoneId(lat,lng)
        first_row = DB[QUERY, lat.to_f, lng.to_f].first
        first_row.nil? ? nil : first_row[:tzid]
    end

    route do |r|
        r.on "time_zone" do
            r.on param: 'lat' do |lat|
                r.on param: 'lng' do |lng|
                    r.on param: 'api_key' do |api_key|
                        tzid = findTimeZoneId(lat.to_f, lng.to_f)
                        r.halt(404, {'error' => 'no time_zone_id found!'}) if tzid.nil?
                        { :time_zone_id => tzid }
                    end
                end
            end
            r.halt(400, {'error' => 'missing lat|lng|api_key query parameter!'})
        end
    end
end
