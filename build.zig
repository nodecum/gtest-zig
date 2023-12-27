const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gtest_dep = b.dependency("gtest", .{});

    const lib = b.addStaticLibrary(.{
        .name = "gtest",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibCpp();

    var cc_files = [_][]const u8{
        "gtest-all.cc",
        "gtest-assertion-result.cc",
        "gtest.cc",
        "gtest-death-test.cc",
        "gtest-filepath.cc",
        "gtest_main.cc",
        "gtest-matchers.cc",
        "gtest-port.cc",
        "gtest-printers.cc",
        "gtest-test-part.cc",
        "gtest-typed-test.cc",
    };
    for (&cc_files) |*file| {
        file.* = b.pathJoin(&.{ "googletest", "src", file.* });
    }
    lib.addCSourceFiles(.{
        .dependency = gtest_dep,
        .files = &cc_files,
        .flags = &.{
            "-Wall",
            "-Wshadow",
            "-Wconversion",
            "-Wundef",
            "-Wchar-subscripts",
            "-DGTEST_HAS_PTHREAD=0",
        },
    });

    lib.addIncludePath(
        gtest_dep.path(b.pathJoin(&.{ "googletest", "include" })),
    );
    // this is necessary, because likes to include src/gtest-internal-inl.h
    lib.addIncludePath(
        gtest_dep.path(b.pathJoin(&.{"googletest"})),
    );
    // install the header, we have a LazyPath,
    // thus can not use installHeader
    const install_header = b.addInstallFileWithDir(
        gtest_dep.path(
            b.pathJoin(&.{ "googletest", "include", "gtest", "gtest.h" }),
        ),
        .header,
        b.pathJoin(&.{ "gtest", "gtest.h" }),
    );
    b.getInstallStep().dependOn(&install_header.step);
    b.installArtifact(lib);
}
