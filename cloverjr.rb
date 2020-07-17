#!/usr/bin/ruby
$LOAD_PATH.push(File.dirname(__FILE__) + '/lib')

require 'changelog_model'
require 'pp'


#cl_filename = File.dirname(__FILE__) + '/' + ARGV[0]
cl_filename = Dir.pwd + '/' + ARGV[0]
changelog = ChangelogModel.new(cl_filename)
changelog.to_html()
