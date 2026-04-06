const std = @import("std");
const Complex = std.math.Complex;

/// Perform discrete Fourier transform on a complex sequence.
///
/// Direct computation of the discrete Fourier transform, updating the `spectrum` buffer.
pub fn dft(comptime T: type, spectrum: []Complex(T), samples: []const Complex(T), k: usize) void {
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
pub fn idft(comptime T: type, signal: []Complex(T), spectrum: []const Complex(T), n: usize) void {
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
pub fn power_spectrum_two_sided(comptime T: type, spectrum: []const Complex(T), allocator: std.mem.Allocator) !std.ArrayList(T) {
    var array: std.ArrayList(T) = try .initCapacity(allocator, spectrum.len);

    for (spectrum) |k| {
        array.appendAssumeCapacity(k.mul(k.conjugate()).re);
    }

    return array;
}
