import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Following the "Your first Flutter app" codelab: https://codelabs.developers.google.com/codelabs/flutter-codelab-first

void main() {
  runApp(MyApp());
}

/// The code in [MyApp] sets up the whole app.
///
/// It creates the app-wide state (more on this later), names the app,
/// defines the visual theme, and sets the "home" widget—the starting point of your app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        ),
        home: MyNewHomePage(),
      ),
    );
  }
}

/// One of the possible ways to manage state in a Flutter app is to use the
/// [ChangeNotifier] class.
///
/// This class extends the [ChangeNotifier] class, which means that it can notify
/// others about its own changes. For example, if the current word pair changes, some widgets in the app need to know.
/// The state is created and provided to the whole app using a [ChangeNotifierProvider]
/// (see code above in [MyApp]). This allows any widget in the app to get hold of the state.
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  /// The getNext() method reassigns current with a new random WordPair.
  /// It also calls notifyListeners() (a method of [ChangeNotifier]) that ensures that anyone watching [MyAppState] is notified.
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  /// A new property to MyAppState called favorites. This property is initialized with an empty list: []
  /// Then, specified that the list can only ever contain word pairs: [<WordPair>[]], using generics.
  /// This helps make your app more robust — Dart refuses to even run your app if you try to add anything other than WordPair to it.
  /// In turn, you can use the favorites list knowing that there can never be any unwanted objects (like null) hiding in there.
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

/// The [MyHomePage] widget is the starting point of the app.
///
/// Every widget defines a build() method that's automatically called every time the widget's circumstances change so that the widget is always up to date.
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // [MyHomePage] tracks changes to the app's current state using the watch method.
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    // Every build method must return a widget or (more typically) a nested tree of widgets.
    // In this case, the top-level widget is [Scaffold]. You aren't going to work with Scaffold in this codelab,
    // but it's a helpful widget and is found in the vast majority of real-world Flutter apps.
    return Scaffold(
      // [Column] is one of the most basic layout widgets in Flutter.
      // It takes any number of children and puts them in a column from top to bottom.
      // By default, the column visually places its children at the top.
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // This [Text] widget takes appState, and accesses the only member of that class, current (which is a [WordPair]).
            // [WordPair] provides several helpful getters, such as asPascalCase or asSnakeCase. Here, we use asLowerCase
            BigCard(pair: pair),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Calls the toggleFavorite method on the appState object.
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text('Like'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Calls the getNext method on the appState object.
                    appState.getNext();
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ], // Notice how Flutter code makes heavy use of trailing commas.
          // This particular comma doesn't need to be here, because children is the last (and also only) member of this particular Column parameter list.
          // Yet it is generally a good idea to use trailing commas: they make adding more members trivial, and they also serve as a hint for Dart's
          // auto-formatter to put a newline there.
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // By using theme.textTheme, you access the app's font theme.
    // This class includes members such as bodyMedium (for standard text of medium size), caption (for captions of images), or headlineLarge (for large headlines).
    // The displayMedium property is a large style meant for display text. The word display is used in the typographic sense here, such as in display typeface.
    // The documentation for displayMedium says that "display styles are reserved for short, important text"—exactly our use case
    // Calling copyWith() on displayMedium returns a copy of the text style with the changes you define. In this case, you're only changing the text's color.
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      // First, the code requests the app's current theme with Theme.of(context)
      // Then, the code defines the card's color to be the same as the theme's colorScheme property.
      // The color scheme contains many colors, and primary is the most prominent, defining color of the app.
      color: theme.colorScheme.primary,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          // for accessibility.
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

/// First, notice that the entire contents of [MyNewHomePage] is extracted into a new widget, [GeneratorPage].
/// The only part of the old MyHomePage widget that didn't get extracted is Scaffold.
///
/// The new [MyHomePage] contains a [Row] with two children. The first widget is [SafeArea], and the second is an [Expanded] widget.
///
/// [MyNewHomePage] is a [StatefulWidget], meaning that it has a state of its own.
class MyNewHomePage extends StatefulWidget {
  @override
  State<MyNewHomePage> createState() => _MyNewHomePageState();
}

/// The [State] class for [MyNewHomePage].
///
/// This class extends State, and can therefore manage its own values. (It can change itself.)
///  Also notice that the build method from the old, stateless widget has moved to the [_MyHomePageState] (instead of staying in the widget).
/// It was moved verbatim—nothing inside the build method changed. It now merely lives somewhere else
///
/// The underscore (_) at the start of _MyHomePageState makes that class private and is enforced by the compiler.
class _MyNewHomePageState extends State<MyNewHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    // LayoutBuilder's builder callback is called every time the constraints change. This happens when, for example:
    // - The user resizes the app's window
    // - The user rotates their phone from portrait mode to landscape mode, or back
    // - Some widget next to MyHomePage grows in size, making MyHomePage's constraints smaller, etc
    // Now your code can decide whether to show the label by querying the current constraints
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              // The [SafeArea] ensures that its child is not obscured by a hardware notch or a status bar.
              // In this app, the widget wraps around [NavigationRail] to prevent the navigation buttons from being obscured by a mobile status bar, for example.
              SafeArea(
                // The navigation rail has two destinations (Home and Favorites), with their respective icons and labels. It also defines the current selectedIndex.
                // A selected index of zero selects the first destination, a selected index of one selects the second destination, and so on. For now, it's hard coded to zero.
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                      // Introduce a new variable, selectedIndex, and initialize it to 0.
                      // Use this new variable in the NavigationRail definition instead of the hard-coded 0 that was there until now.
                      // When the onDestinationSelected callback is called, instead of merely printing the new value to console,
                      //you assign it to selectedIndex inside a setState() call.
                      //This call is similar to the notifyListeners() method used previously—it makes sure that the UI updates.
                    });
                  },
                ),
              ),
              //  Expanded widgets are extremely useful in rows and columns—they let you express layouts
              // where some children take only as much space as they need ([SafeArea], in this case) and
              // other widgets should take as much of the remaining room as possible ([Expanded], in this case).
              // One way to think about [Expanded] widgets is that they are "greedy".
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
            onTap: () => {appState.removeFavorite(pair)},
          ),
      ],
    );
  }
}
