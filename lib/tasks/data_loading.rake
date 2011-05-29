require 'active_record'
require 'active_record/fixtures'
namespace :db do
  def load_data(env)
    ActiveRecord::Base.establish_connection(env)
    pattern = File.join(RAILS_ROOT, 'db', 'fixtures', env.to_s, '*.{yml,csv}')
    
    Dir.glob(pattern).each do |fixture_file|
      table_name = File.basename(fixture_file, '.*')
      Fixtures.create_fixtures('db/fixtures/' + env.to_s, table_name)
    end
  end

  namespace :import do
    desc "Load fixture data into the development database."

    task :development => :environment do
      load_data :development
    end

    desc "Load fixture data into the production database."
    
    task :production => :environment do
      load_data :production
    end
  end
end