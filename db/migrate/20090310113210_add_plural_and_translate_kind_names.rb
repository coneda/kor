class AddPluralAndTranslateKindNames < ActiveRecord::Migration
  def self.up
    add_column :kinds, :plural_name, :string

    Kind.reset_column_information

    Kind.all.each do |k|
      k.plural_name = I18n.t("kinds.#{k.name}", count: :other)
      k.name = I18n.t("kinds.#{k.name}", count: 1)
      k.save
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
