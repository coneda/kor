require 'spec_helper'

RSpec.describe FormsHelper, :type => :helper do
  
  describe "kor_input_tag" do
    it "should not raise an error when labels are given as symbol" do
      expect {
        helper.kor_input_tag(:transit)
      }.not_to raise_error
    end
  end
end
