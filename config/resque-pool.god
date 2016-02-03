rails_env = ENV['RAILS_ENV'] || 'production'
rails_root = File.expand_path(File.join(File.dirname(__FILE__),'..'))

God.watch do |w|
  w.dir      = "#{rails_root}"
  w.name     = "resque-pool"
  w.group    = 'resque'
  w.env      = { "RAILS_ENV" => rails_env }
  w.start    = "bundle exec resque-pool"
  w.keepalive
end

God.watch do |w|
  w.dir      = "#{rails_root}"
  w.name     = "resque-scheduler"
  w.group    = 'resque'
  w.env      = { "RAILS_ENV" => rails_env }
  w.start    = "bundle exec resque-scheduler"
  w.keepalive
end