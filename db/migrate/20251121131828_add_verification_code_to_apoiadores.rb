class AddVerificationCodeToApoiadores < ActiveRecord::Migration[8.1]
  def change
    add_column :apoiadores, :verification_code, :string
    add_column :apoiadores, :verification_code_expires_at, :datetime
  end
end
