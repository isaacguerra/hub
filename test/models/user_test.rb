require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "teste@example.com",
      password: "senha123",
      password_confirmation: "senha123",
      apoiador: apoiadores(:pedro_lider)
    )
  end

  test "deve ser válido com atributos válidos" do
    assert @user.valid?
  end

  test "não deve ser válido sem email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "deve ter password_digest após criar com senha" do
    @user.save
    assert_not_nil @user.password_digest
  end

  test "deve autenticar com senha correta" do
    @user.save
    assert @user.authenticate("senha123")
  end

  test "não deve autenticar com senha incorreta" do
    @user.save
    assert_not @user.authenticate("senha_errada")
  end
end
