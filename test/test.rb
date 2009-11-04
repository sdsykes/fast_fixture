require File.dirname(__FILE__) + '/setup.rb'

class FastFixtureTest < Test::Unit::TestCase
  def setup
    ActiveRecord::Base.configurations = YAML.load(File.read(RAILS_ROOT + "/config/database.yml"))
    ActiveRecord::Base.establish_connection(:development)
    load File.dirname(__FILE__) + '/schema/schema.rb'
  end

  def test_original_table_uses_myisam
    ActiveRecord::Base.establish_connection(:development)
    t = ActiveRecord::Base.connection.select_all("SHOW CREATE TABLE courses")[0]
    assert t["Create Table"] =~ /ENGINE=MyISAM/
  end

  def test_cloned_table_uses_innodb
    FastFixture::Cloner.new.clone
    ActiveRecord::Base.establish_connection(:test)
    t = ActiveRecord::Base.connection.select_all("SHOW CREATE TABLE courses")[0]
    assert t["Create Table"] =~ /ENGINE=InnoDB/
  end
end
