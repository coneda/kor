FactoryGirl.define do
  
  factory :kind do
    name "Werk"
    plural_name "Werke"
  end
  
  factory :medium do
    document File.open("#{Rails.root}/spec/fixtures/image_a.jpg")
  end

  factory :medium_without_swap, :class => Medium do
    image File.open("#{Rails.root}/spec/fixtures/image_a.jpg")
  end
  
  factory :default, :class => Collection do
    name "default"
  end
  
  factory :work, :class => Kind do
    name "Werk"
    plural_name "Werke"
  end
  
  factory :mona_lisa, :class => Entity do
    name "Mona Lisa"

    association :kind, :factory => :work, :method => :build
    collection { Collection.find_or_create_by_name "default" }
    
    factory :der_schrei do
      name "Der Schrei"
    end

    factory :ramirez do
      name "Ramirez"
    end
  end

  factory :is_part_of, :class => Relation do
    name "ist Teil von"
    reverse_name "besteht aus"
  end

  factory :is_related_to, :class => Relation do
    name "steht in Verbindung zu"
    reverse_name "steht in Verbindung zu"
  end

  factory :rating, :class => Api::Rating do
    namespace {'2d3d'}
  end
  
  factory :user do
    email 'mustermann@coneda.net'
    name 'hmustermann'
    full_name 'Hans Mustermann'
    password 'mustermann'

    factory :hmustermann do

    end

    factory :jdoe do
      email 'jdoe@coneda.net'
      name 'jdoe'
      full_name 'John Doe'
      password 'jdoe'
    end

    factory :admin do
      email 'admin@coneda.net'
      name 'admin'
      full_name 'Administrator'
      password 'admin'
      
      rating_admin true
    end

    factory :ldap_template do
      email 'ldap@coneda.net'
      name 'ldap'
      full_name 'LDAP template user'
      password 'ldap'
    end
  end

  factory :credential do

    factory :students do
      name "students"
    end
  end
  
end
