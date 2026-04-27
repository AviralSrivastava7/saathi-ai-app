# Flutter / Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Suppress warnings for missing MediaPipe proto classes as suggested by the build error
-dontwarn com.google.mediapipe.proto.CalculatorProfileProto$CalculatorProfile
-dontwarn com.google.mediapipe.proto.GraphTemplateProto$CalculatorGraphTemplate

# Keep all MediaPipe classes to prevent them from being stripped or renamed
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# Keep Gson / JSON serialization (if used by any plugin)
-keepattributes Signature
-keepattributes *Annotation*
