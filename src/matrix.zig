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
                self.elements.items[i] = x;
            }
        }

        pub fn scale(self: *Self, x: T) void {
            for (0..self.getSize()) |i| {
                self.elements.items[i] *= x;
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

        pub fn getRow(self: Self, allocator: std.mem.Allocator, row_i: usize) MatrixError!std.ArrayList(T) {
            if (row_i < 0 or row_i > self.rows_n - 1) {
                return MatrixError.OutOfBounds;
            }
            var row = std.ArrayList(T).init(allocator);
            for (0..self.cols_n) |col_i| {
                try row.append(try self.get(row_i, col_i));
            }
            return row;
        }

        pub fn getCol(self: Self, allocator: std.mem.Allocator, col_i: usize) MatrixError!std.ArrayList(T) {
            if (col_i < 0 or col_i > self.cols_n - 1) {
                return MatrixError.OutOfBounds;
            }
            var col = std.ArrayList(T).init(allocator);
            for (0..self.rows_n) |row_i| {
                try col.append(try self.get(row_i, col_i));
            }
            return col;
        }
    };
}

pub fn Add(
    comptime T: type,
    allocator: std.mem.Allocator,
    m1: Matrix(T),
    m2: Matrix(T),
) MatrixError!Matrix(T) {
    if ((m1.rows_n != m2.rows_n) or (m1.cols_n != m2.cols_n)) {
        return MatrixError.InvalidSize;
    }
    var dest = Matrix(T).init(allocator, m1.rows_n, m1.cols_n) catch return MatrixError.OutOfMemory;
    for (0..dest.getSize()) |i| {
        dest.elements.items[i] = m1.elements.items[i] + m2.elements.items[i];
    }
    return dest;
}

pub fn MultiplyElementWise(
    comptime T: type,
    allocator: std.mem.Allocator,
    m1: Matrix(T),
    m2: Matrix(T),
) MatrixError!Matrix(T) {
    if ((m1.rows_n != m2.rows_n) or (m1.cols_n != m2.cols_n)) {
        return MatrixError.InvalidSize;
    }
    var dest = Matrix(T).init(allocator, m1.rows_n, m1.cols_n) catch return MatrixError.OutOfMemory;
    for (0..dest.getSize()) |i| {
        dest.elements.items[i] = m1.elements.items[i] * m2.elements.items[i];
    }

    return dest;
}

pub fn Multiply(
    comptime T: type,
    allocator: std.mem.Allocator,
    m1: Matrix(T),
    m2: Matrix(T),
) MatrixError!Matrix(T) {
    if (m1.cols_n != m2.rows_n) {
        return MatrixError.InvalidSize;
    }
    var dest = Matrix(T).init(allocator, m1.rows_n, m2.cols_n) catch return MatrixError.OutOfMemory;
    for (0..dest.rows_n) |row_i| {
        for (0..dest.cols_n) |col_i| {
            const relevant_row = try m1.getRow(allocator, row_i);
            defer relevant_row.deinit();
            const relevant_col = try m2.getCol(allocator, col_i);
            defer relevant_col.deinit();

            var element: T = 0;
            for (0..m1.cols_n) |i| {
                element += relevant_row.items[i] * relevant_col.items[i];
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

pub fn Determinant(comptime T: type, allocator: std.mem.Allocator, m: Matrix(T)) MatrixError!T {
    if (m.rows_n != m.cols_n) {
        return MatrixError.NotSquare;
    }
    if (m.rows_n == 2) {
        return try m.get(0, 0) * try m.get(1, 1) - try m.get(0, 1) * try m.get(1, 0);
    } else {
        var determinant: T = 0;
        for (0..m.cols_n) |i| {
            var cofactor_m = try Matrix(T).init(allocator, m.rows_n - 1, m.cols_n - 1);
            defer cofactor_m.deinit();

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
                determinant += try m.get(0, i) * try Determinant(T, allocator, cofactor_m);
            } else {
                determinant -= try m.get(0, i) * try Determinant(T, allocator, cofactor_m);
            }
        }
        return determinant;
    }
}
