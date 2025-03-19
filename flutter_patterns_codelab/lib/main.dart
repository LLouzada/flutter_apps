import 'package:flutter/material.dart';

import 'data.dart';

void main() {
  runApp(const DocumentApp());
}

class DocumentApp extends StatelessWidget {
  const DocumentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: DocumentScreen(document: Document()),
    );
  }
}

class DocumentScreen extends StatelessWidget {
  final Document document;

  const DocumentScreen({required this.document, super.key});

  @override
  Widget build(BuildContext context) {
    // Refactor the build method of DocumentScreen to call metadata
    // and use it to initialize a pattern variable declaration.
    // shorthand for when the name of a field and the variable populating it are the same
    // The syntax of the variable pattern `:modified` is shorthand for `modified: modified`.
    //If you want a new local variable of a different name, you can write modified: localModified instead.
    final (title, :modified) = document.metadata;
    final formattedModifiedDate = formatDate(modified);
    final blocks = document.getBlocks();

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Center(child: Text('Last modified: $formattedModifiedDate')),
          Expanded(
            child: ListView.builder(
              itemCount: blocks.length,
              itemBuilder: (context, index) {
                return BlockWidget(block: blocks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BlockWidget extends StatelessWidget {
  final Block block;

  const BlockWidget({required this.block, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),

      // In your first version of BlockWidget, you switched on a field of a Block object to return a TextStyle.
      // Now, you switch an instance of the Block object itself and match against object patterns that represent its subclasses, extracting the object's properties in the process.
      // The Dart analyzer can check that each subclass is handled in the switch expression because you made Block a sealed class.
      // Try removing one of the subclass cases from the switch expression and see the error kick in
      child: switch (block) {
        HeaderBlock(:final text) => Text(
          text,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        ParagraphBlock(:final text) => Text(text),
        CheckboxBlock(:final text, :final isChecked) => Row(
          children: [Checkbox(value: isChecked, onChanged: (_) {}), Text(text)],
        ),
      },
    );
  }
}

String formatDate(DateTime dateTime) {
  final today = DateTime.now();
  final difference = dateTime.difference(today);

  // switch expression
  //
  // When every case in a switch is handled, it's called an exhaustive switch.
  // For example, switching on a bool type is exhaustive when it has cases for true and false.
  // Switching on an enum type is exhaustive when there are cases for each of the enum's values, too, because enums represent a fixed number of constant values.
  return switch (difference) {
    Duration(inDays: 0) => 'today',
    Duration(inDays: 1) => 'tomorrow',
    Duration(inDays: -1) => 'yesterday',
    // Guard clauses (`when` keyword after a case pattern)
    // can be used in if-cases, switch statements, and switch expressions.
    Duration(inDays: final days) when days > 7 => '${days ~/ 7} weeks from now',
    Duration(inDays: final days) when days < -7 =>
      '${days.abs() ~/ 7} weeks ago',
    Duration(inDays: final days, isNegative: true) => '${days.abs()} days ago',
    Duration(inDays: final days) => '$days days from now',
  };
}
