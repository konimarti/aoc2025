module aoc2025::app;

import std::io;
import std::time;
import std::math;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	// io::printfn("result: part 2: %d %s", part2(), c.mark());
}

fn long load_data()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	long sum = 0;
	foreach (line: input.trim().tsplit(","))
	{
		line = line.trim();
		if (try dash = line.index_of_char('-'))
		{
			String first = line[:dash];
			String last  = line[dash+1..];
			// io::printfn("first: %s, last: %s", first, last);
			for (long i = first.to_long()!!; i <= last.to_long()!!; i++)
			{
				if (is_invalid(i)) sum += i;
			}
		}
	}
	return sum;
}

fn bool is_invalid(long id)
{
	String tmp = string::tformat("%s", id);
	if (tmp.len % 2 == 1) return false;
	// io::printfn("checking: %s (%s == %s)", id, tmp[:tmp.len/2], tmp[tmp.len/2..]);
	return (tmp[:tmp.len/2] == tmp[tmp.len/2..]);
}

fn long part1() => load_data();
// fn long part2() => load_rotations().sum();
