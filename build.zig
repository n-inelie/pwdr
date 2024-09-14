const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "pwdr",
        .root_source_file = b.path("main.zig"),
        .optimize = .ReleaseFast,
        .target = b.standardTargetOptions(.{}),
    });

    b.installArtifact(exe);

    b
        .step("run", "Run the application")
        .dependOn(&b.addRunArtifact(exe).step);

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("main.zig"),
    });

    b
        .step("test", "Run tests")
        .dependOn(&b.addRunArtifact(unit_tests).step);
}
