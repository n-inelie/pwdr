const std = @import("std");
const math = std.math;

pub fn Vector2(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,

        pub inline fn init(
            x: T,
            y: T,
        ) Self {
            return .{
                .x = x,
                .y = y,
            };
        }

        pub fn magnitudeSquared(self: Self) T {
            return math.pow(T, self.x, 2) + math.pow(T, self.y, 2);
        }

        pub fn magnitude(self: Self) f32 {
            var m: f32 = undefined;
            switch (@typeInfo(T)) {
                .Int => m = @floatFromInt(self.magnitudeSquared()),
                else => m = @floatCast(self.magnitudeSquared()),
            }

            return math.sqrt(m);
        }
    };
}
