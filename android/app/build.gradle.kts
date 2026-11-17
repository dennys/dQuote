import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // 桌面小工具用 Jetpack Glance（@Composable），Kotlin 2.x 起 Compose 編譯器是獨立外掛
    id("org.jetbrains.kotlin.plugin.compose")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dennys.dquote"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
    }

    buildFeatures {
        compose = true
        compose = true // Glance 是 Compose 家族，不開這個編不過 DquoteWidget.kt
    }

    defaultConfig {
        applicationId = "com.dennys.dquote"
        // 33（Android 13）：POST_NOTIFICATIONS 是執行時權限，我們的整個提醒功能都建立在它之上。
        // 與同 family 專案一致（也是 arm64 世代；只封 arm64 見下方 ndk.abiFilters）。
        minSdk = 33
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // minSdk 33 的裝置實質上是 arm64 世代，只封 arm64（APK 體積與建置時間都省）。
        // 用 ndk.abiFilters 而不是 splits.abi —— flutter gradle plugin 會自己設 ndk abiFilters，
        // 兩者並存時 Gradle 直接報「Conflicting configuration」。
        ndk {
            abiFilters.addAll(listOf("arm64-v8a"))
        }
    }


    // keystore 與密碼都不進版控：本地放 android/app/{dquote.keystore, key.properties}，
    // CI 由 secrets KEYSTORE_B64 / KEY_PROPERTIES 還原到同一路徑。
    // 沒有 key.properties 時**不能**指定 signingConfig：storeFile 留 null 会让 AGP 的
    // validateSigningRelease 直接報「Keystore file not set for signing config release」，
    // 不會像以前註解寫的「退回未簽章」（不簽章的產物是 app-release-unsigned.apk）。
    val keyPropsFile = file("key.properties")
    signingConfigs {
        create("release") {
            if (keyPropsFile.exists()) {
                val props = Properties().apply { keyPropsFile.inputStream().use { load(it) } }
                storeFile = file(props.getProperty("storeFile"))
                storePassword = props.getProperty("storePassword")
                keyAlias = props.getProperty("keyAlias")
                keyPassword = props.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            if (keyPropsFile.exists()) signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    // 桌面小工具。版本 1.2.0（stable）。compose 相關 AAR 約 26 MB（本機沒快取過，第一次會下載）。
    // 只拉 glance-appwidget（它會帶進 glance 核心 + 它自己要的 compose 版本）。
    // 別額外釘 compose material3 版本：glance 1.2.0 帶的是 material3 1.0.0，另釘新版會讓
    // manifest merger 報「Namespace androidx.compose.material3 is used in multiple libraries」。
}

flutter {
    source = "../.."
}
