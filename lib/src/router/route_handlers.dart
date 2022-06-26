import 'package:fluro/fluro.dart';
import 'package:wallet2/src/views/views.dart';

// Handlers

final homeHandler = Handler(handlerFunc: (context, params) {
  return const HomeView();
});

final movesHandler = Handler(handlerFunc: (context, params) {
  return const MovesView();
});

final settingsHandler = Handler(handlerFunc: (context, params) {
  return const SettingsView();
});

final loginHandler = Handler(handlerFunc: (context, params) {
  return const LoginView();
});

final addMoveHandler = Handler(handlerFunc: (context, params) {
  return const AddMoveView();
});

final accountHandler = Handler(handlerFunc: (context, params) {
  return AccountView(
    account: params['i']?[0],
  );
});

// 404
final pageNotFound = Handler(handlerFunc: (_, __) => const NotFoundView());
