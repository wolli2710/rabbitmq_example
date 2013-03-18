class ImagesController < ApplicationController
    require 'bunny'
    require 'json'

    before_filter :authenticate_user!, :only => [:new, :create]

######################################
    #Bunny Stuff
######################################
    def self.client
        unless @client
            c = Bunny.new
            c.start
            @client = c
        end
        @client
    end

    def self.send_image
      @send_image ||= client.exchange('')
    end
######################################

    def index
        @images = Image.all
    end

    def show
        @image = Image.find(params[:id])
    end

    def new
        @image = Image.new
    end

    def create
        @image = Image.new(params[:image])
        @image.user_id = current_user.id
        if @image.save
            path = @image.image.url.split("/").slice(0..-2).join("/") + "/"
            file = @image.image.url.split("/").last
       
            str = {:image_id => @image.id ,:root_path => Rails.root, :image_path => path, :image_file => file}
            ImagesController.send_image.publish str.to_json , :key => "images"
            redirect_to root_url, :notice => "Image uploaded!"
        else
            render :new
        end
    end
end