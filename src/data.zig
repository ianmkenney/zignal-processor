const Complex = @import("std").math.Complex;
const io = @import("io.zig");

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
    };
}
