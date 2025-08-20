import { application } from "controllers/application"

import HelloController from "controllers/hello_controller"
import ToggleController from "controllers/toggle_controller"
import NotificationsController from "controllers/notifications_controller"
import MentionAutocompleteController from "controllers/mention_autocomplete_controller"

application.register("hello", HelloController)
application.register("toggle", ToggleController)
application.register("notifications", NotificationsController)
application.register("mention-autocomplete", MentionAutocompleteController)
