require File.dirname(__FILE__) + '/setup.rb'

class FastFixtureTest < Test::Unit::TestCase
  def setup
    load 'schema/schema.rb'
  end

  def test_cloned_table_is_correct
    FastFixture::Cloner.new.clone
    assert true
  end
end
