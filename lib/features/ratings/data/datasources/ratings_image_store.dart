import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Stores rating photos in the app's local documents directory so the
/// SQLite `photoPath` keeps pointing at a file the app controls.
///
/// `image_picker` returns temp-directory paths that the OS may clean up;
/// copying into `getApplicationDocumentsDirectory()` makes them durable.
class RatingsImageStore {
  static const _folderName = 'rating_images';

  Future<Directory> _folder() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(join(base.path, _folderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copies [sourcePath] into the local cache and returns the new path.
  ///
  /// Returns [sourcePath] unchanged if it already lives in the cache.
  Future<String> save(String sourcePath) async {
    final dir = await _folder();
    final ext = extension(sourcePath);
    final fileName =
        'rating_${DateTime.now().microsecondsSinceEpoch}$ext';
    final destination = join(dir.path, fileName);

    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) return sourcePath;
    if (isWithin(dir.path, sourcePath)) return sourcePath;

    await sourceFile.copy(destination);
    return destination;
  }

  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) return;
    final dir = await _folder();
    if (!isWithin(dir.path, path)) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
