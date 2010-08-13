class CreateAssetOnSegmentHistories < ActiveRecord::Migration
  def self.up
    create_table :asset_on_segment_histories do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :asset_on_segment_histories
  end
end
