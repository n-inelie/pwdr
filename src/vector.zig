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

pub inline fn Vector2i(x: i32, y: i32) Vector(i32) {
    return Vector(f32).Create(&.{ x, y });
}

pub inline fn Vector3i(x: i32, y: i32, z: i32) Vector(i32) {
    return Vector(i32).Create(&.{ x, y, z });
}

pub inline fn Vector4i(x: i32, y: i32, z: i32, w: i32) Vector(i32) {
    return Vector(i32).Create(&.{ x, y, z, w });
}

pub inline fn Vector2f(x: f32, y: f32) Vector(f32) {
    return Vector(f32).Create(&.{ x, y });
}

pub inline fn Vector3f(x: f32, y: f32, z: f32) Vector(f32) {
    return Vector(f32).Create(&.{ x, y, z });
}

pub inline fn Vector4f(x: f32, y: f32, z: f32, w: f32) Vector(f32) {
    return Vector(f32).Create(&.{ x, y, z, w });
}
