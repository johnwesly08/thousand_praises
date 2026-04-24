import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const String userPraiseFileName = 'praises_user.json';

Future<File> _getPraiseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File('${dir.path}/$userPraiseFileName');
}

/// Load User-added praises
Future<List<Map<String, dynamic>>> loadUserPraises() async {
  try {
    final file = await _getPraiseFile();
    if (!await file.exists()) return [];

    final content = await file.readAsString();
    final List data = jsonDecode(content);
    return List<Map<String, dynamic>>.from(data);
  } catch (e) {
    return [];
  }
}

/// Add a new praise
Future<void> addUserPraise({
  required String reference,
  required String praise,
}) async {
  final file = await _getPraiseFile();
  final existing = await loadUserPraises();

  existing.add({
    'reference': reference.trim(),
    'praise': praise.trim(),
  });

  await file.writeAsString(
    jsonEncode(existing),
    flush: true,
  );
}

//Export the User Praise

Future<void> exportUserPraises() async {
  final file = await _getPraiseFile();
  if(!await file.exists()) {
    throw Exception('No praises to export');
  }

  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Thousand Praises - JSON Export user',
  );

}