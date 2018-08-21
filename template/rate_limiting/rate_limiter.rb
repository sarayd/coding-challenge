require_relative './environment'

class RateLimiter
  class Limited < StandardError; end

  def initialize(throws:)
  end

  def limit(name, threshold:, period:)
  end
end
