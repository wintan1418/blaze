import { application } from "./application"

import HelloController from "./hello_controller"
import NavController from "./nav_controller"
import RevealController from "./reveal_controller"
import CarouselController from "./carousel_controller"
import FlashController from "./flash_controller"

application.register("hello", HelloController)
application.register("nav", NavController)
application.register("reveal", RevealController)
application.register("carousel", CarouselController)
application.register("flash", FlashController)
