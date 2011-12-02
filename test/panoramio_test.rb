require 'test/test_helper'
require 'uri'
require 'ruby-debug'

class PanoramioTest < Test::Unit::TestCase
  should "generate Panoramio API URLs" do
    url = Panoramio.url(:order => :popularity, 
                        :set  => :public, 
                        :from => 0, 
                        :to   => 10, 
                        :minx => 60, 
                        :maxx => 70, 
                        :miny => 10, 
                        :maxy => 20, 
                        :size => :medium)
    url.should =~ %r{^http://www.panoramio.com.*}
    puts url
    URI.parse(url).to_s.should == url
  end

  should "generate Panoramio API URLs with default parameters" do
    url = Panoramio.url(:minx => 60, 
                        :maxx => 70, 
                        :miny => 10, 
                        :maxy => 20)
    expected = "http://www.panoramio.com/map/get_panoramas.php?maxy=20&to=20&order=popularity&minx=60&from=0&size=thumbnail&maxx=70&set=public&miny=10"
    url.should =~ %r{^http://www.panoramio.com.*}
    URI.parse(url).to_s.should == url
  end

  context "support Panoramio REST API" do
    should "handle empty results" do
      photos = Panoramio.photos(:minx => 60, 
                                :maxx => 70, 
                                :miny => 10, 
                                :maxy => 20)

      photos.should == nil
    end

    should "handle partial results" do
      photos = Panoramio.photos(:minx => -60, 
                                :maxx => 70, 
                                :miny => 10, 
                                :maxy => 20)

      photos.size.should == 20
      photos.first.photo_title.should_not == nil
      photos.first.latitude.should_not == nil
      photos.first.longitude.should_not == nil
    end

    should "handle full results" do
      photos = Panoramio.all_photos(:minx => -10, 
                                    :maxx => 70, 
                                    :miny => 10, 
                                    :maxy => 20)

      photos.size.should == 478
      photos.first.photo_title.should_not == nil
      photos.first.latitude.should_not == nil
      photos.first.longitude.should_not == nil
    end
  end
end
