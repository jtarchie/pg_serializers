require "postgres_json_serializer/version"

module PostgresJsonSerializer
  Attribute = Struct.new(:field, :options) do
    def custom_key(key)
      (options.try(:[], :key) || key).to_s
    end

    def to_arel(serializer)
      connection = serializer.scope.connection
      if serializer.respond_to?(field)
        value = serializer.send(field)
        value = Arel::SqlLiteral.new(connection.quote(value)) unless value.is_a?(Arel::SqlLiteral)
      else
        model = serializer.scope.model
        value = model.arel_table[field]
      end

      value.as(custom_key(field))
    end
  end

  class Association < Attribute
    def to_arel(serializer)
      model = serializer.scope.model
      reflection = model.reflections[field]
      klass = reflection.klass

      serializer.scope.joins!(field).references!(field)
      arel = Arel::Nodes::NamedFunction.new("array_agg",[klass.arel_table[klass.primary_key]])
      arel.as(custom_key("#{field}_ids"))
    end
  end

  class Serializer < Struct.new(:scope)
    def self.has_many(field, options = {})
      add_attribute Association.new(field, options)
    end

    def self.attribute(field, options = {})
      add_attribute Attribute.new(field, options)
    end

    def self.attributes(*fields)
      add_attribute *fields.collect{|f| Attribute.new(f) }
    end

    def self.add_attribute(*attributes)
      @attributes ||= []
      @attributes += attributes
    end

    def to_json
      connection = scope.connection
      attributes_select = self.class.attributes.collect do |a|
        a.to_arel(self)
      end
      connection.select_value("SELECT array_to_json(array_agg(row_to_json(t))) FROM (#{scope.select(attributes_select).to_sql}) t")
    end
  end
end
