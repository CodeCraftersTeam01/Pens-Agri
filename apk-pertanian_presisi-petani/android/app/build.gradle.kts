plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "id.ac.pens.pertanian_presisi.petani"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "id.ac.pens.pertanian_presisi.petani"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

flutter {
    source = "../.."
}

// =====================================================================
// SUNTIKAN REPOSITORI JITPACK LANGSUNG DI LEVEL MODUL APP
// =====================================================================
repositories {
    google()
    mavenCentral()
    maven(url = "https://jitpack.io")
}

dependencies {
    // Menarik driver USB Serial terupdate & stabil dari Github via JitPack
    implementation("com.github.mik3y:usb-serial-for-android:3.9.0")
}