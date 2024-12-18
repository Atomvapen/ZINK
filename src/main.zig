const std = @import("std");

const max_height = 24;

pub const BufferError = error{OutofMemory};

pub const Buffer = struct {
    allocator: *std.mem.Allocator,
    content: []u8,
    line_it: std.mem.SplitIterator(u8, .any),

    pub fn init(allocator: *std.mem.Allocator, content: []const u8) !Buffer {
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

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var allocator = arena.allocator();
    const content = try readInput(&allocator);
    var buffer = try Buffer.init(&allocator, content);

    var line_count: u32 = 1;
    while (buffer.nextLine()) |line| : (line_count += 1) {
        if (line_count == max_height) break;
        _ = line;
    }
    const max_line_count_width: u32 = numberWidth(line_count);
    buffer.lineReset();

    line_count = 1;
    while (buffer.nextLine()) |line| : (line_count += 1) {
        if (line_count == max_height) break;
        {
            var i = max_line_count_width - numberWidth(line_count);
            while (i != 0) : (i -= 1) {
                std.debug.print(" ", .{});
            }
        }
        std.debug.print("{d} {s}\n", .{ line_count, line });
    }
}

fn numberWidth(number: u32) u32 {
    var result: u32 = 0;
    var n = number;

    while (n != 0) : (n /= 10) {
        result += 1;
    }
    return result;
}

fn readInput(allocator: *std.mem.Allocator) ![]u8 {
    var arg_it = try std.process.argsWithAllocator(allocator.*);
    defer arg_it.deinit();
    // _ = arg_it.next() orelse unreachable;
    _ = arg_it.skip();

    const file_name = arg_it.next();
    var file_handle = blk: {
        if (file_name) |file_name_delimited| {
            const fName: []const u8 = file_name_delimited;
            break :blk try std.fs.cwd().openFile(fName, .{});
        } else {
            break :blk std.io.getStdIn();
        }
    };

    defer file_handle.close();
    return try file_handle.readToEndAlloc(allocator.*, std.math.maxInt(usize));
}
