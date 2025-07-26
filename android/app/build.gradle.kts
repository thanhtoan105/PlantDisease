plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.plant_ai_disease_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.plant_ai_disease_flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Use NEWEST TensorFlow Lite version (2.17.0) to support newer model operations
    // This fixes the "FULLY_CONNECTED version 12" compatibility issue
    val tfliteVersion = "2.17.0"
    implementation("org.tensorflow:tensorflow-lite:$tfliteVersion") {
        exclude(group = "org.tensorflow", module = "tensorflow-lite")
    }
    implementation("org.tensorflow:tensorflow-lite-gpu:$tfliteVersion") {
        exclude(group = "org.tensorflow", module = "tensorflow-lite-gpu")
    }
    implementation("org.tensorflow:tensorflow-lite-api:$tfliteVersion")
    implementation("org.tensorflow:tensorflow-lite-support:0.4.4")
}
