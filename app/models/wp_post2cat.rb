class WpPost2cat < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "wordpress"
  set_table_name 'wp_post2cat'
  set_primary_key 'rel_id'
  
  belongs_to :wp_post, :foreign_key => 'post_id'
  belongs_to :wp_category, :foreign_key => 'category_id'
end