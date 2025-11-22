require "test_helper"

class BairroTest < ActiveSupport::TestCase
  def setup
    @bairro = bairros(:centro_bairro)
  end

  test "deve ser válido com atributos válidos" do
    assert @bairro.valid?
  end

  test "não deve ser válido sem name" do
    @bairro.name = nil
    assert_not @bairro.valid?
    assert_includes @bairro.errors[:name], "can't be blank"
  end

  test "deve pertencer a região" do
    assert_respond_to @bairro, :regiao
    assert_equal regioes(:centro), @bairro.regiao
  end

  test "deve ter muitos apoiadores" do
    assert_respond_to @bairro, :apoiadores
  end
end
