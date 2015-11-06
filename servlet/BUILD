load("/rules/war", "war_file")

war_file(
    name = "backend",
    data = [":webapp"],
    data_path = "/servlet/webapp",
    jars = [":app"],
)

java_library(
    name = "javax.servlet.api",
    neverlink = 1,
    visibility = ["//visibility:public"],
    exports = ["@javax-servlet-api//jar:jar"],
)

java_library(
    name = "app",
    srcs = glob(["src/main/java/**/*.java"]),
    deps = [
        "javax.servlet.api",
        ":lombok",
        "@slf4j-jar//jar",
    ],
)

filegroup(
    name = "webapp",
    srcs = glob(["webapp/**/*"]),
)

java_plugin(
  name = "lombok_plugin",
  processor_class = "lombok.launch.AnnotationProcessorHider$AnnotationProcessor",
  deps = ["@lombok-jar//jar"],
)

java_library(
  name = "lombok",
  exports = ["@lombok-jar//jar"],
  exported_plugins = [":lombok_plugin"],
)
