const std = @import("std");
const print = std.debug.print;
const matrix = @import("matrix.zig");
const vector = @import("vector.zig");

pub fn main() !void {
    const v1 = vector.Vector2(f32, 3, 4);
    print("{}, {}\n", .{ v1.magnitudeSquared(), v1.magnitude() });
    const v2 = vector.Vector2(f32, 2, 3);
    print("{}\n", .{vector.distance(f32, v1, v2)});
}
