module aoc2025::app;

import std::io;
import std::time;
import std::collections::list;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	io::printfn("result: part 2: %d %s", part2(), c.mark());
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

fn long max_bank(String bank, usz n)
{
	List{char} l;
	l.tinit();
	long allowed = bank.len - n;
	foreach (i, c: bank)
	{
		while (l.len() && c > l.last()!! && allowed)
		{
			l.pop()!!;
			allowed--;
		}
		l.push(c);
	}
	String res = (String)l.array_view()[:n];
	return res.to_long()!!;
}

fn long solve(usz n)
{
	long total = 0;
	foreach (bank: load_banks())
	{
		if (!bank) continue;
		total += max_bank(bank, n);
	}
	return total;
}

fn long part1() => solve(2);
fn long part2() => solve(12);
