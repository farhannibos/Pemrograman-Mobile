import 'package:get/get.dart';

import '/app/modules/home/views/home_view.dart';
import '/app/modules/home/bindings/home_binding.dart';

// Import events module
import '/app/modules/events/views/event_view.dart';
import '/app/modules/events/bindings/event_binding.dart';

import 'app_routes.dart';

abstract class _Paths {
  static const HOME = Routes.HOME;
  static const EVENTS = Routes.EVENTS;
}

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      // Tambahkan rute ini
      name: _Paths.EVENTS,
      page: () => const EventView(),
      binding: EventBinding(),
    ),
  ];
}