const std = @import("std");

const matrix = @import("matrix.zig");
const vector = @import("vector.zig");

const Matrix = matrix.Matrix;
const Vector = vector.Vector;

const TransformError = error{InvalidSize};

pub fn transformVector(
    comptime T: type,
    m: Matrix(T),
    v: Vector(T),
) TransformError!Vector(T) {
    if (v.dimensions != m.cols_n) {
        return TransformError.InvalidSize;
    }

    var vec2 = vector.Vector(T).Create(&[_]T{0} ** m.cols_n);
    for (0..m.rows_n) |_| {
        vec2.lazyPrint();
    }
    return v;
}
