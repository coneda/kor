class Dating < ActiveRecord::Base

  self.abstract_class = true

  validates :label, :dating_string, presence: true
  
  validate :dating_string_must_be_parseable
  def dating_string_must_be_parseable
    if unparsable? && self[:dating_string].present?
      errors.add :dating_string, :invalid
    end
  end

  def self.after(dating)
    parsed = parse(dating)
    parsed ? where("to_day > ?", julian_date_for(parsed[:from])) : none
  end

  def self.before(dating)
    parsed = parse(dating)
    parsed ? where("from_day < ?", julian_date_for(parsed[:to])) : none
  end

  def self.between(dating)
    after(dating).before(dating)  
  end

  def unparsable?
    !parsable?
  end
  
  def parsable?
    self.class.parse(dating_string) ? true : false
  end
  
  
  # ----------------------------------------------------- virtual attributes ---
  def dating_string=(value)
    self[:dating_string] = value
    parsed = self.class.parse(value)
    
    if parsed
      self[:from_day] ||= self.class.julian_date_for(parsed[:from])
      self[:to_day] ||= self.class.julian_date_for(parsed[:to])
    end
  end
  
  def from_day=(value)
    parsed = self.class.parse(value)
    self[:from_day] = self.class.julian_date_for(parsed[:from]) if parsed
  end
  
  def to_day=(value)
    parsed = self.class.parse(value)
    self[:to_day] = self.class.julian_date_for(parsed[:to]) if parsed
  end

  def self.parse(value)
    begin
      if value
        Kor::Dating::Transform.new.apply Kor::Dating::Parser.new.parse(value)
      end
    rescue Parslet::ParseFailed => e
      nil
    rescue Kor::Exception => e
      nil
    end
  end
  
  def self.julian_date_for(date)
    Date.civil(date.year, date.month, date.day).jd
  end

end