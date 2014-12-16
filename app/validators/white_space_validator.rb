class WhiteSpaceValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if value.is_a?(String)
      if value.match(/^\s/)
        record.errors.add attribute, :whitespace_beginning
      end

      if value.match(/\s$/)
        record.errors.add attribute, :whitespace_end
      end

      if value.match(/\s\s/)
        record.errors.add attribute, :whitespace_consecutive
      end
    end
  end

end