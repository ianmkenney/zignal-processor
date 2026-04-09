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

    const precision = b.option(bool, "double", "use double precision") orelse false;
    const options = b.addOptions();
    options.addOption(bool, "enabledouble", precision);
    exe.root_module.addOptions("config", options);

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
