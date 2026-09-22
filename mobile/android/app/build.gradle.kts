import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { stream -> load(stream) }
    }
}

val environmentSigningValues = mapOf(
    "ANDROID_UPLOAD_STORE_FILE" to System.getenv("ANDROID_UPLOAD_STORE_FILE"),
    "ANDROID_UPLOAD_STORE_PASSWORD" to System.getenv("ANDROID_UPLOAD_STORE_PASSWORD"),
    "ANDROID_UPLOAD_KEY_ALIAS" to System.getenv("ANDROID_UPLOAD_KEY_ALIAS"),
    "ANDROID_UPLOAD_KEY_PASSWORD" to System.getenv("ANDROID_UPLOAD_KEY_PASSWORD"),
)
val environmentSigningConfigured = environmentSigningValues.values.all {
    !it.isNullOrBlank()
}
val environmentSigningPartiallyConfigured = environmentSigningValues.values.any {
    !it.isNullOrBlank()
} && !environmentSigningConfigured

if (environmentSigningPartiallyConfigured) {
    throw GradleException(
        "Release signing environment variables must be provided together.",
    )
}

if (keystorePropertiesFile.exists() && environmentSigningConfigured) {
    throw GradleException(
        "Configure release signing with either android/key.properties or environment variables, not both.",
    )
}

val releaseBuildRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}

if (releaseBuildRequested &&
    !keystorePropertiesFile.exists() &&
    !environmentSigningConfigured
) {
    throw GradleException(
        "Release signing is not configured. Use android/key.properties locally " +
            "or all ANDROID_UPLOAD_* environment variables in secure CI.",
    )
}

android {
    namespace = "com.myidealbody.ai"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.myidealbody.ai"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists() || environmentSigningConfigured) {
            create("release") {
                if (environmentSigningConfigured) {
                    storeFile = file(environmentSigningValues.getValue("ANDROID_UPLOAD_STORE_FILE")!!)
                    storePassword = environmentSigningValues.getValue("ANDROID_UPLOAD_STORE_PASSWORD")
                    keyAlias = environmentSigningValues.getValue("ANDROID_UPLOAD_KEY_ALIAS")
                    keyPassword = environmentSigningValues.getValue("ANDROID_UPLOAD_KEY_PASSWORD")
                } else {
                    val storePath = keystoreProperties.getProperty("storeFile")
                        ?: throw GradleException(
                            "storeFile is missing from android/key.properties",
                        )
                    storeFile = file(storePath)
                    storePassword = keystoreProperties.getProperty("storePassword")
                        ?: throw GradleException(
                            "storePassword is missing from android/key.properties",
                        )
                    keyAlias = keystoreProperties.getProperty("keyAlias")
                        ?: throw GradleException(
                            "keyAlias is missing from android/key.properties",
                        )
                    keyPassword = keystoreProperties.getProperty("keyPassword")
                        ?: throw GradleException(
                            "keyPassword is missing from android/key.properties",
                        )
                }
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

kotlin {
    jvmToolchain(17)
}

flutter {
    source = "../.."
}
