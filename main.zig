const std = @import("std");
const print = std.debug.print;
const Vector = @import("vector.zig").Vector;
const Matrix = @import("matrix.zig").Matrix;

pub fn main() !void {}

// test "vector_0" {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     defer _ = gpa.deinit();
//     const allocator = gpa.allocator();

//     var v1 = try Vector(f32).init(allocator, &[_]f32{ 3, 4, 5 });
//     defer v1.deinit();
//     var v2 = try Vector(f32).init(allocator, &[_]f32{ 7, 8, 9 });
//     defer v2.deinit();

//     try v1.print();
//     try v2.print();

//     var v3 = try Vector(f32).add(allocator, v1, v2);
//     defer v3.deinit();

//     try v3.print();

//     const dot_product_v1_v2 = try Vector(f32).dot_product(v1, v2);
//     print("dot product between v1 and v2: {d}\n", .{dot_product_v1_v2});
// }

test "matrix_0" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var m1 = try Matrix(f32).init(allocator, 3, 3);
    defer m1.deinit();

    try m1.fill(3.0);
    try m1.print();
}
