# encoding: utf-8

require 'spec_helper'

describe Mass::EntityMerger do
  include DataHelper
  
  it "should merge entities while preserving the dataset" do
    test_data
    
    mona_lisa = Entity.find_by_name('Mona Lisa')
    mona_lisa.dataset = {'gnd' => '12345', 'google_maps' => 'Am Dornbusch 13, 60315 Frankfurt'}
    
    merged = Mass::EntityMerger.new.run(:old_ids => Entity.all.map{|e| e.id},
      :attributes => {
        :name => mona_lisa.name,
        :dataset => {
          'gnd' => '12345'
        }
      }
    )
    
    Entity.count.should eql(1)
    merged.dataset['gnd'].should eql('12345')
  end
  
end
