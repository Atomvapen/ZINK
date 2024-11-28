const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var arg_it = try std.process.argsWithAllocator(allocator);
    defer arg_it.deinit();
    _ = arg_it.next() orelse unreachable;
    // _ = arg_it.skip();

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
    const content = try file_handle.readToEndAlloc(allocator, std.math.maxInt(usize));
    defer allocator.free(content);

    std.debug.print("{s}", .{content});
}
