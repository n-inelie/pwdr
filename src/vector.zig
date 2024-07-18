const std = @import("std");
const math = std.math;

pub fn Vector(comptime T: type, comptime Dimensions: usize) type {
    return struct {
        const Self = @This();

        items: std.ArrayList(T),

        pub fn init(allocator: std.mem.Allocator) Self {
            var items = std.ArrayList(T).init(allocator);
            items.appendNTimes(0, Dimensions);
            return .{ .items = items };
        }

        pub fn deinit(self: *Self) void {
            self.items.deinit();
        }
    };
}
