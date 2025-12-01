module aoc2025::app;

import std::io;
import std::time;
import std::math;
import std::collections::list;

fn void main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		// io::printfn("result: part 2: %d %s", part2(), c.mark());
	};
}

fn long load_rotations()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	long pos = 50;
	long sign = 1;
	long ret = 0;
	foreach (line: input.trim().tsplit("\n"))
	{
		if (!line.len) continue;
		switch (line[0])
		{
			case 'L': sign = -1;
			case 'R': sign = +1;
			default: unreachable();
		}
		pos += sign * line[1..].to_long()!!;
		if (pos % 100 == 0) ret++;
	}
	return ret;
}

fn long part1() => load_rotations();
