import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import * as bootstrap from "bootstrap"
// import "./channels/consumer"
// import "./channels/index"
// import "./channels/notifications_channel"




const application = Application.start()
eagerLoadControllersFrom("controllers", application)