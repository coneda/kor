require 'spec_helper'

describe Regexp do
  
  it "should parse a multiple value list" do
    
    regex = /^(image|video|application\/x-shockwave-flash)/
    
    expect("image/jpg").to match(regex)
    expect("video/ogg").to match(regex)
    expect("application/x-shockwave-flash").to match(regex)
    
    expect("text/html").not_to match(regex)
  end
  
end
