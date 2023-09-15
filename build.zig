const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "gtest",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibCpp();

    const folder = b.build_root.join(b.allocator, &.{ "gtest", "googletest", "src" }) catch @panic("File Not Found");
    var dir = std.fs.cwd().openIterableDir(folder, .{}) catch unreachable;
    var it = dir.iterate();

    while (it.next() catch unreachable) |file| {
        if (file.kind != .file) {
            continue;
        }

        const name: []const u8 = file.name;
        if (std.ascii.endsWithIgnoreCase(name, ".cc")) {
            lib.addCSourceFile(.{
                .file = .{ .path = b.pathJoin(&.{ folder, name }) },
                .flags = &.{
                    "-Wall",
                    "-Wshadow",
                    "-Wconversion",
                    "-Wundef",
                    "-Wchar-subscripts",
                    "-DGTEST_HAS_PTHREAD=0",
                },
            });
        }
    }

    lib.addIncludePath(.{ .path = b.pathJoin(&.{ "gtest", "googletest" }) });
    lib.addIncludePath(.{ .path = b.pathJoin(&.{ "gtest", "googletest", "include" }) });
    b.installArtifact(lib);

    lib.step.dependOn(installHeaders(
        b,
        b.pathJoin(&.{ "gtest", "googletest", "include", "gtest" }),
        "gtest",
    ));

    lib.step.dependOn(installHeaders(
        b,
        b.pathJoin(&.{ "gtest", "googletest", "include", "gtest", "internal" }),
        b.pathJoin(&.{ "gtest", "internal" }),
    ));

    //TODO should we provide a way to set the custom headers?
    lib.step.dependOn(installHeaders(
        b,
        b.pathJoin(&.{ "gtest", "googletest", "include", "gtest", "internal", "custom" }),
        b.pathJoin(&.{ "gtest", "internal", "custom" }),
    ));
}

fn installHeaders(b: *std.Build, folder: []const u8, out_folder: []const u8) *std.build.Step {
    var dir = std.fs.cwd().openIterableDir(b.build_root.join(b.allocator, &.{folder}) catch @panic("File Not Found"), .{}) catch unreachable;
    var it = dir.iterate();
    var step = b.allocator.create(std.Build.Step) catch @panic("OOM");
    step.* = std.Build.Step.init(.{
        .id = .custom,
        .name = "install headers",
        .owner = b,
    });

    while (it.next() catch unreachable) |file| {
        if (file.kind != .file) {
            continue;
        }

        const name: []const u8 = file.name;
        if (std.ascii.endsWithIgnoreCase(name, ".h")) {
            step.dependOn(&b.addInstallHeaderFile(b.pathJoin(&.{ folder, name }), b.pathJoin(&.{ out_folder, name })).step);
        }
    }

    return step;
}
