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
#
#   Panoramio.photos_adv(
#       :miny => 49.492059,
#       :maxy => 49.64658,
#       :minx => 19.998493,
#       :maxx => 20.373058,
#       :part_size => 0.1,
#       :set => :full
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

    # Get all photos from Panoramio within area
    #
    # :call-seq:
    #   Panoramio.all_photos( Hash options ) = > Array of photos
    def all_photos(options = {})
      output = []
      i = 0
      loop do
        opts = options.clone.merge({ :from => i, :to => i + 100 })
        new_photos = photos(opts)
        return output if new_photos.nil? || !new_photos.size
        output += new_photos
        i += 100
      end
    end

    # TODO document
    #
    # Get even more photos from Panoramio. Divide area using :part_size in options.
    #
    # :call-seq:
    #   Panoramio.photos_adv( Hash options ) = > Hash with photos and calculated data
    def photos_adv(options = {})
      # not enough data
      return nil unless options[:minx] || options[:maxx] || options[:miny] || options[:maxy]
      return photos(options) unless options[:part_size]

      # start creating parts
      x_length = options[:maxx] - options[:minx]
      y_length = options[:maxy] - options[:miny]

      # new partials count
      x_partial_count = (x_length / options[:part_size]).ceil
      y_partial_count = (y_length / options[:part_size]).ceil

      x_precised_part_size = x_length / x_partial_count.to_f
      y_precised_part_size = y_length / y_partial_count.to_f

      output = []
      (0...(x_partial_count)).each do |x|
        (0...(y_partial_count)).each do |y|
          h = options.clone.merge({
            :minx => options[:minx] + x * x_precised_part_size,
            :maxx => options[:minx] + (1 + x) * x_precised_part_size,
            :miny => options[:miny] + y * y_precised_part_size,
            :maxy => options[:miny] + (1 + y) * y_precised_part_size,
          })
          output += photos_all(h)
        end
      end

      output.uniq!({
        :array => output,
        :array_size => output.size,
        :x_parts => x_partial_count,
        :x_precised_part_size => x_precised_part_size,
        :y_parts => y_partial_count,
        :y_precised_part_size => y_precised_part_size
      })
    end

    protected
      def to_params(options)
        { :order => :popularity,
          :set => :public,
          :size => :thumbnail,
          :from => 0,
          :to => 20 }.merge(options)
      end

      def to_uri(options)
        to_params(options).map { |key, val| "#{key}=#{val}" }.join("&")
      end

      def to_photos(json)
        return nil if json['photos'].first.nil?
        # issues with redefinition
        struct = defined?(Struct::Photo) ? Struct::Photo : Struct.new('Photo', *json['photos'].first.keys)
        json['photos'].map { |p| struct.new(*p.values) }
      end
  end

  remote_defaults :on_success => lambda { |response| JSON.parse(response.body) },
                  :on_failure => lambda { |response| raise "Panoramio.com error: #{response.code}. Response #{response.body}" },
                  :cache_responses => 180
  define_remote_method :get_photos, :base_uri => URL
end
