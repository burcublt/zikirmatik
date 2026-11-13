import java.util.Base64
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseDefines = (project.findProperty("dart-defines") as? String).orEmpty()
    .split(",").filter { it.isNotEmpty() }.associate { encoded ->
        val pair = String(Base64.getDecoder().decode(encoded), Charsets.UTF_8).split("=", limit = 2)
        pair[0] to pair.getOrElse(1) { "" }
    }
val uploadKeyFile = rootProject.file("key.properties")
val uploadKey = Properties().apply {
    if (uploadKeyFile.isFile) uploadKeyFile.inputStream().use { load(it) }
}
val signingFields = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val hasUploadKey = signingFields.all { !uploadKey.getProperty(it).isNullOrBlank() }

android {
    namespace = "com.example.zikirmatik"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = releaseDefines["ANDROID_APPLICATION_ID"]?.takeIf { it.isNotBlank() }
            ?: "com.example.zikirmatik"
        manifestPlaceholders["admobAppId"] = releaseDefines["ADMOB_ANDROID_APP_ID"]?.takeIf { it.isNotBlank() }
            ?: "ca-app-pub-3940256099942544~3347511713"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = maxOf(24, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKey) {
            create("upload") {
                storeFile = rootProject.file(uploadKey.getProperty("storeFile"))
                storePassword = uploadKey.getProperty("storePassword")
                keyAlias = uploadKey.getProperty("keyAlias")
                keyPassword = uploadKey.getProperty("keyPassword")
            }
        }
    }
    buildTypes {
        release {
            if (hasUploadKey) signingConfig = signingConfigs.getByName("upload")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

val validateReleaseConfiguration = tasks.register("validateReleaseConfiguration") {
    doLast {
        val identity = releaseDefines["ANDROID_APPLICATION_ID"].orEmpty()
        val app = releaseDefines["ADMOB_ANDROID_APP_ID"].orEmpty()
        val native = releaseDefines["ADMOB_ANDROID_NATIVE"].orEmpty()
        val banner = releaseDefines["ADMOB_ANDROID_BANNER"].orEmpty()
        val appPattern = Regex("ca-app-pub-[0-9]{16}~[0-9]{10}")
        val unitPattern = Regex("ca-app-pub-[0-9]{16}/[0-9]{10}")
        val identityPattern = Regex("[A-Za-z][A-Za-z0-9_]*(\\.[A-Za-z][A-Za-z0-9_]*)+")
        check(identityPattern.matches(identity) && !identity.startsWith("com.example.")) {
            "ANDROID_APPLICATION_ID gerekli. scripts/build_release.py ile yayın ayarlarını kontrol edin."
        }
        check(appPattern.matches(app) && unitPattern.matches(native) && unitPattern.matches(banner)
            && listOf(app, native, banner).none { it.startsWith("ca-app-pub-3940256099942544") }
            && app.substringBefore('~') == native.substringBefore('/')
            && app.substringBefore('~') == banner.substringBefore('/')) {
            "Gerçek ve aynı yayıncıya ait Android AdMob kimlikleri gerekli."
        }
        check(hasUploadKey && uploadKey.getProperty("keyAlias") != "androiddebugkey"
            && rootProject.file(uploadKey.getProperty("storeFile")).isFile) {
            "Android yayın imzası eksik. android/key.properties.example dosyasını kullanın; debug imzası kabul edilmez."
        }
    }
}
tasks.configureEach {
    if (name == "preReleaseBuild") dependsOn(validateReleaseConfiguration)
}
