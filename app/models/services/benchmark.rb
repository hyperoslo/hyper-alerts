class Services::Benchmark
  include Mongoid::Document

  field :start, type: Time
  field :stop, type: Time
  field :duration, type: Float

  # An Array with arbitrary metadata describing the parameters of the benchmark.
  field :meta, type: Array

  belongs_to :benchmarkable, polymorphic: true, index: true

  before_save :set_duration, if: -> { start && stop }

  # Measure the given block.
  def measure
    self.start = Time.now

    yield

    self.stop = Time.now
  end

  # Create a new benchmark and measure the given block.
  #
  # parameters - A Hash of parameters to forward to `Benchmark.new`.
  def self.measure parameters = {}, &block
    benchmark = new parameters
    benchmark.measure &block
    benchmark.save!

    benchmark
  end

  private

  def set_duration
    self.duration = (stop - start).round 2
  end
end
