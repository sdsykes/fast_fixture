module FastFixture
  class Cloner
    def initialize(prefix = nil)
      @prefix = prefix
    end

    def clone
      @conn = db_conn(:development)
      db_dump
      @conn = db_conn(:test)
      db_purge
      @conn = db_conn(:test) # new connection is required after db recreate
      db_clone
    end

    def dump_file
      "#{RAILS_ROOT}/db/development_structure.sql"
    end

    def db_conn(env)
      ActiveRecord::Base.establish_connection(db_conn_spec(env)).connection
    end

    def db_conn_spec(env)
      connections = YAML.load(File.read "#{RAILS_ROOT}/config/database.yml")
      conn_spec = connections["#{@prefix}#{env}"] || connections["#{@prefix}_#{env}"]
      if conn_spec.nil?
        raise "Cannot find database specification.  Configuration '#{db_name}' expected in config/database.yml"
      elsif conn_spec["adapter"] !~ /^mysql/
        raise "Only use this cloner on mysql databases - specify adapter: mysql in database.yml"
      else
        conn_spec
      end
    end

    def db_dump
      File.open(dump_file, "w+") {|f| f << @conn.structure_dump}
    end

    def db_purge
      conn_spec = db_conn_spec(:test)
      @conn.recreate_database(conn_spec["database"], conn_spec)
    end

    def db_clone
      @conn.execute('SET foreign_key_checks = 0')
      IO.readlines(dump_file).join.gsub(/ENGINE=MyISAM/, "ENGINE=InnoDB").split("\n\n").each do |table|
        @conn.execute(table)
      end
    end
  end
end
