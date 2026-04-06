const std = @import("std");

const version: ?std.SemanticVersion = .{ .major = 0, .minor = 1, .patch = 0 };

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "zignal",
        .version = version,
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = b.graph.host,
            .strip = true,
        }),
    });

    b.installArtifact(exe);
}
