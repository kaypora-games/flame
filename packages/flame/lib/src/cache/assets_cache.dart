import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetBundle;
import 'package:plato/plato.dart';

const _logr = Logr(true, prefix: 'flame.assets_cache');

/// A class that loads, and caches files.
///
/// It automatically looks for files in the `assets` directory.
class AssetsCache {
  AssetsCache({
    this.prefix = 'assets/',
    AssetBundle? bundle,
  }) : bundle = bundle ?? Flame.bundle;

  /// The [AssetBundle] from which assets are loaded.
  /// defaults to [Flame.bundle].
  AssetBundle bundle;

  /// The the byte length of cached items
  int get length => _files.values.map((a) => a.length).sum;

  @override
  String toString() => Printr.print(this,
    'items=$cacheCount',
    'length=$length'
  );

  // String? removeEldest() =>
  //     _files.removeEldest()?.key;

  String prefix;
  final Map<String, _Asset<dynamic>> _files = {};

  /// Removes the file from the cache.
  void clear(String file) {
    _files.remove(file);
  }

  /// Removes all the files from the cache.
  void clearCache() {
    _files.clear();
  }

  /// Returns the number of files in the cache.
  int get cacheCount => _files.length;

  /// Reads a file from assets folder.
  Future<String> readFile(String fileName, {String? package}) async {
    final cacheKey = package == null ? fileName : 'packages/$package/$fileName';
    var asset = _files[cacheKey];
    asset ??= _files[cacheKey] = await _readFile(cacheKey, package: package);
    return (asset as _StringAsset).value;
  }

  /// Reads a binary file from assets folder.
  Future<Uint8List> readBinaryFile(String fileName, {String? package}) async {
    final cacheKey = package == null ? fileName : 'packages/$package/$fileName';
    var asset = _files[cacheKey];
    asset ??= _files[cacheKey] = await _readBinary(cacheKey, package: package);
    return (asset as _BinaryAsset).value;
  }

  /// Reads a json file from the assets folder.
  Future<Map<String, dynamic>> readJson(String fileName, {String? package}) async {
    final cacheKey = package == null ? fileName : 'packages/$package/$fileName';
    var asset = _files[cacheKey];
    asset ??= _files[cacheKey] = await _readJson(cacheKey, package: package);
    return (asset as _JsonAsset).value;
  }

  Future<_StringAsset> _readFile(String fileName, {String? package}) async {
    final fullPrefix = package == null ? prefix : 'packages/$package/$prefix';
    final asset = _StringAsset(await bundle.loadString('$fullPrefix$fileName'));
    _logr.log(() => 'READ-FILE > $asset');
    return asset;
  }

  Future<_BinaryAsset> _readBinary(String fileName, {String? package}) async {
    final fullPrefix = package == null ? prefix : 'packages/$package/$prefix';
    final asset = _BinaryAsset(Uint8List.view((await bundle.load('$fullPrefix$fileName')).buffer));
    _logr.log(() => 'READ-BINARY > $asset');
    return asset;
  }

  Future<_JsonAsset> _readJson(String fileName, {String? package}) async {
    final fullPrefix = package == null ? prefix : 'packages/$package/$prefix';
    final asset = _JsonAsset(jsonDecode(await bundle.loadString('$fullPrefix$fileName')) as Map<String, dynamic>);
    _logr.log(() => 'READ-JSON > $asset');
    return asset;
  }

  /// This method provides synchronous access to cached assets, similar to
  /// [AssetsCache.fromCache].
  T fromCache<T>(String fileName) {
    final asset = _files[fileName];
    assert(
      asset != null,
      'Tried to access an asset "$fileName" that does not exist in the cache. '
      'Make sure to load the asset using readFile(), readBinaryFile(), or '
      'readJson() before accessing it with fromCache()',
    );
    assert(
      asset!.value is T,
      'Tried to access asset "$fileName" as type $T, but it was loaded as '
      '${asset.value.runtimeType}. Make sure to use the correct type when '
      'calling fromCache<T>()',
    );

    return asset!.value as T;
  }
}

sealed class _Asset<T> {
  int length;
  T value;
  _Asset(this.length, this.value);

  @override
  String toString() => Printr.print(this,
    '$length'
  );
}

class _StringAsset extends _Asset<String> {
  _StringAsset(String value): super(value.length, value);
}

class _BinaryAsset extends _Asset<Uint8List> {
  _BinaryAsset(Uint8List bytes): super(bytes.length, bytes);
}

class _JsonAsset extends _Asset<Map<String, dynamic>> {
  _JsonAsset(Map<String, dynamic> map): super(map.length, map);
}
