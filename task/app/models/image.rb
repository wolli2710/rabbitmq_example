class Image < ActiveRecord::Base
    attr_accessible :description, :image, :user_id
    default_scope order("images.created_at DESC")

    belongs_to :user
    mount_uploader :image, ImageUploader
end
