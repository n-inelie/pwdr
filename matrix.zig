const std = @import("std");

pub fn Matrix(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Error = error{
            InvalidDimensions,
            IndexOutOfBounds,
        };

        allocator: std.mem.Allocator,
        rows_n: usize,
        cols_n: usize,
        elements: std.ArrayList(T),

        pub inline fn init(allocator: std.mem.Allocator, rows_n: usize, cols_n: usize) !Self {
            var list = try std.ArrayList(T).initCapacity(allocator, rows_n * cols_n);
            list.appendNTimesAssumeCapacity(0, rows_n * cols_n);
            return Self{
                .allocator = allocator,
                .rows_n = rows_n,
                .cols_n = cols_n,
                .elements = list,
            };
        }

        pub inline fn deinit(self: *Self) void {
            self.elements.deinit();
        }

        pub inline fn get(self: Self, row_i: usize, col_i: usize) Self.Error!T {
            if (row_i > self.rows_n or col_i > self.cols_n) {
                return Self.Error.IndexOutOfBounds;
            }
            return self.elements.items[self.cols_n * row_i + col_i];
        }

        pub inline fn set(self: *Self, row_i: usize, col_i: usize, x: T) Self.Error!void {
            if (row_i > self.rows_n or col_i > self.cols_n) {
                return Self.Error.IndexOutOfBounds;
            }
            self.elements.items[self.cols_n * row_i + col_i] = x;
        }

        pub fn print(self: Self) Self.Error!void {
            for (0..self.rows_n) |row_i| {
                for (0..self.cols_n) |col_i| {
                    std.debug.print("{d} ", .{try self.get(row_i, col_i)});
                }
                std.debug.print("\n", .{});
            }
        }

        pub fn fill(self: *Self, x: T) Self.Error!void {
            for (0..self.rows_n) |row_i| {
                for (0..self.cols_n) |col_i| {
                    try self.set(row_i, col_i, x);
                }
            }
        }
    };
}
