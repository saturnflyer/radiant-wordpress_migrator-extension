namespace :radiant do
  namespace :extensions do
    namespace :wordpress_migrator do
      
      desc "Runs the migration of the Wordpress Migrator extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          WordpressMigratorExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          WordpressMigratorExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Wordpress Migrator to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from WordpressMigratorExtension"
        Dir[WordpressMigratorExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(WordpressMigratorExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end  
    end
  end
end
