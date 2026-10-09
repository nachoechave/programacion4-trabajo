Rails.application.config.active_storage.content_types_to_serve_as_binary += %w[application/pdf]
Rails.application.config.active_storage.content_types_allowed_inline -= %w[image/svg+xml]
