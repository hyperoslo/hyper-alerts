# Hyper Alerts

Hyper Alerts notifies people whenever someone posts to Facebook or Twitter.

## Disclaimer

Hyper Alerts uses Facebook Query Language (FQL), which is no longer supported for new applications. Pending
a rewrite of the Facebook adapter, you cannot use Hyper Alerts to get alerts for activity on Facebook.

## Installation

Hyper Alerts requires [Ruby](https://www.ruby-lang.org/en/), [MongoDB](http://www.mongodb.org/) and [Redis](http://redis.io/) to
run. You should also have a good understanding of [Ruby on Rails](http://rubyonrails.org/).

### Workers

Hyper Alerts uses workers to synchronize with Facebook and Twitter. We use [Sidekiq](http://sidekiq.org/) because it's threaded
and that really works out when you're waiting for I/O. In fact, we wait so much that we've been running 50 threads per process.

    # Start a worker to process jobs in the queue
    $ sidekiq --concurrency 50

### Schedulers

Most of Hyper Alerts' jobs need to happen automatically, like synchronizing pages or dispatching notifications. These jobs
are enqueued by schedulers, which continously poll the database for changes and schedule jobs that are due.

    # Schedule subscriptions that are due for notifications
    $ rake subscriptions:dispatch

    # Schedule Facebook pages that are due for synchronization
    $ rake facebook:synchronize

## Configuration

Hyper Alerts is configured from its `.env` file. You'll find a sample in the repository, but you will have to populate it
with your own credentials.

## Development

If you want to run Hyper Alerts on your local computer, you will need to alias "hyperalerts.dev" to localhost in
`etc/hosts` and allow it in your Facebook application so you can log in.

    # /etc/hosts
    127.0.0.1 hyperalerts.dev

## Credits

Hyper made this. We're a digital communications agency with a passion for good code, and if you're using this we probably want to hire you.

## License

Hyper Alerts is available under the MIT license. See the LICENSE file for more info.
