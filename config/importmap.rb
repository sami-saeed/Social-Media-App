# Importmap: pin modules for Stimulus + Turbo + Bootstrap

pin "application"                             # your main entrypoint
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @8.0.16
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js", preload: true # @3.2.2
## Using manual controller registration; no stimulus-loading helper needed
pin "controllers", to: "controllers/index.js"
pin "controllers/application", to: "controllers/application.js"
pin "controllers/hello_controller", to: "controllers/hello_controller.js"
pin "controllers/toggle_controller", to: "controllers/toggle_controller.js"
pin "controllers/notifications_controller", to: "controllers/notifications_controller.js"
pin "controllers/mention_autocomplete_controller", to: "controllers/mention_autocomplete_controller.js"
pin "channels", to: "channels/index.js"
pin "channels/consumer", to: "channels/consumer.js"
pin "channels/notifications_channel", to: "channels/notifications_channel.js"
pin "channels/link_scraper_channel", to: "channels/link_scraper_channel.js"

# Optional if you’re using Bootstrap JS:
pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.3.7/dist/js/bootstrap.esm.js"
pin "@rails/actioncable", to: "@rails--actioncable--src.js"
pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.8/lib/index.js"
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.13
## Single pin for Action Cable is sufficient
