require "test_helper"

class MunicipioTest < ActiveSupport::TestCase
  def setup
    @municipio = municipios(:macapa)
  end

  test "deve ser válido com atributos válidos" do
    assert @municipio.valid?
  end

  test "não deve ser válido sem name" do
    @municipio.name = nil
    assert_not @municipio.valid?
    assert_includes @municipio.errors[:name], "não pode ficar em branco"
  end

  test "deve ter muitas regiões" do
    assert_respond_to @municipio, :regioes
    assert @municipio.regioes.count > 0
  end

  test "deve ter muitos apoiadores" do
    assert_respond_to @municipio, :apoiadores
  end
end
