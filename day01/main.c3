module aoc2025::app;

import std::io;
import std::time;
import std::math;

fn void main()
{
	@pool()
	{
		Clock c = clock::now();
		io::printfn("result: part 1: %d %s", part1(), c.mark());
		io::printfn("result: part 2: %d %s", part2(), c.mark());
	};
}

struct Result
{
	long after;
	long during;
}
fn long Result.sum(&self) => self.after + self.during;

fn Result load_rotations()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	Result r = {0, 0};
	long pos = 50;
	long sign = 1;
	long rot;
	foreach (line: input.trim().tsplit("\n"))
	{
		if (!line.len) continue;
		switch (line[0])
		{
			case 'L': sign = -1;
			case 'R': sign = +1;
			default: unreachable();
		}
		rot = line[1..].to_long()!!;
		while (rot--)
		{
			pos += sign;
			switch (pos)
			{
				case 100: pos = 0;
				case -1:  pos = 99;
			}
			if (rot > 0 && pos == 0) r.during++;
		}
		if (pos == 0) r.after++;
	}
	return r;
}

fn long part1() => load_rotations().after;
fn long part2() => load_rotations().sum();
