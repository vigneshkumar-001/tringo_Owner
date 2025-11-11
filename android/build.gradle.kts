import org.gradle.api.file.Directory

// Needed so all modules can resolve deps
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Move the root build dir to ../../build
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.set(newBuildDir)

// Move each subproject's build dir under that
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    layout.buildDirectory.set(newSubprojectBuildDir)

    // Make sure :app is evaluated first (as you had)
    evaluationDependsOn(":app")
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
