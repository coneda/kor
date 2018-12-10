class Kor::Statistics::Editors < Kor::Statistics::Simple
  def items
    User.all
  end

  def create_counts
    @create_counts ||= Entity.group(:creator_id).count
  end

  def update_counts
    @update_counts ||= Entity.group(:updater_id).count
  end

  def counts_for(user_id)
    return {
      :created => create_counts[user_id] || 0,
      :updated => update_counts[user_id] || 0
    }
  end

  def process(item)
    result = {
      :id => item.id,
      :name => item.display_name,
      :days => ((Time.now - item.created_at).to_f / 60 / 60 / 24).round(2),
    }

    result.merge! counts_for(item.id)

    unless result[:days] == 0
      result.merge!(
        :created_per_day => (result[:created].to_f / result[:days]).round(2),
        :updated_per_day => (result[:updated].to_f / result[:days]).round(2)
      )
    end

    statistics << result unless result[:created] + result[:updated] == 0
  end

  def statistics
    @statistics ||= []
  end

  def ordered_statistics
    statistics.sort do |x, y|
      x[:created_per_day] + x[:updated_per_day] <=> y[:created_per_day] + y[:updated_per_day]
    end.reverse
  end

  def report
    result = "counted entities for #{total} users\n"
    result << ::Hirb::Helpers::AutoTable.render(ordered_statistics,
      :fields => [:name, :days, :created, :updated, :created_per_day, :updated_per_day]
    )
    result
  end
end
