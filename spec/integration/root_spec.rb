require 'spec_helper'

describe 'When defining root element' do
  context 'when root is enabled' do
    serializer do
      root :my_root
      attribute :field
    end

    before do
      create_table{|t| t.string :field}
    end

    after { remove_table }

    it 'uses the name specificed for the root element' do
      expect(json['my_root'].length).to eq 0
    end
  end
end
