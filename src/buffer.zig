const std = @import("std");

// pub const BufferError = error{
//     OutOfMemoery,
//     FileNotSupported,
// };

pub const Buffer = struct {
    allocator: *std.mem.Allocator,
    content: []u8,
    line_it: std.mem.SplitIterator(u8, .any),

    pub fn init(allocator: *std.mem.Allocator, content: []const u8) anyerror!Buffer {
        return Buffer{
            .allocator = allocator,
            .content = try allocator.dupe(u8, content),
            .line_it = std.mem.splitAny(u8, content, "\n"),
        };
    }

    pub fn nextLine(self: *Buffer) ?[]const u8 {
        return self.line_it.next();
    }

    pub fn lineReset(self: *Buffer) void {
        self.line_it.index = 0;
    }
};
