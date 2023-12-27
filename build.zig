const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gtest_dep = b.dependency("gtest", .{});

    const cflags = &.{
        "-Wall",
        "-Wshadow",
        "-Wconversion",
        "-Wundef",
        "-Wchar-subscripts",
        "-DGTEST_HAS_PTHREAD=0",
    };
    const gtest_root_dir = gtest_dep.path("googletest");
    const gtest_include_dir = gtest_dep.path(
        b.pathJoin(&.{ "googletest", "include" }),
    );
    const gtest_lib = b.addStaticLibrary(.{
        .name = "gtest",
        .target = target,
        .optimize = optimize,
    });
    gtest_lib.linkLibCpp();
    var cc_files = [_][]const u8{
        "gtest-assertion-result.cc",
        "gtest.cc",
        "gtest-death-test.cc",
        "gtest-filepath.cc",
        "gtest-matchers.cc",
        "gtest-port.cc",
        "gtest-printers.cc",
        "gtest-test-part.cc",
        "gtest-typed-test.cc",
    };
    // add prefix path to files
    for (&cc_files) |*file| {
        file.* = b.pathJoin(&.{ "googletest", "src", file.* });
    }
    gtest_lib.addCSourceFiles(.{ .dependency = gtest_dep, .files = &cc_files, .flags = cflags });
    gtest_lib.addIncludePath(gtest_root_dir);
    gtest_lib.addIncludePath(gtest_include_dir);
    b.installArtifact(gtest_lib);
    // we export gtest-all.cc as lib
    const gtest_all_lib = b.addStaticLibrary(.{ .name = "gtest-all", .target = target, .optimize = optimize });
    gtest_all_lib.linkLibCpp();
    gtest_all_lib.addCSourceFiles(
        .{
            .dependency = gtest_dep,
            .files = &.{b.pathJoin(&.{ "googletest", "src", "gtest-all.cc" })},
            .flags = cflags,
        },
    );
    gtest_all_lib.addIncludePath(gtest_root_dir);
    gtest_all_lib.addIncludePath(gtest_include_dir);
    b.installArtifact(gtest_all_lib);

    // and gtest_main.cc as gtest-main lib
    const gtest_main_lib = b.addStaticLibrary(.{ .name = "gtest-main", .target = target, .optimize = optimize });
    gtest_main_lib.linkLibCpp();
    gtest_main_lib.addCSourceFiles(
        .{
            .dependency = gtest_dep,
            .files = &.{b.pathJoin(&.{ "googletest", "src", "gtest_main.cc" })},
            .flags = cflags,
        },
    );
    gtest_main_lib.addIncludePath(gtest_root_dir);
    gtest_main_lib.addIncludePath(gtest_include_dir);
    b.installArtifact(gtest_main_lib);

    // install the header, we have a LazyPath,
    // thus can not use installHeader
    // const install_gtest_header = b.addInstallFileWithDir(
    //     gtest_dep.path(
    //         b.pathJoin(&.{ "googletest", "include", "gtest", "gtest.h" }),
    //     ),
    //     .header,
    //     b.pathJoin(&.{ "gtest", "gtest.h" }),
    // );
    // b.getInstallStep().dependOn(&install_gtest_header.step);
    // gtest_lib.installed_headers.append(&install_gtest_header.step) catch @panic("OOM");
    gtest_lib.installHeadersDirectoryOptions(
        .{
            .source_dir = gtest_dep.path(b.pathJoin(&.{ "googletest", "include", "gtest" })),
            .install_dir = .header,
            .install_subdir = "gtest",
        },
    );
}
