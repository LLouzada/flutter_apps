// The application uses a feature-driven directory structure.
// This project structure enables us to scale the project by having self-contained
// features. In this example we will only have a single feature (the counter itself)
// but in more complex applications we can have hundreds of different features.

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_counter/app.dart';
import 'package:flutter_bloc_counter/counter_observer.dart';

// We’re initializing the `CounterObserver` we just created and calling runApp with the `CounterApp`
void main() {
  Bloc.observer = const CounterObserver();
  runApp(const CounterApp());
}
