const std = @import("std");
const Complex = std.math.Complex;

/// Write complex sequence to file.
///
/// File has three tab-separated columns:
/// 1. Data index
/// 2. Real component
/// 3. Complex component
pub fn write_complex(
    comptime T: type,
    filename: []const u8,
    signal: []const Complex(T),
) !void {
    const file = try std.fs.cwd().createFile(filename, .{});
    defer file.close();

    for (signal, 0..) |data, i| {
        _ = try file.write(std.mem.asBytes(&i));
        _ = try file.write(std.mem.asBytes(&data.re));
        _ = try file.write(std.mem.asBytes(&data.im));
    }
}

/// Read complex sequence from file.
///
/// Ignores the index column and returns an ArrayList of Complex(T).
pub fn read(comptime T: type, filename: []const u8, allocator: std.mem.Allocator) !std.ArrayList(Complex(T)) {
    const file = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    defer file.close();

    var file_buffer: [1024]u8 = undefined;
    var file_reader = file.reader(&file_buffer);

    var array: std.ArrayList(Complex(T)) = .empty;

    const width = 2 * @sizeOf(T) + @sizeOf(usize);

    while (file_reader.interface.take(width) catch null) |line| {
        const re = std.mem.bytesToValue(T, line[@sizeOf(usize) .. @sizeOf(usize) + @sizeOf(T)]);
        const im = std.mem.bytesToValue(T, line[@sizeOf(usize) + @sizeOf(T) ..]);
        const value: std.math.Complex(T) = .init(re, im);
        try array.append(allocator, value);
    }

    return array;
}
