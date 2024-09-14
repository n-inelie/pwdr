const std = @import("std");

pub fn Vector(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Error = error{
            InvalidDimensions,
            IndexOutOfBounds,
        };

        allocator: std.mem.Allocator,
        dimensions: usize,
        elements: std.ArrayList(T),

        pub fn init(allocator: std.mem.Allocator, elements: []const T) !Self {
            var list = try std.ArrayList(T).initCapacity(allocator, elements.len);
            try list.appendSlice(elements);
            return Self{
                .allocator = allocator,
                .dimensions = elements.len,
                .elements = list,
            };
        }

        pub inline fn deinit(self: *Self) void {
            self.elements.deinit();
        }

        pub inline fn get(self: Self, index: usize) Self.Error!T {
            if (index > self.dimensions) {
                return Self.Error.IndexOutOfBounds;
            }

            return self.elements.items[index];
        }

        pub inline fn print(self: Self) !void {
            if (self.dimensions == 0) {
                std.debug.print("<EmptyVector>\n", .{});
            }

            std.debug.print("<{d}", .{try self.get(0)});
            for (1..self.dimensions) |i| {
                std.debug.print(", {d}", .{try self.get(i)});
            }
            std.debug.print(">\n", .{});
        }

        pub fn magnitude_squared(self: Self) T {
            var magnitude_squared_output: T = 0;
            for (self.elements.elements) |item| {
                magnitude_squared_output += item * item;
            }
            return magnitude_squared_output;
        }

        pub inline fn magnitude(self: Self) T {
            return @sqrt(self.magnitude_squared());
        }

        pub fn add(allocator: std.mem.Allocator, v1: Vector(T), v2: Vector(T)) !Vector(T) {
            if (v1.dimensions != v2.dimensions) {
                return Self.Error.InvalidDimensions;
            }

            var add_output_elements = try std.ArrayList(T).initCapacity(allocator, v1.dimensions);
            for (0..v1.dimensions) |i| {
                add_output_elements.items[i] = try v1.get(i) + try v2.get(i);
            }

            return Self{
                .allocator = allocator,
                .dimensions = v1.dimensions,
                .elements = add_output_elements,
            };
        }

        pub fn dot_product(v1: Vector(T), v2: Vector(T)) !T {
            if (v1.dimensions != v2.dimensions) {
                return Self.Error.InvalidDimensions;
            }

            var dot_product_output: T = 0;
            for (0..v1.dimensions) |i| {
                dot_product_output += try v1.get(i) * try v2.get(i);
            }

            return dot_product_output;
        }
    };
}
