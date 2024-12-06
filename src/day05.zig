const std = @import("std");
const __debug = std.debug.print;
const file_path = "./printer_queue.txt";
const file_content = @embedFile(file_path);

var cache_p1 = std.AutoHashMap([2]i32, bool).init(std.heap.page_allocator);
var cache_p2 = std.AutoHashMap([2]i32, i32).init(std.heap.page_allocator);

pub fn main() !void {
    const total = part1();

    __debug("{any}\n", .{total});
}

pub fn part1() !i64 {
    const rules = try parseRules();

    for (rules) |pair| {
        const a = pair[0];
        const b = pair[1];

        try cache_p1.put(.{ a, b }, true);
        try cache_p1.put(.{ b, a }, false);
    }

    const updates = try parseUpdates();

    var total: i64 = 0;

    main: for (updates) |u| {
        const update = u;
        // if (is_ordered(cache_p1, update)) {
        //     const half: usize = update.len / 2;
        //     total += update[half];
        // }
        for (0..update.len) |i| {
            for (i + 1..update.len) |j| {
                const key = .{ update[i], update[j] };
                if ((cache_p1.get(key)) != null and !cache_p1.get(key).?) {
                    continue :main;
                }
            }
        }
        const half: usize = update.len / 2;
        total += update[half];
    }

    return total;
}

pub fn part2() !i64 {}

pub fn is_ordered(cache: anytype, update: []i32) bool {
    for (0..update.len) |i| {
        for (i + 1..update.len) |j| {
            const key = .{ update[i], update[j] };
            if ((cache.get(key) != null) and !cache.get(key).?) {
                return false;
            }
        }
    }
    return true;
}

pub fn parseRules() ![][2]i32 {
    var sections_it = std.mem.splitSequence(u8, file_content, "\n\n");
    const rules_section = sections_it.next().?;
    var rules_lines = std.mem.splitSequence(u8, rules_section, "\n");

    var parsed_rules = std.ArrayList([2]i32).init(std.heap.page_allocator);
    // try std.heap.page_allocator.free(rules);

    while (rules_lines.next()) |line| {
        var ranges_it = std.mem.splitSequence(u8, line, "|");

        const start_str = ranges_it.next().?;
        const end_str = ranges_it.next().?;

        const start_num = try std.fmt.parseInt(i32, start_str, 10);
        const end_num = try std.fmt.parseInt(i32, end_str, 10);
        try parsed_rules.append(.{ start_num, end_num });
    }

    return parsed_rules.items;
}

pub fn parseUpdates() ![][]i32 {
    var sections_it = std.mem.splitSequence(u8, file_content, "\n\n");

    // SKIP the order rusel.
    _ = sections_it.next().?;

    const updates_section = sections_it.next().?;
    var updates_lines = std.mem.splitSequence(u8, updates_section, "\n");

    var parsed_updates = std.ArrayList([]i32).init(std.heap.page_allocator);
    // try std.heap.page_allocator.free(rules);

    outer: while (updates_lines.next()) |line| {

        // Iterator over a single line of updates.
        var values_it = std.mem.splitSequence(u8, line, ",");

        var buf = std.ArrayList(i32).init(std.heap.page_allocator);
        while (values_it.next()) |value| {
            if (value.len == 0) {
                continue :outer;
            }
            const as_int = try std.fmt.parseInt(i32, value, 10);
            try buf.append(as_int);
        }

        try parsed_updates.append(buf.items);
    }

    return parsed_updates.items;
}

pub fn parseUpdatesFlat() ![]i32 {
    var sections_it = std.mem.splitSequence(u8, file_content, "\n\n");

    // SKIP the order rusel.
    _ = sections_it.next().?;

    const updates_section = sections_it.next().?;
    var updates_lines = std.mem.splitSequence(u8, updates_section, "\n");

    var parsed_updates = std.ArrayList(i32).init(std.heap.page_allocator);
    // try std.heap.page_allocator.free(rules);

    outer: while (updates_lines.next()) |line| {

        // Iterator over a single line of updates.
        var values_it = std.mem.splitSequence(u8, line, ",");

        while (values_it.next()) |value| {
            if (value.len == 0) {
                continue :outer;
            }
            __debug("{s} len{d}\n", .{ value, value.len });
            const as_int = try std.fmt.parseInt(i32, value, 10);
            try parsed_updates.append(as_int);
        }
    }

    return parsed_updates.items;
}
