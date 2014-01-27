require 'benchmark'
require 'oj'
require 'postgres_json_serializer'
require_relative '../spec/support/db'

n = 10000


connection = Example.connection
connection.create_table(:examples) {|t| t.integer :number }

n.times{|i| Example.create(number: i)}

ActiveRecord::Base.logger = Logger.new(STDOUT)

class Serializer < PostgresJsonSerializer::Serializer
  attribute :number
end

Benchmark.bm do |x|
  x.report("scope.to_json") { Example.all.to_json }
  x.report("scope.pluck") { Example.connection.select_all(Example.all.to_sql).to_json }
  x.report("serializer(scope)") { Serializer.new(Example.all).to_json }
end
