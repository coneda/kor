class String
  def short(how_short = 30)
    length > how_short ? first(how_short - 3).strip + "..." : self
  end
end
