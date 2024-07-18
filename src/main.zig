const std = @import("std");
const print = std.debug.print;

const matrix = @import("matrix.zig");
const vector = @import("vector.zig");

const transform = @import("transform.zig");

pub fn main() !void {
    const m1 = matrix.Mat2(f32);
    m1.lazyPrint();
    const v1 = vector.Vector2(f32, 3, 4);
    v1.lazyPrint();
    _ = try transform.transformVector(f32, m1, v1);
}
