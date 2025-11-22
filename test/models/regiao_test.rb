require "test_helper"

class RegiaoTest < ActiveSupport::TestCase
  def setup
    @regiao = regioes(:centro)
  end

  test "deve ser válido com atributos válidos" do
    assert @regiao.valid?
  end

  test "não deve ser válido sem name" do
    @regiao.name = nil
    assert_not @regiao.valid?
    assert_includes @regiao.errors[:name], "can't be blank"
  end

  test "deve pertencer a município" do
    assert_respond_to @regiao, :municipio
    assert_equal municipios(:macapa), @regiao.municipio
  end

  test "deve ter muitos bairros" do
    assert_respond_to @regiao, :bairros
    assert @regiao.bairros.count > 0
  end

  test "deve ter muitos apoiadores" do
    assert_respond_to @regiao, :apoiadores
  end

  test "deve ter coordenador opcional" do
    assert_respond_to @regiao, :coordenador
  end
end
