

Given /^the setup "([^"]*)"$/ do |name|
  case name
    when 'Bamberg'
      step 'the entity "Bamberg" of kind "Ort/Orte"'
      step 'the entity "Bamberger Apokalypse" of kind "Werk/Werke"'
      step 'the entity "Sankt Stephan" of kind "Institution/Institutionen"'
      step 'the relation "befindet sich in/Aufbewahrungsort von" between "Werk/Werke" and "Institution/Institutionen"'
      step 'the relation "Institution in Ort/Ort der Institution" between "Institution/Institutionen" and "Ort/Orte"'
    when 'Frankfurt-Berlin'
      step "the credential \"User Frankfurt\""
      step "the credential \"Admin Frankfurt\""
      step "the credential \"User Berlin\""
      step "the credential \"Admin Berlin\""
      step "the collection \"Frankfurt\""
      step "the collection \"Berlin\""
      
      user_frankfurt = Credential.find_by_name('User Frankfurt')
      admin_frankfurt = Credential.find_by_name('Admin Frankfurt')
      user_berlin = Credential.find_by_name('User Berlin')
      admin_berlin = Credential.find_by_name('Admin Berlin')
      
      frankfurt = Collection.find_by_name('Frankfurt')
      Kor::Auth.grant frankfurt, :view, :to => [user_frankfurt, admin_frankfurt, user_berlin, admin_berlin]
      Kor::Auth.grant frankfurt, :edit, :to => [admin_frankfurt]
      Kor::Auth.grant frankfurt, :create, :to => [admin_frankfurt]
      Kor::Auth.grant frankfurt, :delete, :to => [admin_frankfurt]
      Kor::Auth.grant frankfurt, :approve, :to => [admin_frankfurt]
      Kor::Auth.grant frankfurt, :download_originals, :to => [admin_frankfurt]
      
      berlin = Collection.find_by_name('Berlin')
      Kor::Auth.grant berlin, :view, :to => [user_frankfurt, admin_frankfurt, admin_berlin]
      Kor::Auth.grant berlin, :edit, :to => [user_berlin, admin_berlin]
      Kor::Auth.grant berlin, :create, :to => [user_berlin, admin_berlin]
      Kor::Auth.grant berlin, :delete, :to => [admin_berlin]
      Kor::Auth.grant berlin, :approve, :to => [admin_berlin]
      Kor::Auth.grant berlin, :download_originals, :to => [admin_frankfurt]
      
      step "the entity \"Frankfurter Dom\" of kind \"Werk/Werke\" inside collection \"Frankfurt\""
      step "the entity \"Kreuzberg\" of kind \"Ort/Orte\" inside collection \"Berlin\""
      step "the entity \"Neukölln\" of kind \"Ort/Orte\" inside collection \"Berlin\""
      step "the entity \"Rathaus\" of kind \"Werk/Werke\" inside collection \"Frankfurt\""
      step "the relation \"Standort in/Standort von\" between \"Werk/Werke\" and \"Ort/Orte\""
    when "Many relationships with images"
      step "the entity \"Mona Lisa\" of kind \"Werk/Werke\""
      step "the kind \"Ort/Orte\""
      step "the medium \"spec/fixtures/image_a.jpg\""
      step "the relation \"stellt dar/wird dargestellt von\" between \"medium/media\" and \"Ort/Orte\""
      step "the relation \"ist äquivalent zu/ist äquivalent zu\" between \"Werk/Werke\" and \"Ort/Orte\""
      
      mona_lisa = Entity.find_by_name('Mona Lisa')
      test_entity = FactoryGirl.create :location
      image = Medium.last.entity
      
      11.times do
        Relationship.relate_and_save(mona_lisa, 'ist äquivalent zu', test_entity)
      end
      
      Relationship.relate_and_save(test_entity, 'wird dargestellt von', image)
    else
      raise "unknown setup #{name}"
  end
end

Given(/^the default test data$/) do
  require "#{Rails.root}/spec/support/data_helper"
  Class.new.extend(DataHelper).default_setup relationships: true
end
