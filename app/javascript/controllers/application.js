import * as bootstrap from "bootstrap"
import { Application } from "@hotwired/stimulus"
import ToggleController from "./toggle_controller"
// import "@rails/ujs"
// import Rails from "@rails/ujs"
// Rails.start()


const application = Application.start()

// Optional: Debug mode
application.debug = false


application.register("toggle", ToggleController)


window.Stimulus = application

export { application }
