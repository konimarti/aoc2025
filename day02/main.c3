module aoc2025::app;

import std::io;
import std::time;
import std::math;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	io::printfn("result: part 2: %d %s", part2(), c.mark());
}

alias IsInvalidFunc = fn bool(long);
fn long load_data(IsInvalidFunc func)
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
			for (long i = first.to_long()!!; i <= last.to_long()!!; i++)
			{
				if (func(i)) sum += i;
			}
		}
	}
	return sum;
}

fn bool is_invalid_part1(long id)
{
	String tmp = string::tformat("%s", id);
	if (tmp.len % 2 == 1) return false;
	return (tmp[:tmp.len/2] == tmp[tmp.len/2..]);
}

fn bool is_invalid_part2(long id)
{
	String tmp = string::tformat("%s", id);
	for (usz i = 1; i < tmp.len/2 + 1; i++)
	{
		String s = tmp[:i];
		if (tmp.len % i != 0) continue;

		String rem = tmp;
		while (rem.starts_with(s)) rem = rem[i..];
		if (rem.len == 0) return true;
	}
	return false;
}

fn long part1() => load_data(&is_invalid_part1);
fn long part2() => load_data(&is_invalid_part2);
