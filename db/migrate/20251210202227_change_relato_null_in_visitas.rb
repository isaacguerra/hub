class ChangeRelatoNullInVisitas < ActiveRecord::Migration[8.1]
  def change
    change_column_null :visitas, :relato, true
  end
end
