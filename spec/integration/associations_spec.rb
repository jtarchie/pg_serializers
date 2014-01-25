require 'spec_helper'

describe "When there are associations on the serializer" do
  before do
    create_table(Example) {|t| t.string :name }
    create_table(Child) {|t| t.belongs_to :example }
  end

  after do
    remove_table(Example)
    remove_table(Child)
  end

  context "and you are embedding ids" do
    serializer do
      has_many :children, embed: :ids
    end

    def json(scope)
      JSON.parse(serializer.new(scope).to_json)
    end

    def create_example(name)
      example = Example.create(name: name)
      3.times.collect{ example.children.create }
      example
    end

    def create_example_json(name)
      json(Example.where(id: create_example(name).id)).first
    end

    it "returns only the associated ids" do
      json = create_example_json("Bob")

      expect( json['children_ids'] ).to match_array [1, 2, 3]
    end

    it "associates the ids correctly to the parent" do
      bob_json = create_example_json("Bob")
      tom_json = create_example_json("Tom")


      expect( bob_json['children_ids'] ).to match_array [1, 2, 3]
      expect( tom_json['children_ids'] ).to match_array [4, 5, 6]
    end

    it "only contains one version of the parent" do
      example = create_example("Bob")

      expect( json(Example.where(id: example.id)).length ).to eq 1
    end

    context "with options" do
      serializer do
        has_many :children, embed: :ids, key: :not_my_children_ids
      end

      it "returns the value of the field on custom key" do
        json = create_example_json("Bob")
        expect( json['not_my_children_ids'] ).to match_array [1, 2, 3]
      end
    end
  end
end
