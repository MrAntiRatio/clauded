# Keep Compose runtime metadata
-keep class androidx.compose.runtime.** { *; }
-dontwarn androidx.compose.**

# Keep Kotlin metadata
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
