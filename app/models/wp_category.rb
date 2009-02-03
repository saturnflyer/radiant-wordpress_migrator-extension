class WpCategory < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "wordpress"
  set_table_name 'wp_categories'
  set_primary_key 'cat_ID'
  
  has_many :wp_post2cat, :foreign_key => 'category_id'
  has_many :wp_posts, :through => 'wp_post2cat'
  
  def self.move_to_radiant
    WpCategory.find(:all).each do |cat|
      MetaTag.find_or_create_by_name(cat.cat_name)
    end
  end
end