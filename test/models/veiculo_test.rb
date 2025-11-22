require "test_helper"

class VeiculoTest < ActiveSupport::TestCase
  def setup
    @veiculo = Veiculo.new(
      modelo: "Toyota Corolla",
      placa: "ABC-1234",
      tipo: "Carro",
      apoiador: apoiadores(:pedro_lider)
    )
  end

  test "deve ser válido com atributos válidos" do
    assert @veiculo.valid?
  end

  test "não deve ser válido sem modelo" do
    @veiculo.modelo = nil
    assert_not @veiculo.valid?
    assert_includes @veiculo.errors[:modelo], "can't be blank"
  end

  test "não deve ser válido sem placa" do
    @veiculo.placa = nil
    assert_not @veiculo.valid?
    assert_includes @veiculo.errors[:placa], "can't be blank"
  end

  test "deve pertencer a apoiador" do
    assert_respond_to @veiculo, :apoiador
    @veiculo.save
    assert_equal apoiadores(:pedro_lider), @veiculo.apoiador
  end
end
