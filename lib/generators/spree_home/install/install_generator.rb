module SpreeHome
  module Generators
    class InstallGenerator < Rails::Generators::Base

      class_option :auto_run_migrations, type: :boolean, default: false

      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "//= require spree/backend/spree_home\n"
      end

      def add_stylesheets
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require spree/backend/spree_home\n", before: /\*\//, verbose: true
      end

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_home'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask 'Would you like to run the migrations now? [Y/n]')
        if run_migrations
          run 'bundle exec rake db:migrate'
        else
          puts 'Skipping rake db:migrate, don\'t forget to run it!'
        end
			end
			def load_spree_home_seed
				if ActiveRecord::Base.connection.table_exists?('spree_homes')
					unless Spree::Home.find_by(name: 'APP')
						Spree::Home.create(name: "APP")
					end
					unless Spree::Home.find_by(name: 'WEB')
						Spree::Home.create(name: "WEB")
					end		
				else
					puts 'after create table spree_homes!!!Do'
					puts 'Spree::Home.create(name: "APP")'
					puts 'Spree::Home.create(name: "WEB")'
				end
			end	
    end
  end
end
