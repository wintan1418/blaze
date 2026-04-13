class AddNameSnapshotToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :name_snapshot, :string
  end
end
