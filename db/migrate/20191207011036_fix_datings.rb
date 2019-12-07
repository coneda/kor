class FixDatings < ActiveRecord::Migration
  def up
    EntityDating.find_each do |ed|
      parsed = ed.class.parse(ed.dating_string)
      if parsed
        ed.update_columns(
          from_day: ed.class.julian_date_for(parsed[:from]),
          to_day: ed.class.julian_date_for(parsed[:to])
        )
      end
    end

    RelationshipDating.find_each do |rd|
      parsed = rd.class.parse(ed.dating_string)
      if parsed
        rd.update_columns(
          from_day: rd.class.julian_date_for(parsed[:from]),
          to_day: rd.class.julian_date_for(parsed[:to])
        )
      end
    end
  end

  def down
    raise ActiveSupport::IrreversibleMigration
  end
end
