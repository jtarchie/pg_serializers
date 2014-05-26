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
        value = Arel.sql(connection.quote(value)) unless value.is_a?(Arel::SqlLiteral)
      else
        model = serializer.scope.model
        value = model.arel_table[field]
      end

      value.as(connection.quote_column_name(custom_key(field)))
    end
  end

  Root = Struct.new(:name) do
    def to_arel(serializer)
      connection = serializer.scope.connection
      array_json = Arel.sql("COALESCE(array_to_json(array_agg(row_to_json(t))), '[]')")

      if self.name
        Arel.sql("'{' || to_json(#{connection.quote(self.name)}::text) || ':' || #{array_json} || '}'")
      else
        array_json
      end
    end
  end

  class Serializer
    attr_reader :scope

    def initialize(scope)
      @scope = scope.dup
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

    def self.root(*name)
      @root ||= Root.new(*name) if name
      @root
    end

    def to_json(*)
      connection = scope.connection
      attributes_select = self.class.attributes.collect do |a|
        a.to_arel(self)
      end
      select = Arel::SelectManager.new(Arel::Table.engine)
      select.project(self.class.root.to_arel(self))
      select.from(Arel::Nodes::TableAlias.new(scope.select(attributes_select).arel, Arel::Table.new("t").name))
      connection.select_value(select)
    end
  end
end

