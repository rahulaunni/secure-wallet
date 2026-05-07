# ================= FLUTTER & ANDROID CORE =================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class androidx.lifecycle.** { *; }

# ================= FLUTTER SECURE STORAGE (CRITICAL FIX) =================
# 🚨 This prevents the "HiveEncryption" crash
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep interface com.it_nomads.fluttersecurestorage.** { *; }

# ================= HIVE DB =================
-keep class hive.** { *; }
-keep class * extends hive.TypeAdapter
-keepclassmembers class * {
    public <init>();
}

# ================= LOTTIE ANIMATIONS =================
# 🚨 This prevents animations from disappearing
-keep class com.airbnb.lottie.** { *; }

# ================= CRYPTO & SECURITY =================
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }
-keep class com.google.crypto.tink.** { *; }

# ================= SAFETY & ATTRIBUTES =================
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# ================= OPTIONAL / LEGACY =================
-keep class com.google.gson.** { *; }
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
