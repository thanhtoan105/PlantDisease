// Phần allprojects: repositories và force TF Lite versions
allprojects {
    repositories {
        google()
        mavenCentral()
    }

    // Force NEWEST TensorFlow Lite version (2.17.0) to fix FULLY_CONNECTED version 12 compatibility
    configurations.all {
        resolutionStrategy {
            force("org.tensorflow:tensorflow-lite:2.17.0")
            force("org.tensorflow:tensorflow-lite-gpu:2.17.0")
            force("org.tensorflow:tensorflow-lite-api:2.17.0")
            // Chỉ force tensorflow-lite-support nếu project dùng, nếu không thì bỏ
            force("org.tensorflow:tensorflow-lite-support:0.4.4")
        }
    }
}

// Exclude old versions to prevent conflicts
configurations.all {
    exclude(group = "org.tensorflow", module = "tensorflow-lite")
    exclude(group = "org.tensorflow", module = "tensorflow-lite-gpu")
}

// Custom build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")  // Gộp để tránh lặp
}

// Custom clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
