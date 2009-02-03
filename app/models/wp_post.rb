class WpPost < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "wordpress"
  set_table_name 'wp_posts'
  set_primary_key 'ID'
  
  belongs_to :author, :class_name => 'WpUser', :foreign_key => 'post_author'
  belongs_to :parent, :class_name => 'WpPost', :foreign_key => 'post_parent'
  has_many :wp_post2cats, :foreign_key => 'post_id'
  has_many :categories, :through => :wp_post2cats, :source => :wp_category
  has_many :wp_post2tags, :foreign_key => 'post_id'
  has_many :tags, :through => :wp_post2tags, :source => :wp_tag
  
  def self.move_to_radiant
    # this map could be better
    wp_failed = []
    wp_status_map = {'publish' => 100, 'draft' => 1, 'future' => 1, 'inherit' => 101}
    @home = Page.find_by_slug('/')
    WpPost.find(:all, :conditions => ['post_type = ?','post']).each do |post|
      unless @radiant_author = User.find_by_login(post.author.user_login)
        @radiant_author = User.find_by_login(post.author.user_nicename)
      end
      @radiant_page = Page.find_by_slug(post.post_name) || Page.new
      @radiant_page[:parent_id] = @home.id
      @radiant_page[:title] = post.post_title
      @radiant_page[:slug] = post.post_name
      @radiant_page[:breadcrumb] = post.post_title
      @radiant_page[:created_by_id] = @radiant_author.id
      @radiant_page[:updated_by_id] = @radiant_author.id
      @radiant_page[:published_at] = post.post_date
      @radiant_page[:status_id] = wp_status_map[post.post_status]
      @radiant_page[:class_name] = 'InvisiblePage'# dependency on invisible_pages extension
      if @radiant_page.save!
        @radiant_page.parts.create(:name => 'body', :content => post.post_content, :filter_id => 'Textile')
        @radiant_page.parts.create(:name => 'excerpt', :content => post.post_excerpt, :filter_id => 'Textile') unless post.post_excerpt.blank?
        tags = post.tags.collect {|t| t.tag}
        categories = post.categories.collect {|c| c.cat_name }
        all_tags = tags + categories
        @radiant_page.tag_with(all_tags.join(MetaTag::DELIMITER))
      else
        wp_failed << post.ID
      end
    end
    puts "Failed posts: #{wp_failed.to_s}" unless wp_failed.empty?
  rescue ActiveRecord::Associations::PolymorphicError => e
    puts e.message
    puts "New record? #{@radiant_page.new_record?}"
    puts @radiant_page.inspect
    puts @radiant_page.errors.full_messages
    puts @radiant_page.parts.inspect
  end
  
end