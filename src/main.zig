const std = @import("std");
const print = std.debug.print;
const matrix = @import("matrix.zig");
const vector = @import("vector.zig");

pub fn main() !void {
    var v1 = vector.Vector2(f32, 3, 4);
    print("{}, {}\n", .{ v1.magnitudeSquared(), v1.magnitude() });
}
