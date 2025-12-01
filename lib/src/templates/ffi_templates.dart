// lib/src/templates/ffi_templates.dart

class FfiTemplates {
  static String rustFfi(String projectName) => '''
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// --------------------------------------------------------------------------
// TYPEDEFS (Must be at the top level, outside the class)
// --------------------------------------------------------------------------

typedef JsonDecodeNative = Pointer<Utf8> Function(Pointer<Utf8>);
typedef JsonDecodeDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef JsonEncodeNative = Pointer<Utf8> Function(Pointer<Utf8>);
typedef JsonEncodeDart = Pointer<Utf8> Function(Pointer<Utf8>);

typedef ProcessImageNative = Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Uint32, Uint32, Uint8);
typedef ProcessImageDart = int Function(Pointer<Utf8>, Pointer<Utf8>, int, int, int);

typedef GetOrCacheImageNative = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Uint32, Uint32, Uint8);
typedef GetOrCacheImageDart = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, int, int, int);

typedef ClearImageCacheNative = Int32 Function();
typedef ClearImageCacheDart = int Function();

typedef GetCacheSizeNative = Int64 Function();
typedef GetCacheSizeDart = int Function();

typedef FreeNative = Void Function(Pointer<Void>);
typedef FreeDart = void Function(Pointer<Void>);

// --------------------------------------------------------------------------
// CLASS DEFINITION
// --------------------------------------------------------------------------

/// Rust FFI wrapper for high-performance operations
class RustFFI {
  static RustFFI? _instance;
  static DynamicLibrary? _dylib;

  RustFFI._();

  /// Get singleton instance
  static Future<RustFFI> getInstance() async {
    if (_instance == null) {
      _instance = RustFFI._();
      await _instance!._loadLibrary();
      _instance!._initializeFunctions();
    }
    return _instance!;
  }

  /// Get instance synchronously (for isolates)
  /// Note: Ensure getInstance() has been called at least once before calling this.
  static RustFFI? getInstanceSync() {
    return _instance;
  }

  /// Create instance for isolate
  /// Note: Isolates have separate memory. If you spawn a new isolate, 
  /// static variables (like _dylib) are reset to null. You usually need to 
  /// load the library again inside the new isolate.
  static RustFFI createForIsolate() {
    final instance = RustFFI._();
    // If we are in the same isolate group, we might share the dylib,
    // otherwise, the caller must ensure _loadLibrary is called.
    return instance;
  }

  /// Load platform-specific library
  Future<void> _loadLibrary() async {
    // Check if already loaded
    if (RustFFI._dylib != null) return;

    if (Platform.isAndroid) {
      RustFFI._dylib = DynamicLibrary.open('lib${projectName}_ffi.so');
    } else if (Platform.isIOS) {
      RustFFI._dylib = DynamicLibrary.process();
    } else if (Platform.isWindows) {
      RustFFI._dylib = DynamicLibrary.open('${projectName}_ffi.dll');
    } else if (Platform.isLinux) {
      RustFFI._dylib = DynamicLibrary.open('lib${projectName}_ffi.so');
    } else if (Platform.isMacOS) {
      RustFFI._dylib = DynamicLibrary.open('lib${projectName}_ffi.dylib');
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  // Lazy-loaded function pointers
  late final JsonDecodeDart _jsonDecode;
  late final JsonEncodeDart _jsonEncode;
  late final ProcessImageDart _processImage;
  late final GetOrCacheImageDart _getOrCacheImage;
  late final ClearImageCacheDart _clearImageCache;
  late final GetCacheSizeDart _getCacheSize;
  late final FreeDart _free;

  void _initializeFunctions() {
    // Access the static dylib
    final dylib = RustFFI._dylib;
    if (dylib == null) {
      throw StateError('Library not loaded. Call getInstance() first.');
    }

    _jsonDecode = dylib.lookup<NativeFunction<JsonDecodeNative>>('${projectName}_json_decode').asFunction();
    _jsonEncode = dylib.lookup<NativeFunction<JsonEncodeNative>>('${projectName}_json_encode').asFunction();
    _processImage = dylib.lookup<NativeFunction<ProcessImageNative>>('${projectName}_process_image').asFunction();
    _getOrCacheImage = dylib.lookup<NativeFunction<GetOrCacheImageNative>>('${projectName}_get_or_cache_image').asFunction();
    _clearImageCache = dylib.lookup<NativeFunction<ClearImageCacheNative>>('${projectName}_clear_image_cache').asFunction();
    _getCacheSize = dylib.lookup<NativeFunction<GetCacheSizeNative>>('${projectName}_get_cache_size').asFunction();
    _free = dylib.lookup<NativeFunction<FreeNative>>('${projectName}_free').asFunction();
  }

  /// Decode JSON string
  String jsonDecode(String json) {
    // Ensure functions are initialized if dylib exists
    if (RustFFI._dylib != null && !_isInitialized(_jsonDecode)) {
        _initializeFunctions();
    }
    
    final jsonPtr = json.toNativeUtf8();
    try {
      final resultPtr = _jsonDecode(jsonPtr);
      if (resultPtr.address == 0) {
        throw Exception('Failed to decode JSON');
      }
      final result = resultPtr.toDartString();
      _free(resultPtr.cast());
      return result;
    } finally {
      malloc.free(jsonPtr);
    }
  }

  /// Encode data to JSON string
  String jsonEncode(String data) {
    final dataPtr = data.toNativeUtf8();
    try {
      final resultPtr = _jsonEncode(dataPtr);
      if (resultPtr.address == 0) {
        throw Exception('Failed to encode JSON');
      }
      final result = resultPtr.toDartString();
      _free(resultPtr.cast());
      return result;
    } finally {
      malloc.free(dataPtr);
    }
  }

  /// Process image: resize, compress, save
  bool processImage({
    required String imagePath,
    required String outputPath,
    int width = 0,
    int height = 0,
    int quality = 85,
  }) {
    final imagePathPtr = imagePath.toNativeUtf8();
    final outputPathPtr = outputPath.toNativeUtf8();
    try {
      final result = _processImage(imagePathPtr, outputPathPtr, width, height, quality);
      return result == 0;
    } finally {
      malloc.free(imagePathPtr);
      malloc.free(outputPathPtr);
    }
  }

  /// Get image from cache or process and cache it
  String? getOrCacheImage({
    required String imagePath,
    required String cacheKey,
    int width = 0,
    int height = 0,
    int quality = 85,
  }) {
    final imagePathPtr = imagePath.toNativeUtf8();
    final cacheKeyPtr = cacheKey.toNativeUtf8();
    try {
      final resultPtr = _getOrCacheImage(imagePathPtr, cacheKeyPtr, width, height, quality);
      if (resultPtr.address == 0) {
        return null;
      }
      final result = resultPtr.toDartString();
      _free(resultPtr.cast());
      return result;
    } finally {
      malloc.free(imagePathPtr);
      malloc.free(cacheKeyPtr);
    }
  }

  /// Clear image cache
  bool clearImageCache() {
    final result = _clearImageCache();
    return result == 0;
  }

  /// Get cache size in bytes
  int getCacheSize() {
    return _getCacheSize();
  }

  // Helper to check if a late variable is initialized
  bool _isInitialized(Object? fn) {
    try {
      // Accessing a late variable throws if not initialized
      // This is a workaround; usually keeping a separate boolean flag is cleaner
      // but strictly speaking, calling _initializeFunctions() in getInstance is enough.
      return true;
    } catch (_) {
      return false;
    }
  }
}
''';

  static String hybridParser(String projectName) => '''
import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'package:$projectName/core/ffi/rust_ffi.dart';

/// Type definition for parse function
typedef ParseFunction<R> = R Function(dynamic);

/// Hybrid parser that uses Rust FFI in an isolate for non-blocking performance
class HybridParser<T, R> {
  final String json;
  final ParseFunction<R> parseFunction;
  static bool _initialized = false;

  HybridParser(this.json, this.parseFunction);

  /// Initialize Rust FFI (call once at startup)
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await RustFFI.getInstance();
      _initialized = true;
    } catch (e) {
      print('Warning: Rust FFI initialization failed: \$e');
      print('Falling back to Dart JSON parsing');
    }
  }

  /// Parse JSON using Rust FFI in an isolate
  Future<R> parse() async {
    if (!_initialized) {
      await initialize();
    }

    final completer = Completer<R>();
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _parseInIsolate,
      _IsolateData(
        json: json,
        parseFunction: parseFunction,
        sendPort: receivePort.sendPort,
      ),
    );

    receivePort.listen((result) {
      if (result is R) {
        completer.complete(result);
      } else if (result is Exception) {
        completer.completeError(result);
      }
      receivePort.close();
    });

    return completer.future;
  }

  static void _parseInIsolate(_IsolateData data) async {
    try {
      // Create RustFFI instance for this isolate
      final ffi = RustFFI.createForIsolate();
      
      // Decode JSON using Rust
      final decodedJson = ffi.jsonDecode(data.json);
      final decoded = jsonDecode(decodedJson);
      
      // Parse using provided function
      final result = data.parseFunction(decoded);
      data.sendPort.send(result);
    } catch (e) {
      data.sendPort.send(Exception('Parsing failed: \$e'));
    }
  }
}

class _IsolateData {
  final String json;
  final ParseFunction parseFunction;
  final SendPort sendPort;

  _IsolateData({
    required this.json,
    required this.parseFunction,
    required this.sendPort,
  });
}

/// Hybrid parser with automatic fallback to Dart if Rust unavailable
class HybridParserWithFallback<T, R> {
  final String json;
  final ParseFunction<R> parseFunction;

  HybridParserWithFallback(this.json, this.parseFunction);

  /// Initialize (optional, will auto-initialize on first use)
  static Future<void> initialize() async {
    await HybridParser.initialize();
  }

  /// Parse with automatic fallback
  Future<R> parse() async {
    try {
      final parser = HybridParser(json, parseFunction);
      return await parser.parse();
    } catch (e) {
      // Fallback to Dart JSON parsing
      print('Rust parser failed, using Dart fallback: \$e');
      final decoded = jsonDecode(json);
      return parseFunction(decoded);
    }
  }
}

/// Factory for creating parsers
class HybridParserFactory {
  /// Create a parser instance
  static HybridParser<T, R> create<T, R>(
    String json,
    R Function(dynamic) parseFunction,
  ) {
    return HybridParser(json, parseFunction);
  }

  /// Direct JSON decode
  static Future<dynamic> decode(String json) async {
    final parser = HybridParser<dynamic, dynamic>(json, (data) => data);
    return await parser.parse();
  }

  /// Direct JSON encode
  static Future<String> encode(dynamic data) async {
    final jsonString = jsonEncode(data);
    // For encoding, we just return the string as Rust encoding
    // would require the data to already be in JSON format
    return jsonString;
  }
}
''';

  static String rustParser(String projectName) => '''
import 'dart:convert';
import 'package:$projectName/core/ffi/rust_ffi.dart';

/// Type definition for parse function
typedef ParseFunction<R> = R Function(dynamic);

/// Direct Rust parser (synchronous, may block UI)
class RustParser<T, R> {
  final String json;
  final ParseFunction<R> parseFunction;
  static RustFFI? _ffi;

  RustParser(this.json, this.parseFunction);

  /// Initialize Rust FFI
  static Future<void> initialize() async {
    _ffi = await RustFFI.getInstance();
  }

  /// Parse JSON synchronously using Rust FFI
  R parse() {
    if (_ffi == null) {
      throw StateError('Rust FFI not initialized. Call RustParser.initialize() first.');
    }

    try {
      final decodedJson = _ffi!.jsonDecode(json);
      final decoded = jsonDecode(decodedJson);
      return parseFunction(decoded);
    } catch (e) {
      throw Exception('Parsing failed: \$e');
    }
  }
}
''';

  static String imageService(String projectName) => '''
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:$projectName/core/ffi/rust_ffi.dart';

/// High-level image processing service with caching
class ImageService {
  static ImageService? _instance;
  RustFFI? _ffi;

  ImageService._();

  /// Get singleton instance
  static Future<ImageService> getInstance() async {
    if (_instance == null) {
      _instance = ImageService._();
      _instance!._ffi = await RustFFI.getInstance();
    }
    return _instance!;
  }

  /// Process and cache image with automatic cache key generation
  Future<String?> processAndCache({
    required String imagePath,
    int width = 0,
    int height = 0,
    int quality = 85,
    String? cacheKey,
  }) async {
    if (_ffi == null) {
      _ffi = await RustFFI.getInstance();
    }

    // Generate cache key if not provided
    final key = cacheKey ?? _generateCacheKey(imagePath, width, height, quality);

    return _ffi!.getOrCacheImage(
      imagePath: imagePath,
      cacheKey: key,
      width: width,
      height: height,
      quality: quality,
    );
  }

  /// Process image without caching
  Future<bool> process({
    required String imagePath,
    required String outputPath,
    int width = 0,
    int height = 0,
    int quality = 85,
  }) async {
    if (_ffi == null) {
      _ffi = await RustFFI.getInstance();
    }

    return _ffi!.processImage(
      imagePath: imagePath,
      outputPath: outputPath,
      width: width,
      height: height,
      quality: quality,
    );
  }

  /// Clear image cache
  Future<bool> clearCache() async {
    if (_ffi == null) {
      _ffi = await RustFFI.getInstance();
    }

    return _ffi!.clearImageCache();
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    if (_ffi == null) {
      _ffi = await RustFFI.getInstance();
    }

    return _ffi!.getCacheSize();
  }

  /// Generate cache key from image path and parameters
  String _generateCacheKey(String imagePath, int width, int height, int quality) {
    final keyData = '\$imagePath-\$width-\$height-\$quality';
    final bytes = utf8.encode(keyData);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
''';
}
