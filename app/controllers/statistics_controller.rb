class StatisticsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  def summary
    general_mean_synchronization_time = Services::Benchmark.where(:start.gt => 1.hour.ago).avg :duration
    general_mean_throughput           = Services::Benchmark.where(:start.gt => 1.hour.ago).count / 3600.0
    general_users                     = User.count
    general_subscriptions             = Subscription.count

    info = $redis.info

    redis_connections = info["connected_clients"]
    redis_memory      = info["used_memory"]

    sidekiq = Sidekiq::Stats.new

    workers_processed = sidekiq.processed
    workers_failed    = sidekiq.failed
    workers_enqueued  = sidekiq.enqueued
    workers_retrying  = sidekiq.retry_size

    @statistics = {
      general: {
        users: number_with_delimiter(general_users),
        subscriptions: number_with_delimiter(general_subscriptions),
        mean_synchronization_time: "#{number_with_precision(general_mean_synchronization_time, precision: 2)}s",
        mean_throughput: "#{number_with_precision(general_mean_throughput, precision: 2)} alerts/sec"
      },
      redis: {
        connections: redis_connections,
        memory: number_to_human_size(redis_memory)
      },
      workers: {
        processed: number_with_delimiter(workers_processed),
        failed: number_with_delimiter(workers_failed),
        enqueued: number_with_delimiter(workers_enqueued),
        retrying: number_with_delimiter(workers_retrying)
      }
    }

    respond_to do |format|
      format.html
      format.json { render json: @statistics }
    end
  end
end
