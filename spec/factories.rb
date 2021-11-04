FactoryBot.define do
  factory :kind do
    factory :works do
      name {"work"}
      plural_name {"works"}
    end

    factory :media do
      name {"Medium"}
      plural_name {"Media"}
      uuid {Kind::MEDIA_UUID}
      settings{ {:naming => false} }
    end

    factory :locations do
      name {"location"}
      plural_name {"locations"}
    end

    factory :institutions do
      name {"institution"}
      plural_name {"institutions"}
    end

    factory :literatures do
      name {"literature"}
      plural_name {"literature"}
    end

    factory :people do
      name {"person"}
      plural_name {"people"}
    end
  end

  factory :field do
    type {'Fields::String'}
    name {'youtube_id'}
    show_label {'Youtube-ID'}

    factory :isbn do
      type {'Fields::Isbn'}
      name {'isbn'}
      show_label {'ISBN'}
    end
  end

  factory :medium do
    factory :medium_image_a do
      document {File.open("#{Rails.root}/spec/fixtures/image_a.jpg")}
    end

    factory :medium_image_b do
      document {File.open("#{Rails.root}/spec/fixtures/image_b.jpg")}
    end

    factory :medium_image_c do
      document {File.open("#{Rails.root}/spec/fixtures/image_c.jpg")}
    end

    factory :medium_image_exif do
      document {File.open("#{Rails.root}/spec/fixtures/image_exif.tiff")}
    end

    factory :medium_video_a do
      document {File.open("#{Rails.root}/spec/fixtures/video_a.m4v")}
    end

    factory :medium_video_b do
      document {File.open("#{Rails.root}/spec/fixtures/video_b.flv")}
    end

    factory :medium_audio_a do
      document {File.open("#{Rails.root}/spec/fixtures/audio_a.wav")}
    end

    factory :medium_audio_b do
      document {File.open("#{Rails.root}/spec/fixtures/audio_b.mp3")}
    end

    factory :medium_text_a do
      document {File.open("#{Rails.root}/spec/fixtures/text_file.txt")}
    end
  end

  factory :medium_without_swap, :class => Medium do
    image {File.open("#{Rails.root}/spec/fixtures/image_a.jpg")}
  end

  factory :collection do
    factory :default do
      name {"default"}
    end

    factory :private do
      name {"private"}
    end
  end

  factory :entity_dating do
    label {"Dating"}

    factory :d1533 do
      dating_string {"1533"}
    end

    factory :leonardo_lifespan do
      label {"Lifespan"}
      dating_string {"1452 bis 1519"}
    end
  end

  factory :entity do
    collection{ Collection.find_or_create_by name: "default" }

    factory :work do
      name {"A entity"}
      kind{ Kind.find_or_create_by name: 'work', plural_name: 'works' }

      factory :mona_lisa do
        name {"Mona Lisa"}

        dataset do
          {:gnd => '12345'}
        end
      end

      factory :der_schrei do
        name {"Der Schrei"}
      end

      factory :ramirez do
        name {"Ramirez"}
      end

      factory :landscape do
        name {"Landscape"}
      end

      factory :the_last_supper do
        name {"The Last Supper"}
      end

      factory :artwork do
        name {"An artwork"}
      end
    end

    factory :location do
      name {"A location"}
      kind{ Kind.find_or_create_by name: "location", plural_name: 'locations' }

      factory :united_kingdom do
        name {"United Kingdom"}
      end

      factory :united_states do
        name {"United States of America"}
      end

      factory :paris do
        name {"Paris"}
      end
    end

    factory :person do
      name {"A person"}
      kind{ Kind.find_or_create_by name: 'person', plural_name: 'people' }

      factory :jack do
        name {"Jack"}
      end

      factory :leonardo do
        name {"Leonardo da Vinci"}
      end

      factory :tom do
        name {"Tom"}
      end
    end

    factory :institution do
      name {"An institution"}
      kind{ Kind.find_or_create_by name: 'Institution', plural_name: 'Institutionen' }
    end

    factory :medium_entity do
      kind{ Kind.medium_kind }

      factory :picture_a do
        medium{ FactoryBot.build :medium_image_a }
      end

      factory :picture_b do
        medium{ FactoryBot.build :medium_image_b }
      end

      factory :picture_c do
        medium{ FactoryBot.build :medium_image_c }
      end

      factory :picture_exif do
        medium{ FactoryBot.build :medium_image_exif }
      end

      factory :video_a do
        medium{ FactoryBot.build :medium_video_a }
      end

      factory :video_b do
        medium{ FactoryBot.build :medium_video_b }
      end

      factory :audio_a do
        medium{ FactoryBot.build :medium_audio_a }
      end

      factory :audio_b do
        medium{ FactoryBot.build :medium_audio_b }
      end

      factory :text do
        medium{ FactoryBot.build :medium_text_a }
      end
    end
  end

  factory :relation do
    name {"is related to"}
    reverse_name {"is related to"}

    factory :is_part_of do
      name {"is part of"}
      reverse_name {"consists of"}
    end

    factory :shows do
      name {"shows"}
      reverse_name {"is shown by"}
    end

    factory :depicts do
      name {'depicts'}
      reverse_name {'is depicted by'}
    end

    factory :has_created do
      name {"has created"}
      reverse_name {"has been created by"}
    end

    factory :is_equivalent_to do
      name {"is equivalent to"}
      reverse_name {"is equivalent to"}
    end

    factory :is_located_at do
      name {"is located at"}
      reverse_name {"is location of"}
    end

    factory :is_sibling_of do
      name {"is sibling of"}
      reverse_name {"is sibling of"}
    end
  end

  factory :user do
    terms_accepted {true}

    factory :hmustermann do
      email {'mustermann@coneda.net'}
      name {'hmustermann'}
      full_name {'Hans Mustermann'}
      password {'mustermann'}
    end

    factory :jdoe do
      email {'jdoe@coneda.net'}
      name {'jdoe'}
      full_name {'John Doe'}
      password {'jdoe'}
    end

    factory :mrossi do
      email {'mrossi@coneda.net'}
      name {'mrossi'}
      full_name {'Mario Rossi'}
      password {'mrossi'}
    end

    # factory :admin do
    #   email {'admin@coneda.net'}
    #   name {'admin'}
    #   full_name {'Administrator'}
    #   password {'admin'}

    #   admin true
    #   kind_admin true
    #   relation_admin true
    #   authority_group_admin true
    # end

    factory :guest do
      name {'guest'}
      email {'guest@example.com'}
      full_name {'Guest'}
    end

    factory :ldap_template do
      email {'ldap@coneda.net'}
      name {'ldap'}
      full_name {'LDAP template user'}
      password {'ldap'}
    end
  end

  factory :credential do
    factory :admins do
      name {"admins"}
    end

    factory :students do
      name {"students"}
    end

    factory :guests do
      name {"guests"}
    end
  end

  factory :generator do
    factory :language_indicator do
      name {"language_indicator"}
      directive {"
              <span>Lang-Label:</span>
              <span ng-show=\"locale() == 'en'\">English</span>
              <span ng-show=\"locale() == 'de'\">Deutsch</span>
            "}
    end

    factory :gnd_id do
      name {"gnd_id"}
      directive {"<a href=\"https://example.com/{entity.fields.gnd_id}\">GND-ID</>"}
    end

    factory :activity_id do
      name {"activity_id"}
      directive {"<a href=\"https://example.com/{entity.fields.activity_id}\">ACTIVITY-ID</>"}
    end
  end

  factory :authority_group_category do
    factory :archive do
      name {'archive'}
    end

    factory :shelf_1 do
      name {'shelf 1'}
    end

    factory :shelf_2 do
      name {'shelf 2'}
    end
  end

  factory :authority_group do
    name {"seminar"}
  end
end
