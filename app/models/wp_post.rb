class WpPost < ActiveRecord::Base
  include ActionView::Helpers::TextHelper
  self.abstract_class = true
  establish_connection "wordpress"
  set_table_name 'wp_posts'
  set_primary_key 'ID'
  
  belongs_to :author, :class_name => 'WpUser', :foreign_key => 'post_author'
  belongs_to :parent, :class_name => 'WpPost', :foreign_key => 'post_parent'
  has_many :wp_post2cats, :foreign_key => 'post_id'
  has_many :categories, :through => :wp_post2cats, :source => :wp_category
  has_many :wp_post2tags, :foreign_key => 'post_id'
  has_many :meta_tags, :through => :wp_post2tags, :source => :wp_tag
  
  def self.move_to_radiant
    # this map could be better
    wp_failed = []
    wp_status_map = {'publish' => 100, 'draft' => 1, 'future' => 1, 'inherit' => 101}
    @home = Page.find_by_slug('/')
    WpPost.find(:all, :conditions => ['post_type = ?','post']).each do |post|
      unless @radiant_author = User.find_by_login(post.author.user_login)
        @radiant_author = User.find_by_login(post.author.user_nicename)
      end
      @radiant_page = Page.find_by_slug(post.post_name) || Page.find_by_slug(post.post_name.to_s.slugify[0..99]) || Page.new
      @radiant_page[:parent_id] = @home.id
      if !post.post_title.blank?
        title = post.post_title.to_s[0..99]
      elsif !post.post_name.blank?
        title = post.post_name.to_s[0..99]
      else
        title = post.post_content[0..99]
      end
      @radiant_page[:title] = post.post_title
      if !post.post_name.blank?
        slug = post.post_name.to_s.slugify[0..99]
      elsif !post.post_title.blank?
        slug = post.post_title.to_s.slugify[0..99]
      else
        slug = post.post_content[0..99].to_s.slugify
      end
      @radiant_page[:slug] = slug
      @radiant_page[:breadcrumb] = title
      @radiant_page[:created_by_id] = @radiant_author.id
      @radiant_page[:updated_by_id] = @radiant_author.id
      @radiant_page[:published_at] = post.post_date
      @radiant_page[:status_id] = wp_status_map[post.post_status]
      @radiant_page[:invisible] = true# dependency on invisible_pages extension
      if @radiant_page.save && @radiant_page.valid?
        @radiant_page.parts.create(:name => 'body', :content => post.post_content, :filter_id => 'Textile')
        @radiant_page.parts.create(:name => 'excerpt', :content => post.post_excerpt, :filter_id => 'Textile') unless post.post_excerpt.blank?
        meta_tags = post.meta_tags.collect {|t| t.tag}
        categories = post.categories.collect {|c| c.cat_name }
        all_tags = meta_tags + categories
        @radiant_page.tag_with(all_tags.join(MetaTag::DELIMITER))
      else
        wp_failed << post.ID
      end
    end
    puts "Failed posts: #{wp_failed.to_s}" unless wp_failed.empty?
  rescue ActiveRecord::RecordInvalid => e
    puts e.message
    puts @radiant_page.inspect
    puts @radiant_page.parts.inspect
  end
  
end