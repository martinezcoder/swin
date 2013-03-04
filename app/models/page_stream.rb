# == Schema Information
#
# Table name: page_streams
#
#  id             :integer          not null, primary key
#  page_id        :integer
#  post_id        :string(255)
#  permalink      :string(255)
#  media_type     :string(255)
#  actor_id       :string(255)
#  target_id      :string(255)
#  likes_count    :integer
#  comments_count :integer
#  share_count    :integer
#  created_time   :integer
#  updated_time   :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class PageStream < ActiveRecord::Base
  belongs_to :page

  validates :page_id, presence: true
end


=begin
  
 SELECT post_id, permalink, likes, actor_id, target_id, attachment, comments, share_count, 
        updated_time, created_time 
   FROM stream 
  WHERE source_id =166233540126948
 
 result = {}
 result["data"] = []
 result["data"][0] = {}
 result["data"][0]["post_id"] = "xxxxxx"
 result["data"][1] = {}
 result["data"][1]["post_id"] = "yyyyyy"
 
 for n results loop
   result["data"][n]["post_id"]
   result["data"][n]["permalink"]
   result["data"][n]["attachment"]["media"]["type"]
   result["data"][n]["actor_id"]
   result["data"][n]["target_id"]
   result["data"][n]["likes"]["count"]
   result["data"][n]["comments"]["count"]
   result["data"][n]["share_count"]
   result["data"][n]["created_time"]
   result["data"][n]["updated_time"]
 end loop

=end
