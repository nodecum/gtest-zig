const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gt_dep = b.dependency("gtest", .{});
    const cflags = &.{
        "-Wall",
        "-Wshadow",
        "-Wconversion",
        "-Wundef",
        "-Wchar-subscripts",
        "-DGTEST_HAS_PTHREAD=0",
    };
    // -------------- gtest lib --------------------------------
    const gtest_root_dir = gt_dep.path("googletest");
    const gtest_include_dir = gt_dep.path("googletest/include");
    const gtest_lib = b.addStaticLibrary(
        .{ .name = "gtest", .target = target, .optimize = optimize },
    );
    gtest_lib.linkLibCpp();
    const gtest_cc_files = &.{
        "googletest/src/gtest-assertion-result.cc",
        "googletest/src/gtest.cc",
        "googletest/src/gtest-death-test.cc",
        "googletest/src/gtest-filepath.cc",
        "googletest/src/gtest-matchers.cc",
        "googletest/src/gtest-port.cc",
        "googletest/src/gtest-printers.cc",
        "googletest/src/gtest-test-part.cc",
        "googletest/src/gtest-typed-test.cc",
    };
    gtest_lib.addCSourceFiles(
        .{ .dependency = gt_dep, .files = gtest_cc_files, .flags = cflags },
    );
    gtest_lib.addIncludePath(gtest_root_dir);
    gtest_lib.addIncludePath(gtest_include_dir);
    b.installArtifact(gtest_lib);
    // we export gtest-all.cc as lib
    const gtest_all_lib = b.addStaticLibrary(
        .{ .name = "gtest-all", .target = target, .optimize = optimize },
    );
    gtest_all_lib.linkLibCpp();
    gtest_all_lib.addCSourceFiles(
        .{
            .dependency = gt_dep,
            .files = &.{"googletest/src/gtest-all.cc"},
            .flags = cflags,
        },
    );
    gtest_all_lib.addIncludePath(gtest_root_dir);
    gtest_all_lib.addIncludePath(gtest_include_dir);
    b.installArtifact(gtest_all_lib);

    // and gtest_main.cc as gtest-main lib
    const gtest_main_lib = b.addStaticLibrary(
        .{ .name = "gtest-main", .target = target, .optimize = optimize },
    );
    gtest_main_lib.linkLibCpp();
    gtest_main_lib.addCSourceFiles(
        .{
            .dependency = gt_dep,
            .files = &.{"googletest/src/gtest_main.cc"},
            .flags = cflags,
        },
    );
    gtest_main_lib.addIncludePath(gtest_root_dir);
    gtest_main_lib.addIncludePath(gtest_include_dir);
    b.installArtifact(gtest_main_lib);
    gtest_lib.installHeadersDirectoryOptions(
        .{
            .source_dir = gt_dep.path("googletest/include/gtest"),
            .install_dir = .header,
            .install_subdir = "gtest",
        },
    );
    // --------------- gmock --------------------------------------------
    const gmock_root_dir = gt_dep.path("googlemock");
    const gmock_include_dir = gt_dep.path("googlemock/include");

    const gmock_lib = b.addStaticLibrary(
        .{ .name = "gmock", .target = target, .optimize = optimize },
    );
    gmock_lib.linkLibCpp();
    const gmock_cc_files = &.{
        "googlemock/src/gmock-cardinalities.cc",
        "googlemock/src/gmock.cc",
        "googlemock/src/gmock-internal-utils.cc",
        "googlemock/src/gmock-matchers.cc",
        "googlemock/src/gmock-spec-builders.cc",
    };
    gmock_lib.addCSourceFiles(
        .{ .dependency = gt_dep, .files = gmock_cc_files, .flags = cflags },
    );
    gmock_lib.addIncludePath(gmock_root_dir);
    gmock_lib.addIncludePath(gtest_include_dir);
    gmock_lib.addIncludePath(gmock_include_dir);
    gmock_lib.linkLibrary(gtest_lib);
    b.installArtifact(gmock_lib);
    // we export gmock-all.cc as lib
    const gmock_all_lib = b.addStaticLibrary(
        .{ .name = "gmock-all", .target = target, .optimize = optimize },
    );
    gmock_all_lib.linkLibCpp();
    gmock_all_lib.addCSourceFiles(
        .{
            .dependency = gt_dep,
            .files = &.{"googlemock/src/gmock-all.cc"},
            .flags = cflags,
        },
    );
    gmock_all_lib.addIncludePath(gmock_root_dir);
    gmock_all_lib.addIncludePath(gtest_include_dir);
    gmock_all_lib.addIncludePath(gmock_include_dir);
    b.installArtifact(gmock_all_lib);

    // and gmock_main.cc as gmock-main lib
    const gmock_main_lib = b.addStaticLibrary(
        .{ .name = "gmock-main", .target = target, .optimize = optimize },
    );
    gmock_main_lib.linkLibCpp();
    gmock_main_lib.addCSourceFiles(
        .{
            .dependency = gt_dep,
            .files = &.{"googlemock/src/gmock_main.cc"},
            .flags = cflags,
        },
    );
    gmock_main_lib.addIncludePath(gmock_root_dir);
    gmock_main_lib.addIncludePath(gtest_include_dir);
    gmock_main_lib.addIncludePath(gmock_include_dir);
    b.installArtifact(gmock_main_lib);
    gmock_lib.installHeadersDirectoryOptions(
        .{
            .source_dir = gt_dep.path("googlemock/include/gmock"),
            .install_dir = .header,
            .install_subdir = "gmock",
        },
    );
}
