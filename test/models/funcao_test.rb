require "test_helper"

class FuncaoTest < ActiveSupport::TestCase
  def setup
    @funcao = funcoes(:apoiador)
  end

  test "deve ser válido com atributos válidos" do
    assert @funcao.valid?
  end

  test "não deve ser válido sem name" do
    @funcao.name = nil
    assert_not @funcao.valid?
    assert_includes @funcao.errors[:name], "can't be blank"
  end

  test "deve ter muitos apoiadores" do
    assert_respond_to @funcao, :apoiadores
  end
end
