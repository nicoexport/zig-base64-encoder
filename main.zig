const std = @import("std");

const Base64 = struct {
    _table: *const [64]u8,

    pub fn init() Base64 {
        // range 0 to 25 is represented by: ASCII uppercase letters -> [A-Z];
        // range 26 to 51 is represented by: ASCII lowercase letters -> [a-z];
        // range 52 to 61 is represented by: one digit numbers -> [0-9];
        // index 62 and 63 are represented by the characters + and /, respectively;
        // the character = represents the end of meaningful characters in the sequence;
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers_symb = "0123456789+/";

        return Base64{
            ._table = upper ++ lower ++ numbers_symb,
        };
    }

    pub fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }
};

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    const stdout = &stdout_writer.interface;

    const base64 = Base64.init();

    try stdout.print("Character at index 28: {c}\n", .{base64._char_at(28)});
    try stdout.flush();
}

fn _calc_encode_length(input: []const u8) !usize {
    if (input.len < 3) {
        return 4;
    }
    const n_groups: usize = try std.math.divCeil(usize, input.len, 3);
    return n_groups * 4;
}

fn _calc_decode_length(input: []const u8) !usize {
    if (input.len < 4) {
        return 3;
    }

    const n_groups: usize = try std.math.divFloor(usize, input.len, 4);
    var multiple_groups: usize = n_groups * 3;
    var i: usize = input.len - 1;
    while (i > 0) : (i -= 1) {
        if (input[i] == '=') {
            multiple_groups -= 1;
        } else {
            break;
        }
    }

    return multiple_groups;
}
