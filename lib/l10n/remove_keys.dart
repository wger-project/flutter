import 'dart:convert';
import 'dart:io';

/// Remove unused keys from .arb files
///
/// Usage: dart remove_keys.dart aboutBugsTitle aboutBugsText
void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Please provide at least one key as a parameter.');
    return;
  }

  final directory = Directory('.');
  final keysToRemove = arguments;

  // Iterate through all files in the directory that end with .arb
  for (final file in directory.listSync().where((f) => f.path.endsWith('.arb'))) {
    final content = File(file.path).readAsStringSync();
    final Map<String, dynamic> jsonContent = json.decode(content);

    var modified = false;
    for (final key in keysToRemove) {
      if (jsonContent.containsKey(key)) {
        // Remove the key
        jsonContent.remove(key);

        // Remove the metadata key (e.g., '@$key')
        jsonContent.remove('@$key');

        modified = true;
        print('Key "$key" removed from ${file.path}.');
      }
    }

    if (modified) {
      File(file.path).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(jsonContent));
    }
  }
}
