# Importmap: pin modules for Stimulus + Turbo + Bootstrap

pin "application"                             # your main entrypoint
pin "@hotwired/turbo-rails", to: "@hotwired--turbo-rails.js" # @8.0.16
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js", preload: true # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"

# Optional if you’re using Bootstrap JS:
pin "bootstrap" # @5.3.7
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "@popperjs/core", to: "@popperjs--core.js"# @2.11.8
pin "@hotwired/turbo", to: "@hotwired--turbo.js" # @8.0.13
pin "@rails/actioncable/src", to: "@rails--actioncable--src.js" # @8.0.200
