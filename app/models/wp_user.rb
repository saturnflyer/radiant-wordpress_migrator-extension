class WpUser < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "wordpress"
  set_table_name 'wp_users'
  set_primary_key 'ID'
  
  def self.move_to_radiant
    WpUser.find(:all).each do |user|
      if @radiant_user = User.find_or_create_by_login(user.user_login)
        # wp allows spaces in the user_login... so we move on if we couldn't create
      else
        # try the user_nicename instead
        @radiant_user = User.find_or_create_by_login(user.user_nicename)
      end
      @radiant_user.update_attributes({
        :password => 'password',
        :password_confirmation => 'password',
        :email => user.user_email,
        :name => user.display_name
      })
    end
  end
end