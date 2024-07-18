const std = @import("std");
const print = std.debug.print;

const MatrixError = error{
    InvalidSize,
    NotSquare,
    OutOfMemory,
    OutOfBounds,
};

pub fn Matrix(comptime T: type) type {
    return struct {
        const Self = @This();

        rows_n: usize,
        cols_n: usize,
        elements: []const T,

        pub fn Create(rows_n: usize, cols_n: usize) Self {
            return Self{
                .rows_n = rows_n,
                .cols_n = cols_n,
                .elements = &[rows_n * cols_n]T{0},
            };
        }

        pub fn getSize(self: Self) usize {
            return self.rows_n * self.cols_n;
        }

        pub fn lazyPrint(self: Self) !void {
            for (0..self.rows_n) |row_i| {
                for (0..self.cols_n) |col_i| {
                    print("{} ", .{try self.get(row_i, col_i)});
                }
                print("\n", .{});
            }
        }

        pub fn makeScaler(self: *Self, x: T) !void {
            for (0..self.rows_n) |row_i| {
                for (0..self.cols_n) |col_i| {
                    if (row_i == col_i) {
                        try self.set(row_i, col_i, x);
                    } else {
                        try self.set(row_i, col_i, 0);
                    }
                }
            }
        }

        pub fn fill(self: *Self, x: T) void {
            var i: usize = 0;
            while (i < self.getSize()) : (i += 1) {
                self.elements[i] = x;
            }
        }

        pub fn scale(self: *Self, x: T) void {
            for (0..self.getSize()) |i| {
                self.elements[i] *= x;
            }
        }

        pub fn get(self: Self, row_i: usize, col_i: usize) MatrixError!T {
            if (row_i < 0 or col_i < 0 or row_i > self.rows_n - 1 or col_i > self.cols_n - 1) {
                return MatrixError.OutOfBounds;
            }
            return self.elements[row_i * self.cols_n + col_i];
        }

        pub fn set(self: *Self, row_i: usize, col_i: usize, x: T) MatrixError!void {
            if (row_i < 0 or col_i < 0 or row_i > self.rows_n - 1 or col_i > self.cols_n - 1) {
                return MatrixError.OutOfBounds;
            }
            self.elements[row_i * self.cols_n + col_i] = x;
        }

        pub fn getRow(self: Self, row_i: usize) MatrixError![]const T {
            if (row_i < 0 or row_i > self.rows_n - 1) {
                return MatrixError.OutOfBounds;
            }
            var row = &[self.cols_n]T{0};
            for (0..self.cols_n) |col_i| {
                row[col_i] = try self.get(row_i, col_i);
            }
            return row;
        }

        pub fn getCol(self: Self, col_i: usize) MatrixError![]const T {
            if (col_i < 0 or col_i > self.cols_n - 1) {
                return MatrixError.OutOfBounds;
            }
            var col = &[self.rows_n]T{0};
            for (0..self.rows_n) |row_i| {
                col[row_i] = try self.get(row_i, col_i);
            }
            return col;
        }
    };
}

pub inline fn Mat2(comptime T: type) Matrix(T) {
    return Matrix(T).Create(2, 2);
}

pub inline fn Mat3(comptime T: type) Matrix(T) {
    return Matrix(T).Create(3, 3);
}

pub inline fn Mat4(comptime T: type) Matrix(T) {
    return Matrix(T).Create(4, 4);
}

pub fn Add(comptime T: type, m1: Matrix(T), m2: Matrix(T)) MatrixError!Matrix(T) {
    if ((m1.rows_n != m2.rows_n) or (m1.cols_n != m2.cols_n)) {
        return MatrixError.InvalidSize;
    }
    var dest = Matrix(T).Create(m1.rows_n, m1.cols_n);
    for (0..dest.getSize()) |i| {
        dest.elements[i] = m1.elements[i] + m2.elements[i];
    }
    return dest;
}

pub fn MultiplyElementWise(
    comptime T: type,
    m1: Matrix(T),
    m2: Matrix(T),
) MatrixError!Matrix(T) {
    if ((m1.rows_n != m2.rows_n) or (m1.cols_n != m2.cols_n)) {
        return MatrixError.InvalidSize;
    }
    var dest = Matrix(T).Create(m1.rows_n, m1.cols_n);
    for (0..dest.getSize()) |i| {
        dest.elements[i] = m1.elements[i] * m2.elements[i];
    }

    return dest;
}

pub fn Multiply(comptime T: type, m1: Matrix(T), m2: Matrix(T)) MatrixError!Matrix(T) {
    if (m1.cols_n != m2.rows_n) {
        return MatrixError.InvalidSize;
    }
    var dest = Matrix(T).Create(m1.rows_n, m2.cols_n);
    for (0..dest.rows_n) |row_i| {
        for (0..dest.cols_n) |col_i| {
            const relevant_row = try m1.getRow(row_i);
            const relevant_col = try m2.getCol(col_i);

            var element: T = 0;
            for (0..m1.cols_n) |i| {
                element += relevant_row[i] * relevant_col[i];
            }
            try dest.set(row_i, col_i, element);
        }
    }
    return dest;
}

pub fn Trace(comptime T: type, m: Matrix(T)) MatrixError!T {
    if (m.rows_n != m.cols_n) {
        return MatrixError.NotSquare;
    }
    var trace: T = 0;
    for (0..m.rows_n) |i| {
        trace += try m.get(i, i);
    }
    return trace;
}

pub fn Determinant(comptime T: type, m: Matrix(T)) MatrixError!T {
    if (m.rows_n != m.cols_n) {
        return MatrixError.NotSquare;
    }
    if (m.rows_n == 2) {
        return try m.get(0, 0) * try m.get(1, 1) - try m.get(0, 1) * try m.get(1, 0);
    } else {
        var determinant: T = 0;
        for (0..m.cols_n) |i| {
            var cofactor_m = Matrix(T).Create(m.rows_n - 1, m.cols_n - 1);

            for (1..m.rows_n) |row_i| {
                var cofactor_col_i: usize = 0;
                for (0..m.cols_n) |col_i| {
                    if (col_i == i) {
                        continue;
                    }
                    try cofactor_m.set(row_i - 1, cofactor_col_i, try m.get(row_i, col_i));
                    cofactor_col_i += 1;
                }
            }
            if (i % 2 == 0) {
                determinant += try m.get(0, i) * try Determinant(T, cofactor_m);
            } else {
                determinant -= try m.get(0, i) * try Determinant(T, cofactor_m);
            }
        }
        return determinant;
    }
}
