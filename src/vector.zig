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
                .Float => {
                    for (self.elements) |element| {
                        magnitude_squared += @floatCast(math.pow(T, element, 2));
                    }
                },
                else => {
                    //TODO
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

pub fn distanceSquared(comptime T: type, v1: Vector(T), v2: Vector(T)) f32 {
    var distance_squared: f32 = 0;
    switch (@typeInfo(T)) {
        .Int => {
            for (v1.elements, v2.elements) |element1, element2| {
                distance_squared += @floatFromInt(math.pow(T, element1 - element2, 2));
            }
        },
        .Float => {
            for (v1.elements, v2.elements) |element1, element2| {
                distance_squared += @floatCast(math.pow(T, element1 - element2, 2));
            }
        },
        else => {
            // TODO
        },
    }
    return distance_squared;
}

pub inline fn distance(comptime T: type, v1: Vector(T), v2: Vector(T)) f32 {
    return math.sqrt(distanceSquared(T, v1, v2));
}
