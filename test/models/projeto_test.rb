require "test_helper"

class ProjetoTest < ActiveSupport::TestCase
  fixtures :projetos

  test "valido com nome presente" do
    p = projetos(:default_project)
    assert p.valid?
  end

  test "cidade default tem id 1" do
    assert_equal 1, projetos(:default_project).id
  end
end
