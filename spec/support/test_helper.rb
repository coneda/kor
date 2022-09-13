module TestHelper
  def with_env(overrides = {})
    old = {}
    overrides.each do |k, v|
      old[k] = ENV[k]
      ENV[k] = v
    end
    yield
    old.each do |k, v|
      ENV[k] = old[k]
    end
  end
end
