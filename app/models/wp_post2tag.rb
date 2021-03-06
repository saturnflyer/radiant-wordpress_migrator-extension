class WpPost2tag < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "wordpress"
  set_table_name 'wp_post2tag'
  set_primary_key 'rel_id'
  
  belongs_to :wp_post, :foreign_key => 'post_id'
  belongs_to :wp_tag, :foreign_key => 'tag_id'
end