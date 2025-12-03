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

fn String[] load_banks()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif
	return input.tsplit("\n");
}

fn long dfs(String bank, usz n, usz rem, usz val, long[] memo)
{
	if (n == bank.len || rem == 0) return val;

	// memoization
	if (memo[rem] > val) return 0;
	memo[rem] = val;

	// consider number
	long yes = dfs(bank, n+1, rem-1, 10*val + (long)(bank[n]-'0'), memo);

	// don't consider number
	long no = dfs(bank, n+1, rem, val, memo);

	return (yes > no) ? yes : no;
}

fn long solve(usz n)
{
	long total = 0;
	long[13] memo;
	foreach (bank: load_banks())
	{
		memo[..] = 0;
		total += dfs(bank, 0, n, 0, memo[..]);
	}
	return total;
}

fn long part1() => solve(2);
fn long part2() => solve(12);
