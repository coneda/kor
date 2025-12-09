class Kor::RelatedOrder
  def initialize(from_id, relation_name)
    if from_id.blank? || relation_name.blank?
      raise Kor::Exception, "no from_id or no relation_name given"
    end

    @from_id = from_id
    @relation_name = relation_name
  end

  def self.move_to(dr, new_position)
    instance = new(dr.from_id, dr.relation_name)
    instance.move_to(dr, new_position)
  end

  def self.to_top(dr)
    instance = new(dr.from_id, dr.relation_name)
    instance.to_top(dr)
  end

  def self.to_bottom(dr)
    instance = new(dr.from_id, dr.relation_name)
    instance.to_bottom(dr)
  end

  def self.remove(dr)
    instance = new(dr.from_id, dr.relation_name)
    instance.remove(dr)
  end

  def self.remove_custom(dr)
    instance = new(dr.from_id, dr.relation_name)
    instance.remove_custom!
  end

  def self.authorized?(dr, user)
    instance = new(dr.from_id, dr.relation_name)
    instance.authorized?(user)
  end

  def to_top(dr)
    move_to(dr, 1)
  end

  def to_bottom(dr)
    move_to(dr, max + 1)
  end

  def move_to(dr, new_position)
    remove(dr)

    alphabetical! unless custom?

    dr.update_column :position, new_position
    apply!(beyond_scope(dr), new_position + 1)
  end

  def remove(dr)
    if dr.position > 0
      apply!(beyond_scope(dr), dr.position)
    end
  end

  def custom?
    max > 0
  end

  def remove_custom!
    scope.update_all position: 0
  end

  def alphabetical!
    apply!(scope.order_by_name)
  end

  def apply!(scope, start = 1)
    pos = start
    scope.each do |dr|
      dr.update_column(:position, pos)
      pos += 1
    end
  end

  def max
    scope.maximum(:position)
  end

  def authorized?(user)
    scope.includes(:relationship).each do |dr|
      allowed = Kor::Auth.authorized_for_relationship?(
        user,
        dr.relationship,
        :edit
      )

      return false if !allowed
    end

    true
  end


  protected

    def scope
      DirectedRelationship.
        by_from_entity(@from_id).
        by_relation_name(@relation_name)
    end

    def beyond_scope(dr)
      scope.where('id != ?', dr.id).where('position >= ?', dr.position)
    end
end