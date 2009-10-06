require 'test_helper'
require 'uri'

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
    expected = "http://www.panoramio.com/map/get_panoramas.php?order=popularity&maxx=70&miny=10&set=public&maxy=20&from=0&size=thumbnail&to=20&minx=60" 
    url.should == expected
    URI.parse(url).to_s.should == expected
  end

  should "generate Panoramio API URLs with default parameters" do
    url = Panoramio.url(:minx => 60, 
                        :maxx => 70, 
                        :miny => 10, 
                        :maxy => 20)
    expected = "http://www.panoramio.com/map/get_panoramas.php?order=popularity&maxx=70&miny=10&set=public&maxy=20&from=0&size=thumbnail&to=20&minx=60" 
    url.should == expected
    URI.parse(url).to_s.should == expected
  end

  context "support Panoramio REST API" do
    should "GET /get_panoramas.php" do
      photos = Panoramio.photos(:minx => 60, 
                                :maxx => 70, 
                                :miny => 10, 
                                :maxy => 20)

      photos.size.should == 20
      photos.first.photo_title.should_not == nil
      photos.first.latitude.should_not == nil
      photos.first.longitude.should_not == nil
    end
  end
end
