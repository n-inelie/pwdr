const std = @import("std");
const print = std.debug.print;
const Matrix = @import("matrix.zig").Matrix;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var m1 = try Matrix(u8).init(gpa.allocator(), 3, 3);
    defer m1.deinit();
    var m2 = try Matrix(u8).init(gpa.allocator(), 3, 3);
    defer m2.deinit();
    m1.fill(3);
    m2.fill(4);
    print("{d}, {d}\n", .{ m1.elements.items[3], m2.elements.items[3] });
}
