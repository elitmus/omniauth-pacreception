require "test_helper"

# Critical-path coverage for the PAC Reception OAuth2 strategy:
# configuration defaults, the auth-hash builders (uid/info/extra), the prune!
# helper, the callback_url override, and authorize_params scope handling.
class OmniAuth::Strategies::PacreceptionTest < Minitest::Test
  def app
    @app ||= ->(_env) { [200, {}, ["Hello"]] }
  end

  def build(options = {})
    OmniAuth::Strategies::Pacreception.new(app, options)
  end

  def build_with_env(query = "", options = {})
    strat = build(options)
    env = Rack::MockRequest.env_for("/auth/pacreception#{query}", "rack.session" => {})
    strat.instance_variable_set(:@env, env)
    strat
  end

  def raw_info_fixture
    {
      "user" => {
        "id"         => 42,
        "email"      => "jane@example.com",
        "first_name" => "Jane",
        "last_name"  => "Doe"
      }
    }
  end

  def build_with_raw(options = {})
    strat = build(options)
    raw = raw_info_fixture
    strat.define_singleton_method(:raw_info) { raw }
    strat
  end

  # ---- configuration / defaults ----

  def test_default_name
    assert_equal :pacreception, build.options.name
  end

  def test_default_client_site
    assert_equal "https://www.pacreception.com", build.options.client_options.site
  end

  def test_default_authorize_options
    assert_equal %i[scope auth_type], build.options.authorize_options
  end

  def test_client_site_is_overridable
    strat = build(client_options: { site: "https://staging.pacreception.com" })
    assert_equal "https://staging.pacreception.com", strat.options.client_options.site
  end

  # ---- uid / info / extra (raw_info stubbed) ----

  def test_uid_comes_from_raw_info
    assert_equal 42, build_with_raw.uid
  end

  def test_info_builds_email_and_full_name
    info = build_with_raw.info
    assert_equal "jane@example.com", info["email"]
    assert_equal "Jane Doe", info["name"]
  end

  def test_extra_includes_raw_info_by_default
    assert_equal raw_info_fixture, build_with_raw.extra["raw_info"]
  end

  def test_extra_omits_raw_info_when_skip_info
    refute build_with_raw(skip_info: true).extra.key?("raw_info")
  end

  # ---- prune! ----

  def test_prune_removes_nil_and_empty_values
    pruned = build.prune!("a" => "x", "b" => nil, "c" => "", "d" => "y")
    assert_equal({ "a" => "x", "d" => "y" }, pruned)
  end

  def test_prune_recurses_into_nested_hashes
    pruned = build.prune!("a" => { "b" => nil, "c" => "keep" }, "e" => {})
    assert_equal({ "a" => { "c" => "keep" } }, pruned)
  end

  # ---- callback_url ----

  def test_callback_url_prefers_explicit_option
    url = "https://app.example.com/auth/pacreception/callback"
    assert_equal url, build(callback_url: url).callback_url
  end

  # ---- authorize_params ----

  def test_authorize_params_defaults_scope_to_public
    assert_equal "public", build_with_env.authorize_params[:scope]
  end

  def test_authorize_params_honors_request_scope_and_auth_type
    strat = build_with_env("?scope=email%20profile&auth_type=reauthenticate")
    params = strat.authorize_params
    assert_equal "email profile", params[:scope]
    assert_equal "reauthenticate", params[:auth_type]
  end
end
