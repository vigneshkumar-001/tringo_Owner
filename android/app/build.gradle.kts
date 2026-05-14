import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val keyAliasProp = (keystoreProperties["keyAlias"] as? String)?.trim().orEmpty()
val keyPasswordProp = (keystoreProperties["keyPassword"] as? String)?.trim().orEmpty()
val storeFileProp = (keystoreProperties["storeFile"] as? String)?.trim().orEmpty()
val storePasswordProp = (keystoreProperties["storePassword"] as? String)?.trim().orEmpty()
val hasReleaseKeystore =
    keyAliasProp.isNotEmpty() &&
        keyPasswordProp.isNotEmpty() &&
        storeFileProp.isNotEmpty() &&
        storePasswordProp.isNotEmpty() &&
        rootProject.file(storeFileProp).exists()

android {
    namespace = "com.fenizo.tringo_owner.tringo_owner"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.fenizo.tringo_owner.tringo_owner"
        minSdk = maxOf(23, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keyAliasProp
                keyPassword = keyPasswordProp
                storeFile = rootProject.file(storeFileProp)
                storePassword = storePasswordProp
            }
        } else {
            println(
                "WARNING: android/key.properties missing/incomplete (or keystore file not found). " +
                    "Release builds will be signed with the debug key. " +
                    "Create a keystore + fill android/key.properties for Play Store releases.",
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        viewBinding = true
    }

    buildTypes {
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
        release {
            signingConfig =
                if (hasReleaseKeystore) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("com.google.android.material:material:1.12.0")
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("io.coil-kt:coil:2.6.0")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    implementation("com.squareup.retrofit2:retrofit:2.11.0")
    implementation(platform("com.google.firebase:firebase-bom:34.10.0"))
    implementation("com.squareup.retrofit2:converter-gson:2.11.0")
    implementation("com.google.code.gson:gson:2.11.0")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
//plugins {
//    id("com.android.application")
//    id("org.jetbrains.kotlin.android")
//    id("dev.flutter.flutter-gradle-plugin")
//}
//
//android {
//    namespace = "com.fenizo.tringo_owner.tringo_owner"
//    compileSdk = flutter.compileSdkVersion
//    ndkVersion = flutter.ndkVersion
//
//    defaultConfig {
//        applicationId = "com.fenizo.tringo_owner.tringo_owner"
//        minSdk = maxOf(23, flutter.minSdkVersion)
//        targetSdk = flutter.targetSdkVersion
//        versionCode = flutter.versionCode
//        versionName = flutter.versionName
//    }
//
//    compileOptions {
//        sourceCompatibility = JavaVersion.VERSION_17
//        targetCompatibility = JavaVersion.VERSION_17
//        isCoreLibraryDesugaringEnabled = true
//
//    }
//    kotlinOptions { jvmTarget = "17" }
//
//    buildFeatures { viewBinding = true }
//
//    buildTypes {
//        debug {
//            isMinifyEnabled = false
//            isShrinkResources = false
//        }
//        release {
//            signingConfig = signingConfigs.getByName("debug")
//            isMinifyEnabled = false
//            isShrinkResources = false
//        }
//    }
//}
//
//flutter { source = "../.." }
//
//dependencies {
//    implementation("androidx.core:core-ktx:1.13.1")
//    implementation("androidx.appcompat:appcompat:1.7.0")
//    implementation("com.google.android.material:material:1.12.0")
//
//    // ✅ RecyclerView
//    implementation("androidx.recyclerview:recyclerview:1.3.2")
//
//    // ✅ Coroutines
//    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
//
//    // ✅ Coil (Image loading)
//    implementation("io.coil-kt:coil:2.6.0")
//
//    // ✅ OkHttp + Retrofit + Gson (ApiClient.kt uses this)
//    implementation("com.squareup.okhttp3:okhttp:4.12.0")
//    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
//    implementation("com.squareup.retrofit2:retrofit:2.11.0")
//    implementation("com.squareup.retrofit2:converter-gson:2.11.0")
//    implementation("com.google.code.gson:gson:2.11.0")
//
//    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
//}
//
//
//
////dependencies {
////    implementation("androidx.core:core-ktx:1.13.1")
////    implementation("androidx.appcompat:appcompat:1.7.0")
////    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
////
////
////    implementation("com.google.android.material:material:1.12.0")
////}
