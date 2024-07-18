const std = @import("std");
const math = std.math;

pub fn Vector(comptime T: type) type {
    return struct {
        const Self = @This();

        elements: std.ArrayList(T),
        dimensions: usize,

        pub fn init(allocator: std.mem.Allocator, args: []const T) !Self {
            var elements = std.ArrayList(T).init(allocator);
            for (args) |arg| {
                try elements.append(arg);
            }
            return .{
                .elements = elements,
                .dimensions = elements.items.len,
            };
        }

        pub fn deinit(self: *Self) void {
            self.elements.deinit();
        }

        pub fn magnitudeSquared(self: Self) f32 {
            var magnitude_squared: f32 = 0;
            switch (@typeInfo(T)) {
                .Int => {
                    for (self.elements.items) |element| {
                        magnitude_squared += @floatFromInt(math.pow(T, element, 2));
                    }
                },
                else => {
                    for (self.elements.items) |element| {
                        magnitude_squared += @floatCast(math.pow(T, element, 2));
                    }
                },
            }
            return magnitude_squared;
        }

        pub fn magnitude(self: Self) f32 {
            return math.sqrt(self.magnitudeSquared());
        }
    };
}
