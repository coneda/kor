class Kor::Dating::Transform < Parslet::Transform
  rule(:num => simple(:num), :part => simple(:part), :bc => simple(:bc), :cs => simple(:cs)) do
    modifier = {
      "Anfang" => [0, 75],
      "Mitte" => [35, 35],
      "Ende" => [75, 0],
      "1. Hälfte" => [0, 50],
      "2. Hälfte" => [50, 0],
      "1. Drittel" => [0, 66],
      "2. Drittel" => [33, 33],
      "3. Drittel" => [66, 0]
    }[part.to_s]

    if bc.nil?
      {
        :from => Date.new((num.to_i - 1) * 100 + modifier.first, 1, 1),
        :to => Date.new((num.to_i - 1) * 100 + 99 - modifier.last, 12, 31)
      }
    else
      {
        :from => Date.new(num.to_i * -100 + 1 + modifier.first, 1, 1),
        :to => Date.new((num.to_i - 1) * -100 - modifier.last, 12, 31)
      }
    end
  end

  rule(:num => simple(:num), :approx => simple(:approx), :bc => simple(:bc), :cs => simple(:cs)) do
    result = if bc.nil?
      {
        :from => Date.new((num.to_i - 1) * 100, 1, 1),
        :to => Date.new((num.to_i - 1) * 100 + 99, 12, 31)
      }
    else
      {
        :from => Date.new(num.to_i * -100 + 1, 1, 1),
        :to => Date.new((num.to_i - 1) * -100, 12, 31)
      }
    end

    if approx
      result[:from] -= 25.years
      result[:to] += 25.years
    end

    result
  end

  rule(:num => simple(:num), :approx => simple(:approx), :bc => simple(:bc)) do
    modifier = (approx ? 5 : 0)

    if bc.nil?
      {
        :from => Date.new(num.to_i - modifier, 1, 1),
        :to => Date.new(num.to_i + modifier, 12, 31)
      }
    else
      {
        :from => Date.new(num.to_i * -1 - modifier, 1, 1),
        :to => Date.new(num.to_i * -1 + modifier, 12, 31)
      }
    end
  end

  rule(:day => simple(:day), :month => simple(:month), :yearnum => simple(:yearnum)) do
    if !Date.leap?(yearnum.to_i) && month.to_i == 2 && day.to_i == 29
      raise Kor::Exception, I18n.t('not_leap_year', year: yearnum.to_i)
    end

    {
      :from => Date.new(yearnum.to_i, month.to_i, day.to_i),
      :to => Date.new(yearnum.to_i, month.to_i, day.to_i),
    }
  end

  rule(:date => {:from => simple(:from), :to => simple(:to)}) do
    {:from => from, :to => to}
  end

  rule(:from => {:from => simple(:first_from), :to => simple(:first_to)}, :to => {:from => simple(:last_from), :to => simple(:last_to)}) do
    {:from => first_from, :to => last_to}
  end

  [:century, :date_interval, :year, :year_interval, :interval, :century_interval, :century_part].each do |key|
    rule(key => {:from => simple(:from), :to => simple(:to)}) do
      {:from => from, :to => to}
    end
  end

  rule(:year_interval => subtree(:a)) do
    result = {}

    if a[:from] == '?'
      year = a[:to][:from].year
      result = Kor::Dating::Transform.open_start(year)
    else
      from = (a[:from].is_a?(Hash) ? a[:from][:from] : a[:from])
      result[:from] = Date.new(from.year, 1, 1)
      if a[:to] == '?'
        year = result[:from].year
        result = Kor::Dating::Transform.open_end(year)
      else
        result[:to] = Date.new(a[:to].year, 12, 31)
      end
    end

    result
  end

  rule(:before_year => subtree(:a)) do
    year = a[:date][:from].year
    if a[:not]
      Kor::Dating::Transform.open_end(year)
    else
      Kor::Dating::Transform.open_start(year)
    end
  end

  rule(:after_year => subtree(:a)) do
    year = a[:date][:from].year
    if a[:not]
      Kor::Dating::Transform.open_start(year)
    else
      Kor::Dating::Transform.open_end(year)
    end
  end

  def self.open_start(year)
    return {
      from: Date.new(year - distance(year), 1, 1),
      to: Date.new(year, 12, 31)
    }
  end

  def self.open_end(year)
    return {
      from: Date.new(year, 1, 1),
      to: Date.new(year + distance(year), 12, 31)
    }
  end

  def self.distance(year)
    (today.year - year) / 10
  end

  def self.today
    Date.today
  end
end
