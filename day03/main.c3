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

fn String[] load_banks()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif
	return input.tsplit("\n");
}

fn long find_max(String bank)
{
	long max, joltage;
	usz n;

	max = 0;
	n = bank.len;
	for (usz i = 0; i < n - 1; i++)
	{
		for (usz j = i + 1; j < n; j++)
		{
			joltage = 10*(long)(bank[i] - '0') + (long)(bank[j] - '0');
			if (joltage > max) max = joltage;
		}
	}
	return max;
}

fn long part1()
{
	long total = 0;
	foreach (bank: load_banks())
	{
		total += find_max(bank);
	}
	return total;
}

// fn long part2() => load_data(&is_invalid_part2);
