require 'rspec/autorun'

require 'rubygems' rescue nil
require 'bundler/setup'

REAL_PATH = File.dirname(File.dirname(File.expand_path(__FILE__)))
MEDIA_PATH = File.join(File.expand_path(REAL_PATH), 'media')

$LOAD_PATH.unshift REAL_PATH
$LOAD_PATH.unshift MEDIA_PATH
$LOAD_PATH.unshift File.join(REAL_PATH, 'lib')

require 'chingu'
include Gosu
include Chingu

Image.autoload_dirs.unshift File.join(MEDIA_PATH, 'images')
Sample.autoload_dirs.unshift File.join(MEDIA_PATH, 'sounds')
Song.autoload_dirs.unshift File.join(MEDIA_PATH, 'songs')
Font.autoload_dirs.unshift File.join(MEDIA_PATH, 'fonts')
    
$stderr.sync = $stdout.sync = true
require 'matrix'
