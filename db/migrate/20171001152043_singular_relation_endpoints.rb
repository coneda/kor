class SingularRelationEndpoints < ActiveRecord::Migration
  def change
    change_table :relations do |t|
      t.integer :from_kind_id
      t.integer :to_kind_id
    end

    Relation.reset_column_information

    to_be_turned = []

    Relation.all.each do |r|
      fkids = YAML.load(r.from_kind_ids)
      tkids = YAML.load(r.to_kind_ids)

      fkids.product(tkids).each do |c|
        from_kind_id = c[0]
        to_kind_id = c[1]

        new_r = r.dup
        new_r.generate_uuid
        new_r.update_attributes(
          from_kind_id: from_kind_id,
          to_kind_id: to_kind_id
        )

        progress = Kor.progress_bar("adapting relationships [#{r.name}, #{c.inspect}]", r.relationships.count)
        r.relationships.includes(:from, :to).find_each do |rel|
          if rel.from && rel.to
            updates = {}

            if rel.from.kind_id == from_kind_id && rel.to.kind_id == to_kind_id
              updates[:relation_id] = new_r.id
            end

            if r.name == r.reverse_name
              if rel.from.kind_id == to_kind_id && rel.to.kind_id == from_kind_id
                updates[:relation_id] = new_r.id
                updates[:from_id] = rel.to_id
                updates[:to_id] = rel.from_id
                to_be_turned << rel.id
              end
            end
            rel.update_columns updates if updates != {}
          end

          progress.increment
        end
      end

      r.destroy unless r.relationships.count > 0
    end

    DirectedRelationship
      .joins('LEFT JOIN relationships rels ON rels.id = directed_relationships.relationship_id')
      .update_all('directed_relationships.relation_id = rels.relation_id')

    DirectedRelationship
      .from('directed_relationships dr')
      .joins('LEFT JOIN relationships rels ON rels.id = dr.relationship_id')
      .joins('LEFT JOIN relations r ON r.id = dr.relation_id')
      .update_all("
        dr.relation_name = if (dr.is_reverse, r.reverse_name, r.name),
        dr.from_id = if (dr.is_reverse, rels.to_id, rels.from_id),
        dr.to_id = if (dr.is_reverse, rels.from_id, rels.to_id)
      ")

    # progress = Kor.progress_bar('adapting directed relationships', DirectedRelationship.count)
    # DirectedRelationship.includes(:relationship, :relation).find_each do |dr|
    #   dr.update_columns(
    #     relation_name: (dr.is_reverse ? dr.relation.reverse_name : dr.relation.name),
    #     from_id: (dr.is_reverse ? dr.relationship.to_id : dr.relationship.from_id),
    #     to_id: (dr.is_reverse ? dr.relationship.from_id : dr.relationship.to_id)
    #   )
    #   progress.increment
    # end

    change_table :relations do |t|
      t.remove :from_kind_ids
      t.remove :to_kind_ids
    end
  end
end
