const std = @import("std");
const io = @import("io.zig");
const Complex = std.math.Complex;
const Signal = @import("data.zig").Signal;
const Spectrum = @import("data.zig").Spectrum;

/// Perform discrete Fourier transform on a complex sequence.
///
/// Direct computation of the discrete Fourier transform, updating the `spectrum` buffer.
fn dft(comptime T: type, spectrum: []Complex(T), samples: []const Complex(T), k: usize) void {
    const N = @as(T, @floatFromInt(samples.len));
    const _k = @as(T, @floatFromInt(k));
    var sum: Complex(T) = .init(0, 0);

    for (samples, 0..) |sample, n| {
        const x = 2 * std.math.pi * @as(T, @floatFromInt(n)) / N;
        const power = Complex(T).init(0, -_k * x);
        const exp_factor = std.math.complex.exp(power);
        sum = sum.add(sample.mul(exp_factor));
    }
    spectrum[k] = sum;
}

/// Perform the inverse discrete Fourier transform on a complex spectrum.
///
/// Direct computation of the inverse discrete Fourier transform, updating the `signal` buffer.
fn idft(comptime T: type, signal: []Complex(T), spectrum: []const Complex(T), n: usize) void {
    const N = @as(T, @floatFromInt(spectrum.len));
    var sum: Complex(T) = .init(0, 0);
    for (0..(spectrum.len / 2)) |k| {
        const w = spectrum[k];
        const power: Complex(T) = .init(0, 2.0 * std.math.pi * @as(T, @floatFromInt(k * n)) / N);
        sum = sum.add(w.mul(std.math.complex.exp(power)));
    }
    signal[n] = sum.div(Complex(T).init(N / 2, 0));
}

/// Calculate the power spectrum of a signal's spectrum.
fn power_spectrum_two_sided(comptime T: type, spectrum: []const Complex(T), allocator: std.mem.Allocator) !std.ArrayList(T) {
    var array: std.ArrayList(T) = try .initCapacity(allocator, spectrum.len);

    for (spectrum) |k| {
        array.appendAssumeCapacity(k.mul(k.conjugate()).re);
    }

    return array;
}

pub fn main() !void {
    const n_samples = 32;
    const precision = f32;

    var samples = Signal(precision, n_samples).init();
    var spectrum = Spectrum(precision, n_samples).init();
    var recon = Signal(precision, n_samples).init();

    for (0..n_samples) |i| {
        const n: precision = @as(precision, @floatFromInt(i));
        // some sample signal for testing
        // sin(5 t) + cos(7 t) + 3
        const value: Complex(precision) = .init(std.math.sin(2 * 5 * std.math.pi * n / n_samples) +
            std.math.cos(2 * 7 * std.math.pi * n / n_samples) + 3, 0);
        samples.data[i] = value;
    }

    for (0..n_samples) |k| {
        dft(precision, &spectrum.data, &samples.data, k);
    }

    for (0..n_samples) |n| {
        idft(precision, &recon.data, &spectrum.data, n);
    }

    var psts = try power_spectrum_two_sided(precision, &spectrum.data, std.heap.page_allocator);
    defer psts.deinit(std.heap.page_allocator);

    try samples.write("original.dat");
    try spectrum.write("data.dat");
    try recon.write("recon.dat");
    var values = try io.read(precision, "recon.dat", std.heap.page_allocator);
    defer values.deinit(std.heap.page_allocator);
}
