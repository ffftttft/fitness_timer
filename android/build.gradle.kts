allprojects {
    repositories {
        google()
        maven {
            url = uri("https://maven.aliyun.com/repository/google")
        }
        maven {
            url = uri("https://maven.aliyun.com/repository/central")
        }
    }
}



val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
subprojects {
    fun injectNamespaceAndCompileSdk() {
        if (!project.plugins.hasPlugin("com.android.library")) return
        val android = project.extensions.findByName("android") ?: return
        try {
            val getNs = android.javaClass.getMethod("getNamespace")
            val setNs = android.javaClass.getMethod("setNamespace", String::class.java)
            val current = getNs.invoke(android) as? String
            if (current == null || current.isEmpty()) setNs.invoke(android, "com.isar_db.flutter_libs")
            android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType).invoke(android, 35)
        } catch (_: Exception) { }
    }
    if (project.state.executed) injectNamespaceAndCompileSdk()
    else project.afterEvaluate { injectNamespaceAndCompileSdk() }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
