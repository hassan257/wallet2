import 'package:fluro/fluro.dart';

import '../router/route_handlers.dart';

class Flurorouter {
  static final FluroRouter router = FluroRouter();

  static void configureRoutes() {
    router.define('/',
        handler: homeHandler, transitionType: TransitionType.fadeIn);
    router.define('/home',
        handler: homeHandler, transitionType: TransitionType.fadeIn);
    router.define('/moves',
        handler: movesHandler, transitionType: TransitionType.fadeIn);
    router.define('/settings',
        handler: settingsHandler, transitionType: TransitionType.fadeIn);
    router.define('/login',
        handler: loginHandler, transitionType: TransitionType.fadeIn);
    router.define('/addmove',
        handler: addMoveHandler, transitionType: TransitionType.inFromRight);
    router.define('/account',
        handler: accountHandler, transitionType: TransitionType.inFromRight);
    router.define('/account/:i',
        handler: accountHandler, transitionType: TransitionType.inFromRight);

    // 404 - Not Page Found
    router.notFoundHandler = pageNotFound;
  }
}
