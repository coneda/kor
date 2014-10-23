FactoryGirl.define do
  
  factory :kind do
    name "Werk"
    plural_name "Werke"

    factory :works do
      
    end

    factory :media do
      name "Medium"
      plural_name "Media"
    end

    factory :locations do
      name "Ort"
      plural_name "Orte"
    end

    factory :people do
      name "Person"
      plural_name "People"
    end
  end
  
  factory :medium do
    document File.open("#{Rails.root}/spec/fixtures/image_a.jpg")
  end

  factory :medium_without_swap, :class => Medium do
    image File.open("#{Rails.root}/spec/fixtures/image_a.jpg")
  end
  
  factory :collection do
    factory :default do
      name "default"
    end

    factory :private do
      name "private"
    end
  end
  
  factory :entity do
    collection { Collection.find_or_create_by_name "default" }

    factory :mona_lisa do
      name "Mona Lisa"
      kind { Kind.find_or_create_by_name "Werk" }

      factory :der_schrei do
        name "Der Schrei"
      end

      factory :ramirez do
        name "Ramirez"
      end
    end

    factory :united_kingdom do
      name "United Kingdom"
      kind { Kind.find_or_create_by_name "Ort" }

      factory :united_states do
        name "United States of America"
      end
    end

    factory :landscape do
      name "Landscape"
      kind { Kind.find_or_create_by_name "Werk" }
    end

    factory :jack do
      name "Jack"
      kind { Kind.find_or_create_by_name "Person" }
    end

    factory :picture do
      kind { Kind.medium_kind }
      medium { FactoryGirl.build :medium }
    end

  end

  factory :relation do
    name "is related to"
    reverse_name "is related to"

    factory :is_part_of do
      name "ist Teil von"
      reverse_name "besteht aus"
    end
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
    factory :admins do
      name "admins"
    end

    factory :students do
      name "students"
    end
  end
  
end
