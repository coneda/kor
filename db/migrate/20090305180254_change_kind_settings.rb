class ChangeKindSettings < ActiveRecord::Migration
  def self.up
    k = Kind.get('artwork')
    if k
      k.settings[:form_style]['subtype'][:can_be_empty] = true
      k.save
    end
  end

  def self.down
    k = Kind.get('artwork')
    if k
      k.settings[:form_style]['subtype'].delete(:can_be_empty)
      k.save
    end
  end
end
