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

        pub fn determinant(self: Self) MatrixError!void {
            if (self.rows_n != self.cols_n) {
                return MatrixError.NotSquare;
            }
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
