plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.thousand_praises"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.thousand_praises"
        minSdk = 21
        targetSdk = 36

        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

buildTypes {
    getByName("release") {
        isMinifyEnabled = false
        isShrinkResources = false   // 🔥 ADD THIS LINE
        signingConfig = signingConfigs.getByName("debug")
    }
}
}


flutter {
    source = "../.."
}
