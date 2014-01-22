module DslHelper
  def json
    JSON.parse(serializer.new(Example.all).to_json).first
  end

  module ClassMethods
    def serializer(&block)
      let(:serializer) { Class.new(PostgresJsonSerializer::Serializer, &block) }
    end

    RSpec.configure {|c| c.extend self }
  end

  RSpec.configure {|c| c.include self}
end
