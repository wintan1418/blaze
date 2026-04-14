import { application } from "./application"

import HelloController from "./hello_controller"
import NavController from "./nav_controller"
import RevealController from "./reveal_controller"
import CarouselController from "./carousel_controller"
import FlashController from "./flash_controller"
import FulfillmentController from "./fulfillment_controller"
import ChartController from "./chart_controller"
import ClipboardController from "./clipboard_controller"
import CountUpController from "./count_up_controller"
import MagneticController from "./magnetic_controller"
import ParallaxController from "./parallax_controller"
import TiltController from "./tilt_controller"
import ExplodeRevealController from "./explode_reveal_controller"
import DrawerController from "./drawer_controller"
import TextRevealController from "./text_reveal_controller"
import HorizontalScrollController from "./horizontal_scroll_controller"
import TestimonialCarouselController from "./testimonial_carousel_controller"
import ModalController from "./modal_controller"

application.register("hello", HelloController)
application.register("nav", NavController)
application.register("reveal", RevealController)
application.register("carousel", CarouselController)
application.register("flash", FlashController)
application.register("fulfillment", FulfillmentController)
application.register("chart", ChartController)
application.register("clipboard", ClipboardController)
application.register("count-up", CountUpController)
application.register("magnetic", MagneticController)
application.register("parallax", ParallaxController)
application.register("tilt", TiltController)
application.register("explode-reveal", ExplodeRevealController)
application.register("drawer", DrawerController)
application.register("text-reveal", TextRevealController)
application.register("horizontal-scroll", HorizontalScrollController)
application.register("testimonial-carousel", TestimonialCarouselController)
application.register("modal", ModalController)
