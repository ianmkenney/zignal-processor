const std = @import("std");
const io = @import("io.zig");
const Complex = std.math.Complex;
const Signal = @import("data.zig").Signal;
const Spectrum = @import("data.zig").Spectrum;

fn sample_signal(comptime T: type) (fn (T) Complex(T)) {
    const inner = struct {
        fn _sample_signal(t: T) Complex(T) {
            return .init(std.math.sin(5.0 * t) + std.math.cos(9.0 * t) + 1.0, 0);
        }
    };

    return inner._sample_signal;
}

pub fn main() !void {
    const n_samples = 32;
    const precision = f64;

    var samples = Signal(precision, n_samples).initFn(sample_signal(precision));
    var spectrum = samples.dft();
    var recon = spectrum.idft();

    try samples.write("original.dat");
    try spectrum.write("data.dat");
    try recon.write("recon.dat");

    var values = try io.read(precision, "recon.dat", std.heap.page_allocator);
    defer values.deinit(std.heap.page_allocator);
}
