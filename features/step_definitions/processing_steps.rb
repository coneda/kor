Given /^everything is indexed$/ do
  Kor::Elastic.index_all
end

Given /^everything is processed$/ do
  Delayed::Worker.new.work_off
end
