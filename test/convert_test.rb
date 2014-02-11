require 'test_helper'
require 'fileutils'

WebifyRuby::webify_binary = 'bin/webify-travis'
exec 'chmod a+x '+WebifyRuby::webify_binary

class WebifyRubyTest < ActiveSupport::TestCase
  ttf_convert_path = PATH+'/public/ttf_convert'
  otf_convert_path = PATH+'/public/otf_convert'
  
  test "Converts and moves" do
    
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
  
  test "Checking for CSS Writing" do
    class WebifyRuby::Convert
      public :should_write_css?
    end
    
    convert_without_css = WebifyRuby::Convert.new(
    PATH+'/public/ttf/bpg_dedaena_nonblock.ttf',
    dir: ttf_convert_path
    )
    
    convert_with_css_create = WebifyRuby::Convert.new(
    PATH+'/public/ttf/bpg_dedaena_nonblock.ttf',
    dir: ttf_convert_path,
    css: PATH+'/public/stylesheets/'
    )
    
    assert_equal(false, convert_without_css.should_write_css?)
    assert_equal(true, convert_with_css_create.should_write_css?)
  end
  
  test "Destination directories" do
    class WebifyRuby::Convert
      public :destination_dir
    end
    
    convert_same_dir = WebifyRuby::Convert.new(
    PATH+'/public/ttf/bpg_dedaena_nonblock.ttf'
    )
    
    new_dir = PATH+'/public/destionation_directories_test'
    
    FileUtils::rmdir(new_dir)
    
    creates_new_dir = WebifyRuby::Convert.new(
    PATH+'/public/ttf/bpg_dedaena_nonblock.ttf',
    dir: new_dir
    )
    
    assert_equal(convert_same_dir.original_dir, convert_same_dir.destination_dir)
    assert_equal(true, File.directory?(new_dir))
  end
end
