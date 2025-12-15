require "test_helper"

class ProjetoTest < ActiveSupport::TestCase
  test "valido com nome e slug" do
    projeto = Projeto.new(name: "Campanha X", slug: "campanha-x")
    assert projeto.valid?
  end

  test "invalido sem nome" do
    projeto = Projeto.new(slug: "no-name")
    refute projeto.valid?
    assert projeto.errors[:name].present?
  end

  test "invalido sem slug" do
    projeto = Projeto.new(name: "Sem Slug")
    refute projeto.valid?
    assert projeto.errors[:slug].present?
  end
end
