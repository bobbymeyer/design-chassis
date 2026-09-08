// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// its-swiss registers its own controllers from a module its shell imports;
// this app registers nothing for it. An engine's own controllers register
// themselves the same way, from a module the engine's layout imports.
