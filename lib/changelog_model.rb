# -*- coding: utf-8 -*-
Encoding.default_external = 'utf-8'
require "rubygems"
require "bundler/setup"
require 'kramdown'
require 'kramdown-parser-gfm'
require 'base64'
require 'pp'
require 'erb'
require 'time'
require 'json'


class ChangelogModel
  include ERB::Util
  def initialize(chglog)
    @base_dir = File.expand_path('..', File.dirname(__FILE__)) + '/'
    @contents_dir = File.dirname(chglog) + '/'
    @config = {}
    @config[:images_dir] = @contents_dir + 'images/'
    @config[:input_file] = File.basename(chglog, File.extname(chglog))
    parse_cl(chglog)
    map_tags_contents
    convert_contents
    @contents.sort_by! { |c| c[:id]}
    @contents.reverse!
    @erb = ERB.new(File.read(@base_dir + 'lib/template.erb', :encoding => 'utf-8'), nil, '-')
  end
  def to_html()
    File.open(@config[:input_file] + ".html", 'w', :encoding => 'utf-8') do |f|
      f.puts @erb.result(binding)
    end
  end
  private
  def convert_contents()
    @contents.each do |content|
      content[:contents].gsub!(/(?<!\\)%img:([^%:]*)(?::?([^%]*))%/){img_to_base64("#{@config[:images_dir]}#{$1}",$2)}
      content[:contents].gsub!(/\\%/,"%")
      content[:contents] = Kramdown::Document.new(content[:contents], input: 'GFM').to_html
    end
  end
  def img_to_base64(file_name, width)
    width = 40 if(width == "")
    file_type=file_name[/\.(.*)/,1]
    src_filename = file_name
    img_base64 = Base64.strict_encode64(File.binread(src_filename))
    return '<img src="data:image/' + file_type + ';base64,' + img_base64 + '" width="' + width.to_s + '%" />'
  end
  def parse_cl(fileName)
    buf = File.readlines(fileName, :encoding => 'utf-8')
    @contents ||= []
    oneday_string = []
    contents_date = Time.now()
    author = "hoge"
    buf.each do |line|
      line = line[/^\t?([^\r\n]*)/,1]
      if((all,date_line, author_line = /^(\d{4}-\d{2}-\d{2}) *([^ ]+)?/.match(line).to_a)[0] != nil)
        if(!oneday_string.empty?)
          one_day = parse_oneday_string(oneday_string,fileName,contents_date,author) unless(oneday_string.empty?)
          @contents.concat(one_day)
        end
        contents_date = Time.parse(date_line[/^\d{4}-\d{2}-\d{2}/,0])
        author = author_line
        oneday_string = []
      else
        oneday_string << line
      end
    end
    one_day = parse_oneday_string(oneday_string,fileName,contents_date,author) unless(oneday_string.empty?)
    @contents.concat(one_day)
  end
  def get_contents_id_in_a_tag(tag)
    contents = @contents
    contents.map {|c| c[:id] if(c[:tags].is_a?(Array) && c[:tags].include?(tag))}.compact
  end
  def parse_oneday_string(oneday_string,fileName,contents_date,author)
    return_value = []
    one_content = []
    oneday_string.each do |line|
      if(line =~/^\*.+:/ )
        return_value.concat(parse_header(one_content)) if(!one_content.empty?)
        one_content = []
        one_content << line
      else
        one_content << line
      end
    end
    return_value.concat(parse_header(one_content)) 
    return_value.compact!
    num_content = return_value.length
    return_value.each do |c| 
      c[:date] = contents_date 
      c[:author] = author
      c[:id] = c[:date].strftime("%Y-%0m-%0d") + '-' + num_content.to_s
      num_content = num_content - 1
    end
    return_value
  end
  def parse_header(one_content)
    return_value = []
    return_value_tmp = {}
    header = one_content.shift
    return [] if(/^\*p/.match(header))
    _,return_value_tmp[:title],tags,contents = /\*[ ]*([^\[]*?)[ ]*(\[.*\])?:(.*)/.match(header).to_a
    return [] if(return_value_tmp[:title].nil?)
    return_value_tmp[:title] =return_value_tmp[:title].split('%').join("\n")
    return_value_tmp.merge!(parse_tags(tags))
    return_value_tmp.merge!({:contents => contents + "\n" + one_content.join("\n")})
    return_value.push(return_value_tmp.dup)
    return_value
  end
  def parse_tags(tag_string)
    tags = tag_string.split(/[\[\]]/).select{|v| v!=""}
    return_value = {}
    tags.each do |v|
      tmp = v.split(/%/)
      (1..tmp.length-1).each {|i| (tmp[1].is_a?(Array))? tmp[1] << tmp[i] : tmp[1] = [tmp[i]] } if(tmp[0] == 'keywords' || tmp[0] == 'tags') 
      if(return_value.has_key?(:"#{tmp[0]}"))
        return_value[:"#{tmp[0]}"].push(tmp[1])
      else
        return_value[:"#{tmp[0]}"] = tmp[1]
        if(tmp[0] == 'tags')
          @config[:tags] = (@config[:tags].is_a?(Array))? @config[:tags] | tmp[1] : tmp[1]
        end
      end
    end
    return_value
  end
  def map_tags_contents
    @config[:tag_map] = {}
    @config[:tags].each do |t|
      @config[:tag_map][t] = get_contents_id_in_a_tag(t)
    end
    @config[:tag_map].delete_if{|k,v| v.empty?}
    @config[:tag_map] = "var tag_map =" + JSON.generate(@config[:tag_map])
  end
end
