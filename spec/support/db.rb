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

  def create_table(&block)
    connection.create_table(:examples, &block)
    Example.reset_column_information
  end

  def remove_table
    connection.drop_table(:examples)
  end

  Rspec.configure { |c| c.include self }
end
