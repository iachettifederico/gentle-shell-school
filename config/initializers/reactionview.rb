return unless Rails.env.development? && defined?(ReActionView)

ReActionView.configure do |config|
  config.intercept_erb = true
  config.debug_mode = true
  config.slots = true
  config.dev_server = true
end
