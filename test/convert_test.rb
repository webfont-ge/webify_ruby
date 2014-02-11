require 'test_helper'

class WebifyRubyTest < ActiveSupport::TestCase
  test "Converts and moves" do
    ttf_convert_path = PATH+'/public/ttf_convert'
    otf_convert_path = PATH+'/public/otf_convert'
    
    convert_ttf = WebifyRuby::Convert.new(
      PATH+'/public/ttf/bpg_dedaena_nonblock.ttf',
      dir: ttf_convert_path
    )
    
    convert_otf = WebifyRuby::Convert.new(
      PATH+'/public/otf/bpg_dedaena.otf',
      dir: otf_convert_path
    )
    
    count_ttf = Dir[convert_ttf.result_dir + '/*.{ttf,eot,woff,svg}'].length    
    count_otf = Dir[convert_otf.result_dir + '/*.{otf,otf,woff}'].length    
    
    assert_equal(4, count_ttf)
    assert_equal(3, count_otf)
  end
end
