const std = @import("std");
const io = @import("io.zig");
const Complex = std.math.Complex;
const Signal = @import("data.zig").Signal;
const Spectrum = @import("data.zig").Spectrum;

fn sample_signal(t: f32) Complex(f32) {
    return .init(std.math.sin(5 * t) + std.math.cos(7 * t) + 3, 0);
}

pub fn main() !void {
    const n_samples = 32;
    const precision = f32;

    var samples = Signal(precision, n_samples).initFn(sample_signal);
    var spectrum = samples.dft();
    var recon = spectrum.idft();

    try samples.write("original.dat");
    try spectrum.write("data.dat");
    try recon.write("recon.dat");

    var values = try io.read(precision, "recon.dat", std.heap.page_allocator);
    defer values.deinit(std.heap.page_allocator);
}
