plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.decodersfamily.customersupport"
    compileSdk = 35 // Updated to match plugin requirements
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.decodersfamily.customersupport"
        minSdk = 21 // or the desired minSdkVersion
        targetSdk = 35 // or the desired targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("customer_suppport.keystore")
            storePassword = "12345678"
            keyAlias = "customer_support_key"
            keyPassword = "12345678"
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true // Enables code shrinking (R8)
            
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    // You may need to specify your Flutter source location if it’s not a standard Flutter project structure.
    source = "../.."
}
