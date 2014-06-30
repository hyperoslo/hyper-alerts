require 'test_helper'

class Services::BenchmarkTest < ActiveSupport::TestCase
  test "benchmarks" do
    benchmark = Services::Benchmark.measure do
      Timecop.travel 1.second
    end

    assert_equal 1, benchmark.duration
  end
end
