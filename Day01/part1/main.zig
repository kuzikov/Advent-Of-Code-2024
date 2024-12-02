const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();
    const file_path: []const u8 = "input.txt";

    const content = try readFile(allocator, file_path);

    //std.debug.print("{d}\n", .{buffer.len});

    const left_nums = try allocator.alloc(i32, content.len / 14);
    const right_nums = try allocator.alloc(i32, content.len / 14);

    var line_iter = std.mem.splitScalar(u8, content, '\n');

    var i: u16 = 0;
    while (line_iter.next()) |line| {
        var col_iter = std.mem.splitSequence(u8, line, "   ");

        const left_col = col_iter.next();
        const right_col = col_iter.next();

        if ((left_col == null) or (right_col == null)) {
            break;
        }

        const left_int = try std.fmt.parseInt(i32, left_col.?, 10);
        const right_int = try std.fmt.parseInt(i32, right_col.?, 10);

        left_nums[i] = left_int;
        right_nums[i] = right_int;

        i += 1;
    }
    std.mem.sort(i32, left_nums, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right_nums, {}, comptime std.sort.asc(i32));

    var total_dist: u32 = 0;
    for (left_nums, 0..) |left, j| {
        const right = right_nums[j];

        total_dist += @abs(left - right);
    }

    std.debug.print("{any}\n", .{total_dist});
}

pub fn readFile(allocator: std.mem.Allocator, file_path: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(file_path, .{});

    const stat = try file.stat();
    const content = try file.readToEndAlloc(allocator, stat.size);
    return content;
}
