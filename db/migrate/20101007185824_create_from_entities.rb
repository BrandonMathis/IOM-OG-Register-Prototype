class CreateFromEntities < ActiveRecord::Migration
  def self.up
    create_table :from_entities do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :from_entities
  end
end
