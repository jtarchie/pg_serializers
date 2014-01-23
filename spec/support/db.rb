require 'active_record'
options = {adapter: "postgresql", database: "pjs_test", username: "jtarchie"}

ActiveRecord::Base.establish_connection options.merge('database' => 'postgres', 'schema_search_path' => 'public')
connection = ActiveRecord::Base.connection
connection.drop_database options[:database] rescue nil
connection.create_database options[:database]
ActiveRecord::Base.establish_connection options

class Example < ActiveRecord::Base; end

module DBExtensions
  def self.included(base)
    base.let(:connection) { Example.connection }
  end

  def create_table(model = Example, &block)
    connection.create_table(model.table_name, &block)
    model.reset_column_information
  end

  def remove_table(model = Example)
    connection.drop_table(model.table_name)
  end

  Rspec.configure { |c| c.include self } if defined?(RSpec)
end
