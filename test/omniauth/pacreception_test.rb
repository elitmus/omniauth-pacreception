require "test_helper"

class Omniauth::PacreceptionTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Omniauth::Pacreception::VERSION
  end

  def test_requiring_the_gem_registers_the_strategy
    assert defined?(OmniAuth::Strategies::Pacreception)
  end
end
