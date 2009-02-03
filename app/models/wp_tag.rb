class WpTag < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "wordpress"
  set_table_name 'wp_tags'
  set_primary_key 'tag_ID'
  
  has_many :wp_post2cat, :foreign_key => 'tag_id'
  has_many :wp_posts, :through => 'wp_post2tag'
  
  def self.move_to_radiant
    WpTag.find(:all).each do |tag|
      MetaTag.find_or_create_by_name(tag.tag)
    end
  end
end