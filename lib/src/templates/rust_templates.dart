// lib/src/templates/rust_templates.dart

class RustTemplates {
  static String cargoToml(String projectName) => '''[package]
name = "${projectName}_ffi"
version = "0.1.0"
edition = "2021"

[lib]
name = "${projectName}_ffi"
crate-type = ["cdylib", "staticlib"]

[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
image = "0.25"
anyhow = "1.0"
thiserror = "1.0"
once_cell = "1.19"

[target.'cfg(not(target_os = "android"))'.dependencies]
dirs = "5.0"

[target.'cfg(target_os = "android")'.dependencies]
jni = "0.21"

[build-dependencies]
cbindgen = "0.26"
''';

  static String buildSh(String projectName) {
    final libName = '${projectName}_ffi';
    return r'''#!/bin/bash
# Build script for Rust FFI library

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building Rust FFI library...${NC}"

# Detect platform
PLATFORM="unknown"
case "$(uname -s)" in
    Linux*)     PLATFORM="linux";;
    Darwin*)    PLATFORM="macos";;
    MINGW*)     PLATFORM="windows";;
    MSYS*)      PLATFORM="windows";;
esac

echo -e "${YELLOW}Detected platform: $PLATFORM${NC}"

# Build for current platform
cargo build --release

echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${YELLOW}Library location: target/release/${NC}"

# Copy to appropriate Flutter directories based on platform
if [ "$PLATFORM" = "linux" ]; then
    echo -e "${YELLOW}Linux library: target/release/lib''' +
        libName +
        r'''.so${NC}"
elif [ "$PLATFORM" = "macos" ]; then
    echo -e "${YELLOW}macOS library: target/release/lib''' +
        libName +
        r'''.dylib${NC}"
elif [ "$PLATFORM" = "windows" ]; then
    echo -e "${YELLOW}Windows library: target/release/''' +
        libName +
        r'''.dll${NC}"
fi
'''
            .replaceAll('\$libName', libName);
  }

  static String buildBat(String projectName) => '''@echo off
REM Build script for Rust FFI library on Windows

echo Building Rust FFI library...

cargo build --release

if %ERRORLEVEL% EQU 0 (
    echo Build completed successfully!
    echo Library location: target\\release\\${projectName}_ffi.dll
) else (
    echo Build failed!
    exit /b %ERRORLEVEL%
)
''';

  static const String makefile =
      '''.PHONY: build clean test android ios linux windows macos

# Build for current platform
build:
\tcargo build --release

# Clean build artifacts
clean:
\tcargo clean

# Run tests
test:
\tcargo test

# Android builds
android:
\tcargo build --target aarch64-linux-android --release
\tcargo build --target armv7-linux-androideabi --release
\tcargo build --target i686-linux-android --release
\tcargo build --target x86_64-linux-android --release

# iOS builds
ios:
\tcargo build --target aarch64-apple-ios --release
\tcargo build --target x86_64-apple-ios --release

# Linux build
linux:
\tcargo build --target x86_64-unknown-linux-gnu --release

# Windows build
windows:
\tcargo build --target x86_64-pc-windows-msvc --release

# macOS builds
macos:
\tcargo build --target x86_64-apple-darwin --release
\tcargo build --target aarch64-apple-darwin --release
''';

  static const String gitignore = '''# Rust build artifacts
/target/
**/*.rs.bk
Cargo.lock

# IDE
.idea/
.vscode/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db
''';

  static const String libRs = '''// Main library entry point
mod ffi;
mod image_processing;
mod json_processing;
mod cache;

pub use ffi::*;
pub use image_processing::*;
pub use json_processing::*;
pub use cache::*;
''';

  static String ffiRs(String projectName) =>
      '''// FFI bindings for Flutter/Dart interop
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_void};
use std::ptr;
use crate::image_processing::*;
use crate::json_processing::*;
use crate::cache::*;

// Helper macro to convert C string to Rust string
macro_rules! c_str_to_string {
    (\$ptr:expr) => {
        unsafe {
            CStr::from_ptr(\$ptr)
                .to_str()
                .map_err(|e| anyhow::anyhow!("Invalid UTF-8 string: {}", e))?
        }
    };
}

// Helper macro to create C string from Rust string
macro_rules! string_to_c_str {
    (\$str:expr) => {
        CString::new(\$str).map_err(|e| anyhow::anyhow!("Failed to create C string: {}", e))?.into_raw()
    };
}

/// Free memory allocated by Rust
#[no_mangle]
pub extern "C" fn ${projectName}_free(ptr: *mut c_void) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr as *mut c_char);
        }
    }
}

// ============================================================================
// JSON Processing FFI
// ============================================================================

/// Parse JSON string to Rust-processed format
/// Returns a pointer to a C string with the result, or null on error
#[no_mangle]
pub extern "C" fn ${projectName}_json_decode(json_ptr: *const c_char) -> *mut c_char {
    let json_str = match unsafe { CStr::from_ptr(json_ptr).to_str() } {
        Ok(s) => s,
        Err(_) => return ptr::null_mut(),
    };

    match json_decode(json_str) {
        Ok(result) => {
            match CString::new(result) {
                Ok(c_str) => c_str.into_raw(),
                Err(_) => ptr::null_mut(),
            }
        }
        Err(_) => ptr::null_mut(),
    }
}

/// Encode data to JSON string
/// Returns a pointer to a C string with the result, or null on error
#[no_mangle]
pub extern "C" fn ${projectName}_json_encode(data_ptr: *const c_char) -> *mut c_char {
    let data_str = match unsafe { CStr::from_ptr(data_ptr).to_str() } {
        Ok(s) => s,
        Err(_) => return ptr::null_mut(),
    };

    match json_encode(data_str) {
        Ok(result) => {
            match CString::new(result) {
                Ok(c_str) => c_str.into_raw(),
                Err(_) => ptr::null_mut(),
            }
        }
        Err(_) => ptr::null_mut(),
    }
}

// ============================================================================
// Image Processing FFI
// ============================================================================

/// Process image: resize, compress, and cache
/// Parameters:
/// - image_path: Path to the input image
/// - output_path: Path where processed image should be saved
/// - width: Target width (0 to maintain aspect ratio)
/// - height: Target height (0 to maintain aspect ratio)
/// - quality: JPEG quality (0-100, ignored for PNG)
/// Returns: 0 on success, -1 on error
#[no_mangle]
pub extern "C" fn ${projectName}_process_image(
    image_path: *const c_char,
    output_path: *const c_char,
    width: u32,
    height: u32,
    quality: u8,
) -> i32 {
    let img_path = match unsafe { CStr::from_ptr(image_path).to_str() } {
        Ok(s) => s,
        Err(_) => return -1,
    };

    let out_path = match unsafe { CStr::from_ptr(output_path).to_str() } {
        Ok(s) => s,
        Err(_) => return -1,
    };

    match process_image(img_path, out_path, width, height, quality) {
        Ok(_) => 0,
        Err(_) => -1,
    }
}

/// Get image from cache or process and cache it
/// Parameters:
/// - image_path: Path to the input image
/// - cache_key: Unique key for caching
/// - width: Target width (0 to maintain aspect ratio)
/// - height: Target height (0 to maintain aspect ratio)
/// - quality: JPEG quality (0-100)
/// Returns: Pointer to C string with cached path, or null on error
#[no_mangle]
pub extern "C" fn ${projectName}_get_or_cache_image(
    image_path: *const c_char,
    cache_key: *const c_char,
    width: u32,
    height: u32,
    quality: u8,
) -> *mut c_char {
    let img_path = match unsafe { CStr::from_ptr(image_path).to_str() } {
        Ok(s) => s,
        Err(_) => return ptr::null_mut(),
    };

    let key = match unsafe { CStr::from_ptr(cache_key).to_str() } {
        Ok(s) => s,
        Err(_) => return ptr::null_mut(),
    };

    match get_or_cache_image(img_path, key, width, height, quality) {
        Ok(cached_path) => {
            match CString::new(cached_path) {
                Ok(c_str) => c_str.into_raw(),
                Err(_) => ptr::null_mut(),
            }
        }
        Err(_) => ptr::null_mut(),
    }
}

/// Clear image cache
/// Returns: 0 on success, -1 on error
#[no_mangle]
pub extern "C" fn ${projectName}_clear_image_cache() -> i32 {
    match clear_image_cache() {
        Ok(_) => 0,
        Err(_) => -1,
    }
}

/// Get cache size in bytes
/// Returns: Cache size, or -1 on error
#[no_mangle]
pub extern "C" fn ${projectName}_get_cache_size() -> i64 {
    get_cache_size().unwrap_or(-1)
}
''';

  static const String jsonProcessingRs = '''// Fast JSON processing module
use serde_json::{Value, from_str, to_string};
use anyhow::{Result, Context};

/// Decode JSON string with optimized parsing
pub fn json_decode(json_str: &str) -> Result<String> {
    // Parse JSON using serde_json for maximum performance
    let value: Value = from_str(json_str)
        .context("Failed to parse JSON string")?;
    
    // Return prettified JSON for better readability (can be optimized further)
    // For maximum performance, you might want to return the Value directly
    // but we're returning string for FFI compatibility
    to_string(&value)
        .context("Failed to serialize JSON value")
}

/// Encode data structure to JSON string
pub fn json_encode(data_str: &str) -> Result<String> {
    // Parse the input as JSON and re-serialize it
    // This ensures proper JSON formatting
    let value: Value = from_str(data_str)
        .context("Failed to parse input data")?;
    
    to_string(&value)
        .context("Failed to encode to JSON")
}

/// Optimized JSON parsing with validation
pub fn json_validate(json_str: &str) -> Result<bool> {
    from_str::<Value>(json_str)
        .map(|_| true)
        .map_err(|_| anyhow::anyhow!("Invalid JSON"))
}

/// Extract specific field from JSON (optimized path extraction)
pub fn json_extract_field(json_str: &str, field_path: &str) -> Result<String> {
    let value: Value = from_str(json_str)
        .context("Failed to parse JSON")?;
    
    // Support dot notation paths like "user.profile.name"
    let mut current = &value;
    for segment in field_path.split('.') {
        current = current.get(segment)
            .ok_or_else(|| anyhow::anyhow!("Field '{}' not found", segment))?;
    }
    
    serde_json::to_string(current)
        .context("Failed to serialize extracted field")
}

/// Merge multiple JSON objects
pub fn json_merge(json_strs: &[&str]) -> Result<String> {
    let mut merged = serde_json::Map::new();
    
    for json_str in json_strs {
        let value: Value = from_str(json_str)?;
        if let Value::Object(map) = value {
            for (k, v) in map {
                merged.insert(k, v);
            }
        }
    }
    
    to_string(&Value::Object(merged))
        .context("Failed to merge JSON objects")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_json_decode() {
        let json = r#"{"name":"test","value":42}"#;
        let result = json_decode(json).unwrap();
        assert!(result.contains("test"));
    }

    #[test]
    fn test_json_extract_field() {
        let json = r#"{"user":{"profile":{"name":"John"}}}"#;
        let result = json_extract_field(json, "user.profile.name").unwrap();
        assert_eq!(result, r#""John""#);
    }
}
''';

  static const String imageProcessingRs =
      '''// Image processing and caching module
use image::{DynamicImage, ImageFormat};
use std::path::{Path, PathBuf};
use std::fs;
use anyhow::{Result, Context};
use crate::cache::*;

/// Process image: resize, compress, and save
pub fn process_image(
    image_path: &str,
    output_path: &str,
    width: u32,
    height: u32,
    quality: u8,
) -> Result<()> {
    // Load image
    let img = image::open(image_path)
        .context(format!("Failed to open image: {}", image_path))?;

    // Resize image if dimensions are specified
    let resized = if width > 0 || height > 0 {
        if width > 0 && height > 0 {
            img.resize_exact(width, height, image::imageops::FilterType::Lanczos3)
        } else if width > 0 {
            let ratio = width as f32 / img.width() as f32;
            let new_height = (img.height() as f32 * ratio) as u32;
            img.resize(width, new_height, image::imageops::FilterType::Lanczos3)
        } else {
            let ratio = height as f32 / img.height() as f32;
            let new_width = (img.width() as f32 * ratio) as u32;
            img.resize(new_width, height, image::imageops::FilterType::Lanczos3)
        }
    } else {
        img
    };

    // Determine output format from file extension
    let format = match Path::new(output_path)
        .extension()
        .and_then(|e| e.to_str())
        .map(|e| e.to_lowercase())
        .as_deref()
    {
        Some("png") => ImageFormat::Png,
        Some("jpg") | Some("jpeg") => ImageFormat::Jpeg,
        Some("webp") => ImageFormat::WebP,
        _ => ImageFormat::Jpeg, // Default to JPEG
    };

    // Save with appropriate quality
    match format {
        ImageFormat::Jpeg => {
            let mut output_file = fs::File::create(output_path)
                .context("Failed to create output file")?;
            resized.write_to(&mut output_file, ImageFormat::Jpeg)
                .context("Failed to write JPEG")?;
        }
        ImageFormat::Png => {
            let mut output_file = fs::File::create(output_path)
                .context("Failed to create output file")?;
            resized.write_to(&mut output_file, ImageFormat::Png)
                .context("Failed to write PNG")?;
        }
        ImageFormat::WebP => {
            let mut output_file = fs::File::create(output_path)
                .context("Failed to create output file")?;
            resized.write_to(&mut output_file, ImageFormat::WebP)
                .context("Failed to write WebP")?;
        }
        _ => {
            let mut output_file = fs::File::create(output_path)
                .context("Failed to create output file")?;
            resized.write_to(&mut output_file, format)
                .context("Failed to write image")?;
        }
    }

    Ok(())
}

/// Get image from cache or process and cache it
pub fn get_or_cache_image(
    image_path: &str,
    cache_key: &str,
    width: u32,
    height: u32,
    quality: u8,
) -> Result<String> {
    // Check cache first
    if let Some(cached_path) = get_cached_image_path(cache_key) {
        if Path::new(&cached_path).exists() {
            return Ok(cached_path);
        }
    }

    // Process and cache the image
    let cache_dir = get_cache_directory()?;
    let extension = Path::new(image_path)
        .extension()
        .and_then(|e| e.to_str())
        .unwrap_or("jpg");
    
    let cached_filename = format!("{}.{}", cache_key, extension);
    let cached_path = cache_dir.join(cached_filename);
    
    process_image(
        image_path,
        cached_path.to_str().unwrap(),
        width,
        height,
        quality,
    )?;

    // Store cache entry
    cache_image_path(cache_key, cached_path.to_str().unwrap())?;

    Ok(cached_path.to_string_lossy().to_string())
}

/// Get cached image path if it exists
fn get_cached_image_path(cache_key: &str) -> Option<String> {
    get_cache_entry(cache_key)
}
''';

  static String cacheRs(String projectName) =>
      '''// Image cache management module
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::fs;
use anyhow::{Result, Context};
use once_cell::sync::Lazy;
use std::sync::Mutex;

// In-memory cache for image paths
static IMAGE_CACHE: Lazy<Mutex<HashMap<String, String>>> = Lazy::new(|| {
    Mutex::new(HashMap::new())
});

/// Get cache directory path (platform-specific)
pub fn get_cache_directory() -> Result<PathBuf> {
    // For Flutter, this should be passed from Dart side
    // For now, we'll use a default location
    #[cfg(target_os = "android")]
    {
        // Android cache directory
        let cache_dir = PathBuf::from("/data/data/your.package.name/cache/images");
        fs::create_dir_all(&cache_dir)?;
        Ok(cache_dir)
    }
    
    #[cfg(target_os = "ios")]
    {
        // iOS cache directory
        let cache_dir = PathBuf::from("/tmp/${projectName}_cache/images");
        fs::create_dir_all(&cache_dir)?;
        Ok(cache_dir)
    }
    
    #[cfg(target_os = "windows")]
    {
        let cache_dir = if let Some(cache) = dirs::cache_dir() {
            cache.join("$projectName").join("images")
        } else {
            PathBuf::from("C:\\\\tmp\\\\${projectName}_cache\\\\images")
        };
        fs::create_dir_all(&cache_dir)?;
        Ok(cache_dir)
    }
    
    #[cfg(target_os = "linux")]
    {
        let cache_dir = if let Some(cache) = dirs::cache_dir() {
            cache.join("$projectName").join("images")
        } else {
            PathBuf::from("/tmp/${projectName}_cache/images")
        };
        fs::create_dir_all(&cache_dir)?;
        Ok(cache_dir)
    }
    
    #[cfg(target_os = "macos")]
    {
        let cache_dir = if let Some(cache) = dirs::cache_dir() {
            cache.join("$projectName").join("images")
        } else {
            PathBuf::from("/tmp/${projectName}_cache/images")
        };
        fs::create_dir_all(&cache_dir)?;
        Ok(cache_dir)
    }
    
    #[cfg(not(any(target_os = "android", target_os = "ios", target_os = "windows", target_os = "linux", target_os = "macos")))]
    {
        let cache_dir = PathBuf::from("/tmp/${projectName}_cache/images");
        fs::create_dir_all(&cache_dir)?;
        Ok(cache_dir)
    }
}

/// Store image path in cache
pub fn cache_image_path(key: &str, path: &str) -> Result<()> {
    let mut cache = IMAGE_CACHE.lock()
        .map_err(|e| anyhow::anyhow!("Cache lock error: {}", e))?;
    cache.insert(key.to_string(), path.to_string());
    Ok(())
}

/// Get cached image path
pub fn get_cache_entry(key: &str) -> Option<String> {
    let cache = IMAGE_CACHE.lock().ok()?;
    cache.get(key).cloned()
}

/// Clear image cache
pub fn clear_image_cache() -> Result<()> {
    // Clear in-memory cache
    let mut cache = IMAGE_CACHE.lock()
        .map_err(|e| anyhow::anyhow!("Cache lock error: {}", e))?;
    cache.clear();

    // Clear disk cache
    let cache_dir = get_cache_directory()?;
    if cache_dir.exists() {
        fs::remove_dir_all(&cache_dir)?;
        fs::create_dir_all(&cache_dir)?;
    }

    Ok(())
}

/// Get cache size in bytes
pub fn get_cache_size() -> Result<i64> {
    let cache_dir = get_cache_directory()?;
    if !cache_dir.exists() {
        return Ok(0);
    }

    let mut total_size: u64 = 0;
    for entry in fs::read_dir(&cache_dir)? {
        let entry = entry?;
        let metadata = entry.metadata()?;
        if metadata.is_file() {
            total_size += metadata.len();
        }
    }

    Ok(total_size as i64)
}
''';

  static String readme(String projectName) => '''# $projectName Rust FFI Library

High-performance Rust FFI bindings for Flutter, providing fast image processing and JSON operations.

## Features

- **Fast JSON Processing**: Optimized JSON encoding/decoding using Rust's `serde_json`
- **Image Processing**: Resize, compress, and optimize images with support for JPEG, PNG, and WebP
- **Image Caching**: Intelligent caching system to avoid reprocessing images
- **Cross-platform**: Supports Android, iOS, Windows, Linux, and macOS

## Building

### Prerequisites

- Rust (latest stable version)
- Cargo (Rust's package manager)

### Build for Current Platform

**Linux/macOS:**
```bash
chmod +x build.sh
./build.sh
```

**Windows:**
```cmd
build.bat
```

**Manual build:**
```bash
cargo build --release
```

### Platform-Specific Builds

**Android:**
```bash
cargo build --target aarch64-linux-android --release
cargo build --target armv7-linux-androideabi --release
cargo build --target i686-linux-android --release
cargo build --target x86_64-linux-android --release
```

**iOS:**
```bash
cargo build --target aarch64-apple-ios --release
cargo build --target x86_64-apple-ios --release
```

**Linux:**
```bash
cargo build --target x86_64-unknown-linux-gnu --release
```

**Windows:**
```bash
cargo build --target x86_64-pc-windows-msvc --release
```

**macOS:**
```bash
cargo build --target x86_64-apple-darwin --release
cargo build --target aarch64-apple-darwin --release
```

## Project Structure

```
rust/
├── src/
│   ├── lib.rs          # Main library entry point
│   ├── ffi.rs          # FFI bindings for Dart interop
│   ├── json_processing.rs  # JSON encoding/decoding
│   ├── image_processing.rs  # Image processing logic
│   └── cache.rs        # Image cache management
├── Cargo.toml          # Rust dependencies
├── build.sh            # Build script (Linux/macOS)
└── build.bat           # Build script (Windows)
```

## FFI Functions

### JSON Operations

- `${projectName}_json_decode(json_ptr: *const c_char) -> *mut c_char`: Decode JSON string
- `${projectName}_json_encode(data_ptr: *const c_char) -> *mut c_char`: Encode data to JSON

### Image Operations

- `${projectName}_process_image(...)`: Process and save image
- `${projectName}_get_or_cache_image(...)`: Get from cache or process and cache
- `${projectName}_clear_image_cache() -> i32`: Clear image cache
- `${projectName}_get_cache_size() -> i64`: Get cache size in bytes
- `${projectName}_free(ptr: *mut c_void)`: Free allocated memory

## Integration with Flutter

After building, copy the generated library to your Flutter project:

- **Android**: Place `.so` files in `android/app/src/main/jniLibs/<abi>/`
- **iOS**: Add to Xcode project and link
- **Windows**: Place `.dll` in the same directory as your executable
- **Linux**: Place `.so` in the same directory as your executable
- **macOS**: Place `.dylib` in the app bundle

See `lib/core/ffi/rust_ffi.dart` for Dart bindings usage.

## Dependencies

- `serde` & `serde_json`: JSON serialization
- `image`: Image processing
- `anyhow`: Error handling
- `once_cell`: Lazy static initialization
- `dirs`: Platform-specific directory access (non-Android)

## Performance Notes

- JSON processing uses Rust's highly optimized `serde_json`
- Image processing uses `image` crate with Lanczos3 filter for high quality
- Cache uses in-memory HashMap for fast lookups
- All FFI calls are synchronous but should be called from background isolates in Dart
''';

  static String quickStart(String projectName) => '''# Quick Start Guide

## Build the Rust Library

### Quick Build (Current Platform)

**Linux/macOS:**
```bash
cd rust
./build.sh
```

**Windows:**
```cmd
cd rust
build.bat
```

## Copy Library to Flutter

After building, copy the library to your Flutter project:

### Android
```
android/app/src/main/jniLibs/
├── arm64-v8a/lib${projectName}_ffi.so
├── armeabi-v7a/lib${projectName}_ffi.so
├── x86/lib${projectName}_ffi.so
└── x86_64/lib${projectName}_ffi.so
```

### Windows
```
build/windows/x64/runner/Release/${projectName}_ffi.dll
```

### Linux
```
build/linux/x64/release/bundle/lib/lib${projectName}_ffi.so
```

### macOS/iOS
Add to Xcode project and link in Build Phases.

## Usage in Dart

### Initialize (in main.dart)
```dart
import 'package:$projectName/core/common/hybrid_parser.dart';
import 'package:$projectName/core/common/image_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Rust FFI
  await HybridParser.initialize();
  await ImageService.getInstance();
  
  // ... rest of initialization
}
```

### JSON Parsing
```dart
final parser = HybridParser(jsonString, (data) => MyModel.fromJson(data));
final result = await parser.parse();
```

### Image Processing
```dart
final imageService = await ImageService.getInstance();
final cachedPath = await imageService.processAndCache(
  imagePath: '/path/to/image.jpg',
  width: 800,
  height: 600,
);
```

## See Also

- `rust/README.md` - Rust-specific documentation
''';
}
