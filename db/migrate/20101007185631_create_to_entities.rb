class CreateToEntities < ActiveRecord::Migration
  def self.up
    create_table :to_entities do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :to_entities
  end
end
