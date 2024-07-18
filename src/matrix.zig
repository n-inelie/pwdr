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
        elements: std.ArrayList(T),
        allocator: std.mem.Allocator,

        pub fn init(
            allocator: std.mem.Allocator,
            rows_n: usize,
            cols_n: usize,
        ) MatrixError!Self {
            var elements = std.ArrayList(T).init(allocator);
            try elements.appendNTimes(0, rows_n * cols_n);
            return Self{
                .rows_n = rows_n,
                .cols_n = cols_n,
                .elements = elements,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.elements.deinit();
        }

        pub fn getSize(self: Self) usize {
            return self.rows_n * self.cols_n;
        }

        pub fn lazyPrint(self: Self) !void {
            var row_i: usize = 0;
            var col_i: usize = 0;
            while (row_i < self.rows_n) : (row_i += 1) {
                col_i = 0;
                while (col_i < self.cols_n) : (col_i += 1) {
                    print("{} ", .{try self.get(row_i, col_i)});
                }
                print("\n", .{});
            }
        }

        pub fn makeScaler(self: *Self, x: T) !void {
            var row_i: usize = 0;
            var col_i: usize = 0;
            while (row_i < self.rows_n) : (row_i += 1) {
                col_i = 0;
                while (col_i < self.cols_n) : (col_i += 1) {
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
                self.elements.items[i] = x;
            }
        }

        pub fn get(self: Self, row_i: usize, col_i: usize) MatrixError!T {
            if (row_i < 0 or col_i < 0 or row_i > self.rows_n - 1 or col_i > self.cols_n - 1) {
                return MatrixError.OutOfBounds;
            }
            return self.elements.items[row_i * self.cols_n + col_i];
        }

        pub fn set(self: *Self, row_i: usize, col_i: usize, x: T) MatrixError!void {
            if (row_i < 0 or col_i < 0 or row_i > self.rows_n - 1 or col_i > self.cols_n - 1) {
                return MatrixError.OutOfBounds;
            }
            self.elements.items[row_i * self.cols_n + col_i] = x;
        }
    };
}

pub fn Add(comptime T: type, allocator: std.mem.Allocator, m1: Matrix(T), m2: Matrix(T)) MatrixError!Matrix(T) {
    if ((m1.rows_n != m2.rows_n) or (m1.cols_n != m2.cols_n)) {
        return MatrixError.InvalidSize;
    }
    var dest = Matrix(T).init(allocator, m1.rows_n, m1.cols_n) catch return MatrixError.OutOfMemory;
    var i: usize = 0;
    while (i < dest.getSize()) : (i += 1) {
        dest.elements.items[i] = m1.elements.items[i] + m2.elements.items[i];
    }
    return dest;
}

pub fn Determinant(comptime T: type, allocator: std.mem.Allocator, m: Matrix(T)) MatrixError!T {
    if (m.rows_n != m.cols_n) {
        return MatrixError.NotSquare;
    }
    if (m.rows_n == 2) {
        return try m.get(0, 0) * try m.get(1, 1) - try m.get(0, 1) * try m.get(1, 0);
    } else {
        var determinant: T = 0;
        var i: usize = 0;
        while (i < m.cols_n) : (i += 1) {
            var cofactor_m = try Matrix(T).init(allocator, m.rows_n - 1, m.cols_n - 1);
            defer cofactor_m.deinit();

            var row_i: usize = 1;
            while (row_i < m.rows_n) : (row_i += 1) {
                var col_i: usize = 0;
                var cofactor_col_i: usize = 0;
                while (col_i < m.cols_n) : (col_i += 1) {
                    if (col_i == i) {
                        continue;
                    }
                    try cofactor_m.set(row_i - 1, cofactor_col_i, try m.get(row_i, col_i));
                    cofactor_col_i += 1;
                }
            }
            if (i % 2 == 0) {
                determinant += try m.get(0, i) * try Determinant(T, allocator, cofactor_m);
            } else {
                determinant -= try m.get(0, i) * try Determinant(T, allocator, cofactor_m);
            }
        }
        return determinant;
    }
}
