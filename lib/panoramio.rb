require 'typhoeus'
require 'json'
#require 'ruby-debug'

#
# http://www.panoramio.com/api/
#
class Panoramio
  include Typhoeus

  URL = 'http://www.panoramio.com/map/get_panoramas.php'

  class << self
    def url(options = {})
      "#{URL}?#{to_uri(options)}"
    end

    def photos(options = {})
      to_photos(get_photos(:params => to_params(options)))
    end

    protected
      def to_params(options)
        options.merge!({ :order => :popularity,
                         :set   => :public,
                         :size  => :thumbnail,
                         :from  => 0,
                         :to    => 20 })
      end

      def to_uri(options)
        to_params(options).map {|key, val| "#{key}=#{val}" }.join("&")
      end

      def to_photos(json)
        struct = Struct.new('Photo', *json['photos'].first.keys)
        json['photos'].map {|p| struct.new(*p.values) }
      end
  end

  remote_defaults :on_success => lambda {|response| JSON.parse(response.body)},
                  :on_failure => lambda {|response| raise "Panoramio.com error: #{response.code}. Response #{response.body}"},
                  :cache_responses => 180
  define_remote_method :get_photos, :base_uri => URL
  
end
