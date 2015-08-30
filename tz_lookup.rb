require 'json'
require 'roda'
require 'sequel'

DATABASE = Sequel.postgres(
  :host => 'localhost',
  :user => 'tzlookup',
  :password => 'swordfish2',
  :database => 'tzlookup',
  :max_connections => 16
)
QUERY = 'SELECT tzid FROM tz_world WHERE ST_Intersects(ST_SetSRID(ST_MakePoint(?, ?), 4326), geom);'

class TzLookup < Roda
  plugin :halt
  plugin :heartbeat, :path => '/status'
  plugin :indifferent_params
  plugin :json

  def find_timezone_id(lat, lng)
    # n.b. postgis uses (lng, lat), not (lat, lng)!
    first_row = DATABASE[QUERY, lng.to_f, lat.to_f].first
    first_row.nil? ? nil : first_row[:tzid]
  end

  route do |r|
    r.on 'time_zone' do
      lat = params[:lat]
      lng = params[:lng]
      api_key = params[:api_key]

      if lat.nil? || lng.nil? || api_key.nil?
        r.halt(400, {:error => 'missing lat|lng|api_key query parameter!'})
      end

      tzid = find_timezone_id(lat.to_f, lng.to_f)
      r.halt(404, {:error => 'no time_zone_id found!'}) if tzid.nil?
      {:time_zone_id => tzid}
    end
  end
end
