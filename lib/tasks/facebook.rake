namespace :facebook do

  desc "Schedule pages for synchronization"
  task :synchronize => :environment do
    loop do

      Services::Facebook::Page.each do |page|
        if page.due?
          puts "Scheduling #{page}..." if verbose == true
          page.schedule
        end
      end

    end
  end

  namespace :access_tokens do

    desc "Remind users whose access tokens are about to expire to renew them"
    task :remind => :environment do
      access_token_reminder_offset = HyperAlerts::Application.config.access_token_reminder_offset

      loop do

        Services::Facebook::AccessToken.each do |token|
          unless token.reminded?
            token.remind if token.expires? and token.expires_in < access_token_reminder_offset
          end
        end

      end
    end

  end

end
