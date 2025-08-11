import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import * as bootstrap from "bootstrap"





const application = Application.start()
eagerLoadControllersFrom("controllers", application)
Add