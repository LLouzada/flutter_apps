import 'dart:convert';

class Document {
  final Map<String, Object?> _json;
  Document() : _json = jsonDecode(documentJson);

  /// The `metadata` getter method returns a `record`, which is assigned to the local variable `metadataRecord`.
  /// `Records` are a light and easy way to return multiple values from a single function call and assign them to a variable.
  ///
  // (String, {DateTime modified}) get metadata {
  //   const title = 'My Document';
  //   final now = DateTime.now();

  //   return (title, modified: now);
  // }

  /// The variable declaration pattern you used in the last step is an `irrefutable pattern`: the value must match the pattern or it's an error and destructuring won't happen.
  /// Think of any variable declaration or assignment; you can't assign a value to a variable if they're not the same type.
  /// Refutable patterns, on the other hand, are used in control flow contexts:
  /// - They expect that some values they compare against will not match.
  /// - They are meant to influence the control flow, based on whether or not the value matches.
  /// - They don't interrupt execution with an error if they don't match, they just move to the next statement.
  /// - They can destructure and bind variables that are only usable when they match
  ///
  /// **Read JSON values without patterns**
  ///
  /// This code validates that the data is structured correctly without using patterns.
  /// In a later step, you use pattern matching to perform the same validation using less code
  ///  It performs three checks before doing anything else:
  /// - The JSON contains the data structure you expect: if (_json.containsKey('metadata'))
  /// - The data has the type you expect: if (metadataJson is Map)
  /// - That the data is not null, which is implicitly confirmed in the previous check.
  ///
  // (String, {DateTime modified}) get metadata {
  //   if (_json.containsKey('metadata')) {
  //     final metadataJson = _json['metadata'];
  //     if (metadataJson is Map) {
  //       final title = metadataJson['title'] as String;
  //       final localModified = DateTime.parse(
  //         metadataJson['modified'] as String,
  //       );
  //       return (title, modified: localModified);
  //     }
  //   }
  //   throw const FormatException('Unexpected JSON');

  /// **Read JSON values using a map pattern**
  /// With a refutable pattern, you can verify that the JSON has the expected structure using a map pattern
  ///
  /// Here, you see a new kind of if-statement (introduced in Dart 3), the if-case.
  /// The case body only executes if the case pattern matches the data in _json
  ///
  /// This match accomplishes the same checks you wrote in the first version of metadata to validate the incoming JSON.
  /// This code validates the following:
  /// - _json is a Map type.
  /// - _json contains a metadata key.
  /// - _json is not null.
  /// - _json['metadata'] is also a Map type.
  /// - _json['metadata'] contains the keys title and modified.
  /// - title and localModified are strings and aren't null.
  ///
  /// If the value doesn't match, the pattern refutes (refuses to continue execution) and proceeds to the else clause.
  /// If the match is successful, the pattern destructures the values of title and modified from the map and binds them to new local variables.
  (String, {DateTime modified}) get metadata {
    if (_json case {
      'metadata': {'title': String title, 'modified': String localModified},
    }) {
      return (title, modified: DateTime.parse(localModified));
    } else {
      throw const FormatException('Unexpected JSON');
    }
  }

  /// The getBlocks() function returns a list of Block objects, which you use later to build the UI.
  /// A familiar if-case statement performs validation and casts the value of the blocks metadata into a new List named blocksJson
  /// (without patterns, you'd need the toList() method to cast).
  ///
  /// The list literal contains a `collection for` in order to fill the new list with Block objects.
  List<Block> getBlocks() {
    if (_json case {'blocks': List blocksJson}) {
      return [for (final blockJson in blocksJson) Block.fromJson(blockJson)];
    } else {
      throw const FormatException('Unexpected JSON format');
    }
  }
}

const documentJson = '''
{
  "metadata": {
    "title": "My Document",
    "modified": "2023-05-10"
  },
  "blocks": [
    {
      "type": "h1",
      "text": "Chapter 1"
    },
    {
      "type": "p",
      "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
    },
    {
      "type": "checkbox",
      "checked": false,
      "text": "Learn Dart 3"
    }
  ]
}
''';

/// The sealed keyword is a class modifier that means you can only extend or implement this class in the same library.
/// Since the analyzer knows the subtypes of this class, it reports an error if a switch fails to cover one of them and isn't exhaustive.
sealed class Block {
  Block();

  // The factory constructor `fromJson()` uses the same if-case with a map pattern that you've seen before.
  // Notice that the json matches the map pattern, even though one of the keys, checked, is not accounted for in the pattern.
  // Map patterns ignore any entries in the map object that aren't explicitly accounted for in the pattern.
  factory Block.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {'type': 'h1', 'text': String text} => HeaderBlock(text),
      {'type': 'p', 'text': String text} => ParagraphBlock(text),
      {'type': 'checkbox', 'text': String text, 'checked': bool checked} =>
        CheckboxBlock(text, checked),
      _ => throw const FormatException('Unexpected JSON format'),
    };
  }
}

class HeaderBlock extends Block {
  @override
  final String text;
  HeaderBlock(this.text);
}

class ParagraphBlock extends Block {
  @override
  final String text;
  ParagraphBlock(this.text);
}

class CheckboxBlock extends Block {
  @override
  final String text;
  final bool isChecked;
  CheckboxBlock(this.text, this.isChecked);
}
