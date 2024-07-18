const std = @import("std");
const print = std.debug.print;
const matrix = @import("matrix.zig");
const vector = @import("vector.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var m1 = try matrix.Matrix(u8).init(gpa.allocator(), 2, 2);
    defer m1.deinit();
    m1.fill(3);
    try m1.set(0, 1, 4);
    print("{d}\n", .{try m1.get(0, 1)});

    const v1 = vector.Vector2(u8).init(3, 4);
    print("{}, {}\n", .{ v1.magnitudeSquared(), v1.magnitude() });
}
