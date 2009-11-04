namespace :db do
  task :fast_fixture_clone, :db_prefix do |t, args|
    ENV["RAILS_ENV"] = "test"
    require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
    FastFixture::Cloner.new(args[:db_prefix]).clone
  end
  Rake::Task["db:fast_fixture_clone"].comment = "Clones dev DB to test DB changing MyISAM tables to InnoDB"
end
