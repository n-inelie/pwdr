const std = @import("std");
const print = std.debug.print;
const matrix = @import("matrix.zig");
const vector = @import("vector.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // var m1 = try matrix.Matrix(u8).init(gpa.allocator(), 3, 3);
    // defer m1.deinit();
    // var m2 = try matrix.Matrix(u8).init(gpa.allocator(), 3, 3);
    // defer m2.deinit();
    // m1.fill(3);
    // m2.fill(4);
    // var m3 = try matrix.Add(u8, gpa.allocator(), m1, m2);
    // defer m3.deinit();
    // print("{d} + {d} = {d}\n", .{ m1.elements.items[3], m2.elements.items[3], m3.elements.items[3] });

    const v1 = vector.Vector2(u8).init(3, 4);
    print("{}, {}\n", .{ v1.magnitudeSquared(), v1.magnitude() });
}
