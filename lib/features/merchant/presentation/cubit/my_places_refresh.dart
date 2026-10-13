import 'package:flutter/foundation.dart';

/// Bump `myPlacesRefresh.value++` to ask MyPlacesCubit to reload silently.
final ValueNotifier<int> myPlacesRefresh = ValueNotifier<int>(0);
