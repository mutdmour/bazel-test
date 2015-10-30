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
    ],
)

filegroup(
    name = "webapp",
    srcs = glob(["webapp/**/*"]),
)
