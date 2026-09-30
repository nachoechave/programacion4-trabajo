require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Nginx termina HTTPS y reenvia la peticion a Puma.
  config.assume_ssl = true
  config.force_ssl = true

  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false
  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]

  # En el servidor se configura APP_HOST con el subdominio temporal.
  # Ejemplo: digitalcustody.midominio.com
  if ENV["APP_HOST"].present?
    config.hosts << ENV["APP_HOST"]
  end

  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
