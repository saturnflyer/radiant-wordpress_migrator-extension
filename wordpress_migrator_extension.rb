# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class WordpressMigratorExtension < Radiant::Extension
  version "1.0"
  description "Tools to migrate from a WordPress database"
  url "http://saturnflyer.com"

  class MissingDependency < StandardError; end
  
  def activate
    raise WordpressMigratorExtension::MissingDependency.new('You must have the ability to tag your pages with an extension such as the tags extension.') unless Page.new.respond_to?(:tags)
    # admin.tabs.add "Wordpress Migrator", "/admin/wordpress_migrator", :after => "Layouts", :visibility => [:all]
  end
  
  def deactivate
    # admin.tabs.remove "Wordpress Migrator"
  end
  
end
