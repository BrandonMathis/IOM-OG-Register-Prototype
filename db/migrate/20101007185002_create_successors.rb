class CreateSuccessors < ActiveRecord::Migration
  def self.up
    create_table :successors do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :successors
  end
end
