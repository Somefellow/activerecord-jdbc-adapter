require 'active_record/tasks/database_tasks'

require 'arjdbc/tasks/jdbc_database_tasks'

module ArJdbc
  module Tasks
    class MSSQLDatabaseTasks < JdbcDatabaseTasks
      delegate :clear_active_connections!, to: ActiveRecord::Base

      def create
        establish_master_connection
        connection.create_database(configuration['database'])
        establish_connection configuration
      rescue ActiveRecord::StatementInvalid => error
        case error.message
        when /database .* already exists/i
          raise ActiveRecord::Tasks::DatabaseAlreadyExists
        else
          raise
        end
      end

      def drop
        establish_master_connection
        connection.drop_database configuration['database']
      end

      def purge
        clear_active_connections!
        drop
        create
      end


      def structure_dump(filename)
        config = config_from_url_if_needed
        `smoscript -s #{config['host']} -d #{config['database']} -u #{config['username']} -p #{config['password']} -f #{filename} -A -U`
      end

      def structure_load(filename)
        config = config_from_url_if_needed
        `sqlcmd -S #{config['host']} -d #{config['database']} -U #{config['username']} -P #{config['password']} -i #{filename}`
      end

      private

      def establish_master_connection
        establish_connection configuration.merge('database' => 'master')
      end

      def config_from_url_if_needed
        config = self.config
        if config['url'] && ! config.key?('database')
          config = config_from_url(config['url'])
        end
        config
      end

      def deep_dup(hash)
        dup = hash.dup
        dup.each_pair do |k,v|
          tv = dup[k]
          dup[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? deep_dup(tv) : v
        end
        dup
      end

    end

    module DatabaseTasksMSSQL
      extend ActiveSupport::Concern

      module ClassMethods

      def check_protected_environments!
        super
      rescue ActiveRecord::JDBCError => error
        case error.message
        when /cannot open database .* requested by the login/i
        else
          raise
        end
      end

      end
    end

    ActiveRecord::Tasks::DatabaseTasks.send :include, DatabaseTasksMSSQL
  end
end
