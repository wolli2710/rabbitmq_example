class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|

        t.integer  :user_id
        t.string   :image
        t.string   :thumb_url
        t.string   :description
        
        t.timestamps
    end
  end
end
