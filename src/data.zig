const std = @import("std");
const Complex = @import("std").math.Complex;
const io = @import("io.zig");
const transform = @import("transform.zig");

pub fn Signal(comptime T: type, comptime size: usize) type {
    return struct {
        data: [size]Complex(T),
        const Self = @This();

        pub fn init() Self {
            return Self{ .data = undefined };
        }

        pub fn write(self: Self, filename: []const u8) !void {
            try io.write_complex(T, filename, &self.data);
        }

        pub fn dft(self: Self) Spectrum(T, size) {
            var spectrum = Spectrum(T, size).init();

            for (0..size) |k| {
                transform.dft(T, &spectrum.data, &self.data, k);
            }

            return spectrum;
        }

        pub fn initFn(func: fn (T) Complex(T)) Self {
            var self = Self{ .data = undefined };

            const N = @as(T, @floatFromInt(size));
            for (0..size) |i| {
                const n: T = @as(T, @floatFromInt(i));
                const t = 2.0 * std.math.pi * n / N;
                self.data[i] = func(t);
            }
            return self;
        }
    };
}

pub fn Spectrum(comptime T: type, comptime size: usize) type {
    return struct {
        data: [size]Complex(T),
        const Self = @This();

        pub fn init() Self {
            return Self{ .data = undefined };
        }

        pub fn write(self: Self, filename: []const u8) !void {
            try io.write_complex(T, filename, &self.data);
        }

        pub fn idft(self: Self) Signal(T, size) {
            var signal = Signal(T, size).init();

            for (0..size) |n| {
                transform.idft(T, &signal.data, &self.data, n);
            }

            return signal;
        }
    };
}
