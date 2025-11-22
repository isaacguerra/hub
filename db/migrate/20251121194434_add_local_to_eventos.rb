class AddLocalToEventos < ActiveRecord::Migration[8.1]
  def change
    add_column :eventos, :local, :string
  end
end
