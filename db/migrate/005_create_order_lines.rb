class CreateOrderLines < ActiveRecord::Migration
  def self.up
    create_table :order_lines do |t|
      t.belongs_to :model
      t.belongs_to :order
      t.integer :quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :order_lines
  end
end
