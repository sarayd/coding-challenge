require 'test/unit'

require_relative './environment'
require_relative './rate_limiter'

class TestRateLimiter < Test::Unit::TestCase
  def setup
    @limiter = RateLimiter.new(throws: true)
    @count = 0
  end

  def test_throws
    (1..3).each do |i|
      assert_nothing_raised { run! }
      assert_equal(i, @count)
    end
    assert_raise(RateLimiter::Limited) { run! }
  end

  private

  def run!
    @limiter.limit(:expensive_foo, threshold: 3, period: 1.minute) do
      @count += 1
      sleep 1
    end
  end
end
