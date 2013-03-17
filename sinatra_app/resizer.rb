require 'rubygems'
require 'data_mapper'
require 'dm-mysql-adapter'
require 'dm-core'
require 'sinatra'
require 'bunny'
require 'json'
require 'carrierwave/datamapper'
require 'mini_magick'
require 'carrierwave/processing/rmagick'
require 'logger'

configure :development do
  DataMapper.setup(:default, {
    :adapter  => 'mysql',
    :host     => 'localhost',
    :username => 'root' ,
    :password => '',
    :database => 'task_development'})  
end

class Image
  include DataMapper::Resource

  property :id, Serial
  property :image, String
  property :user_id, Serial
  property :description, String
  property :thumb_url, String
end
DataMapper.auto_upgrade!

#
# Bunny Stuff
#
def self.client
    unless @client
        c = Bunny.new
        c.start
        @client = c
    end
    @client
end

def self.get_images_queue
    @get_images ||= client.queue("images")
end

def self.node_exchange
    @node_exchange ||= client.exchange('')
end

get_images_queue.subscribe(:ack => true) do |msg|
  Dir.chdir("../")
  @@current_dir ||= Dir.pwd
  json_string = JSON.parse(msg[:payload])
puts @current_dir
  image_path = json_string['image_path']
  image_file = json_string['image_file']
  image_id = json_string['image_id']
  thumb_image = image_path+"thumb_"+image_file
  @image = Image.first(:id => image_id)
  @image.thumb_url = thumb_image
  @image.save

  file = @@current_dir+"/task/public"+image_path+image_file 
  (1..10).each do 
    if File.exists?(file)
      image = Magick::ImageList.new(@@current_dir+"/task/public"+image_path+image_file)
      image.crop_resized!( 75, 75, Magick::NorthGravity);
      image.write(@@current_dir+"/task/public"+image_path+"thumb_"+image_file)
      puts "processed thumb"
      break
    else
      sleep(1)
    end
  end

  node_exchange.publish "<p><img src="+image_path+"thumb_"+image_file+" /></p><p>"+@image.description+"</p>", :key => "image_upload"

  puts "sent img to node.js"
end