const std = @import("std");
const print = std.debug.print;
const matrix = @import("matrix.zig");
const vector = @import("vector.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var m1 = try matrix.Matrix(i8).init(gpa.allocator(), 3, 3);
    defer m1.deinit();
    try m1.makeScaler(3);
    try m1.lazyPrint();

    var m2 = try matrix.Matrix(i8).init(gpa.allocator(), 3, 3);
    defer m2.deinit();
    try m2.makeScaler(3);
    try m2.lazyPrint();

    var m3 = try matrix.Multiply(i8, gpa.allocator(), m1, m2);
    defer m3.deinit();

    try m3.lazyPrint();

    // const v1 = vector.Vector2(u8).init(3, 4);
    // print("{}, {}\n", .{ v1.magnitudeSquared(), v1.magnitude() });
}
