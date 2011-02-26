require 'typhoeus'
require 'json'
#require 'ruby-debug'

# Utility for getting photos from Panoramio
# http://www.panoramio.com/api/data/api.html
#
# = Options Hash describtion:
#
# :set:
# - :public - popular
# - :full - all
#
# :size:
# - :original
# - :medium (default value)
# - :small
# - :thumbnail
# - :square
# - :mini_square
#
# :minx, :miny, :maxx, :maxy - minimum longitude, latitude, maximum longitude and latitude, respectively
#
# :from, :to - number of photos to be returned
#
# Example:
#   Panoramio.photos(
#        :minx => -180,
#        :maxx => 180,
#        :miny => -90,
#        :maxy => 90#,
#   )


class Panoramio
  include Typhoeus

  URL = 'http://www.panoramio.com/map/get_panoramas.php'

  class << self
    def url(options = {})
      "#{URL}?#{to_uri(options)}"
    end

    # Get photos from Panoramio
    #
    # :call-seq:
    #   Panoramio.photos( Hash options ) = > Array of photos
    def photos(options = {})
      to_photos(get_photos(:params => to_params(options)))
    end

    protected
    def to_params(options)
      {:order => :popularity,
       :set => :public,
       :size => :thumbnail,
       :from => 0,
       :to => 20}.merge(options)
    end

    def to_uri(options)
      to_params(options).map { |key, val| "#{key}=#{val}" }.join("&")
    end

    def to_photos(json)
      # fix for 'no photos''
      if json['photos'].first.nil?
        return Array.new
      end

      struct = Struct.new('Photo', *json['photos'].first.keys)
      json['photos'].map { |p| struct.new(*p.values) }
    end
  end

  remote_defaults :on_success => lambda { |response| JSON.parse(response.body) },
                  :on_failure => lambda { |response| raise "Panoramio.com error: #{response.code}. Response #{response.body}" },
                  :cache_responses => 180
  define_remote_method :get_photos, :base_uri => URL

end
