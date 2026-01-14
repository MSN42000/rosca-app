pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("com.android.application") version "7.4.2" apply false
    id("org.jetbrains.kotlin.android") version "1.8.0" apply false
}

include(":app")