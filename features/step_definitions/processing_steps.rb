Given /^everything is indexed$/ do
  Kor::Elastic.index_all
end

Given(/^all media are processed$/) do
  Delayed::Worker.new.work_off Medium.count
end