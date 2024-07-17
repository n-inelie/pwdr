const std = @import("std");
const print = std.debug.print;

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
        ) !Self {
            var elements = std.ArrayList(T).init(allocator);
            try elements.appendNTimes(0, rows_n * cols_n);
            return Self{
                .rows_n = rows_n,
                .cols_n = cols_n,
                .elements = elements,
                .allocator = allocator,
            };
        }

        pub inline fn deinit(self: *Self) void {
            self.elements.deinit();
        }

        pub inline fn getSize(self: Self) usize {
            return self.rows_n * self.cols_n;
        }

        pub inline fn fill(self: *Self, x: T) void {
            var i: usize = 0;
            while (i < self.getSize()) : (i += 1) {
                self.elements.items[i] = x;
            }
        }
    };
}
