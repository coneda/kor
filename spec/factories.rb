FactoryGirl.define do

  factory :kind do

    factory :works do
      name "Werk"
      plural_name "Werke"
    end

    factory :media do
      name "Medium"
      plural_name "Media"
      settings { {:naming => false} }
    end

    factory :locations do
      name "Ort"
      plural_name "Orte"
    end

    factory :institutions do
      name "Institution"
      plural_name "Institutionen"
    end

    factory :literatures do
      name "Literatur"
      plural_name "Literatur"
    end

    factory :people do
      name "Person"
      plural_name "People"
    end
  end

  factory :field do
    type 'Fields::String'
    name 'youtube_id'
    show_label 'Youtube-ID'

    factory :isbn do
      type 'Fields::Isbn'
      name 'isbn'
      show_label 'ISBN'
    end
  end
  
  factory :medium do

    factory :medium_a do
      document File.open("#{Rails.root}/spec/fixtures/image_a.jpg")
    end

    factory :medium_b do
      document File.open("#{Rails.root}/spec/fixtures/image_b.jpg")
    end

    factory :medium_c do
      document File.open("#{Rails.root}/spec/fixtures/image_c.jpg")
    end
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

  factory :entity_dating do
    label "Dating"

    factory :d1533 do
      dating_string "1533"
    end

    factory :leonardo_lifespan do
      label "Lifespan"
      dating_string "1452 bis 1519"
    end
  end
  
  factory :entity do
    collection { Collection.find_or_create_by :name => "default" }

    factory :work do
      name "A entity"
      kind { Kind.find_or_create_by :name => "Werk" }

      factory :mona_lisa do
        name "Mona Lisa"
        # datings [EntityDating.where(:dating_string => "1533").first || FactoryGirl.build(:d1533)]

        dataset do
          {:gnd => '12345'}
        end
      end

      factory :der_schrei do
        name "Der Schrei"
      end

      factory :ramirez do
        name "Ramirez"
      end

      factory :landscape do
        name "Landscape"
      end

      factory :the_last_supper do
        name "The Last Supper"
      end

      factory :artwork do
        name "An artwork"
      end
    end

    factory :location do
      name "A location"
      kind { Kind.find_or_create_by :name => "Ort" }

      factory :united_kingdom do
        name "United Kingdom"
      end

      factory :united_states do
        name "United States of America"
      end

      factory :paris do
        name "Paris"
      end
    end

    factory :person do
      name "A person"
      kind { Kind.find_or_create_by :name => "Person" }

      factory :jack do
        name "Jack"
      end

      factory :leonardo do
        name "Leonardo da Vinci"
      end
    end

    factory :institution do
      name "An institution"
      kind { Kind.find_or_create_by :name => "Institution" }
    end

    factory :tom do
      name "Tom"
      kind { Kind.find_or_create_by name: "Person" }
    end

    factory :picture do
      kind { Kind.medium_kind }

      factory :picture_a do
        medium { FactoryGirl.build :medium_a }
      end

      factory :picture_b do
        medium { FactoryGirl.build :medium_b }
      end

      factory :picture_c do
        medium { FactoryGirl.build :medium_c }
      end
    end

  end

  factory :relation do
    name "is related to"
    reverse_name "is related to"

    factory :is_part_of do
      name "is part of"
      reverse_name "consists of"
    end

    factory :shows do
      name "shows"
      reverse_name "is shown by"
    end

    factory :has_created do
      name "has created"
      reverse_name "has been created by"
    end

    factory :is_equivalent_to do
      name "is equivalent to"
      reverse_name "is equivalent to"
    end

    factory :is_located_at do
      name "is located at"
      reverse_name "is location of"
    end

    factory :is_sibling_of do
      name "is sibling of"
      reverse_name "is sibling of"
    end
  end

  factory :user do
    terms_accepted true

    factory :hmustermann do
      email 'mustermann@coneda.net'
      name 'hmustermann'
      full_name 'Hans Mustermann'
      password 'mustermann'
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
      
      admin true
      kind_admin true
      relation_admin true
      authority_group_admin true
    end

    factory :guest do
      name 'guest'
      email 'guest@example.com'
      full_name 'Guest'
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

    factory :guests do
      name "guests"
    end
  end

  factory :generator do
    factory :language_indicator do
      name "language_indicator"
      directive "
        <span>Lang-Label:</span>
        <span ng-show=\"locale() == 'en'\">English</span>
        <span ng-show=\"locale() == 'de'\">Deutsch</span>
      "
    end
  end

  factory :authority_group_category do
    factory :archive do
      name 'archive'
    end

    factory :shelf_1 do
      name 'shelf 1'
    end

    factory :shelf_2 do
      name 'shelf 2'
    end
  end

  factory :authority_group do
    name "A authority group"
  end

  factory :user_group do
    name "A user group"
    user_id { User.first.id }
  end

  factory :system_group do
    name "A system group"

    factory :invalids do
      name 'invalid'
    end
  end

  factory :exception_log do

  end
  
end
