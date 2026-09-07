// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// its-swiss pins its two controllers from its engine rather than writing
// pins this app would have to keep in step. They are outside controllers/,
// so they are registered by hand: eagerLoadControllersFrom only reaches
// what is pinned under that name. An engine's own controllers register
// themselves from a module the engine's layout imports.
import ItsSwissClipboardController from "its_swiss/clipboard_controller"
import ItsSwissLiveSearchController from "its_swiss/live_search_controller"
application.register("its-swiss-clipboard", ItsSwissClipboardController)
application.register("its-swiss-live-search", ItsSwissLiveSearchController)
