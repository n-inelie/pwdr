const std = @import("std");
const math = std.math;

pub fn Vector(comptime T: type) type {
    return struct {
        const Self = @This();

        elements: []const T,
        dimensions: usize,

        pub fn Create(args: []const T) Self {
            return .{
                .elements = args,
                .dimensions = args.len,
            };
        }

        pub fn magnitudeSquared(self: Self) f32 {
            var magnitude_squared: f32 = 0;
            switch (@typeInfo(T)) {
                .Int => {
                    for (self.elements) |element| {
                        magnitude_squared += @floatFromInt(math.pow(T, element, 2));
                    }
                },
                else => {
                    for (self.elements) |element| {
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

pub inline fn Vector2(comptime T: type, x: T, y: T) Vector(T) {
    return Vector(T).Create(&.{ x, y });
}

pub inline fn Vector3(comptime T: type, x: T, y: T, z: T) Vector(T) {
    return Vector(T).Create(&.{ x, y, z });
}

pub inline fn Vector4(comptime T: type, x: T, y: T, z: T, w: T) Vector(T) {
    return Vector(T).Create(&.{ x, y, z, w });
}
