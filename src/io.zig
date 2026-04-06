const std = @import("std");
const Complex = std.math.Complex;

/// Write complex sequence to file.
///
/// File has three tab-separated columns:
/// 1. Data index
/// 2. Real component
/// 3. Complex component
pub fn write_complex(comptime T: type, filename: []const u8, signal: []const Complex(T)) !void {
    const file = try std.fs.cwd().createFile(
        filename,
        .{ .read = true },
    );
    defer file.close();

    for (signal, 0..) |data, i| {
        const string = try std.fmt.allocPrint(
            std.heap.page_allocator,
            "{}\t{}\t{}\n",
            .{ i, data.re, data.im },
        );
        defer std.heap.page_allocator.free(string);
        _ = try file.write(string);
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
    while (try file_reader.interface.takeDelimiter('\n')) |line| {
        var field_it = std.mem.splitScalar(u8, line, '\t');
        _ = field_it.next();
        const re = try std.fmt.parseFloat(T, field_it.next().?);
        const im = try std.fmt.parseFloat(T, field_it.next().?);
        const value: std.math.Complex(T) = .init(re, im);
        try array.append(allocator, value);
    }

    return array;
}
