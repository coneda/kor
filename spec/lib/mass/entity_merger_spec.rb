# encoding: utf-8

require 'spec_helper'

describe Mass::EntityMerger do
  include DataHelper
  
  it "should merge entities while preserving external references" do
    test_data
    
    mona_lisa = Entity.find_by_name('Mona Lisa')
    mona_lisa.external_references = {:pnd => '12345', :address => 'Am Alten Schloß 36, Frankfurt'}
    
    merged = Mass::EntityMerger.new.run(:old_ids => Entity.all.map{|e| e.id},
      :attributes => {
        :name => mona_lisa.name,
        :external_references => {
          :pnd => '12345'
        }
      }
    )
    
    Entity.count.should eql(1)
    merged.external_references[:pnd].should eql('12345')
  end
  
end
