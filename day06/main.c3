module aoc2025::app;

import std::io, std::time;
import std::sort;
import std::collections::list;
import std::collections::range;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	// io::printfn("result: part 2: %d %s", part2(), c.mark());
}
struct Homework
{
	List{long}[4] nums;
	List{char} ops;
	usz nlines;
	usz len;
}
fn Homework load_homework()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
		usz nlines = 3;
	$else
		String input = (String)file::load_temp("input")!!;
		usz nlines = 4;
	$endif

	Homework hw;
	hw.nlines = nlines;

	String[] lines = input.trim().tsplit("\n", skip_empty: true);
	for (usz i = 0; i < nlines; i++)
	{
		hw.nums[i].tinit();
		foreach (num: lines[i].trim().tsplit(" ", skip_empty:true))
		{
			hw.nums[i].push(num.to_long()!!);
		}
	}
	hw.ops.tinit();
	foreach (ops: lines[nlines].trim().tsplit(" ", skip_empty:true))
	{
		assert (ops.len == 1);
		hw.ops.push(ops[0]);
	}
	hw.len = hw.ops.len();

	for (usz i = 0; i < nlines; i++) assert(hw.nums[i].len() == hw.len);
	return hw;
}

alias OpType = long;
alias OpFn = fn OpType(OpType acc, OpType elem);

fn OpType add(OpType acc, OpType elem) => acc + elem;
fn OpType mul(OpType acc, OpType elem) => acc * elem;

fn OpFn get_opts(char c, long *init)
{
	switch (c)
	{
		case '+': *init = 0; return &add;
		case '*': *init = 1; return &mul;
		default: unreachable();
	}
}

fn long solve(Homework hw)
{
	long total, sum;
	total = 0;
	foreach (i, op: hw.ops)
	{
		OpFn opf = get_opts(op, &sum);
		for (usz j = 0; j < hw.nlines; j++) sum = opf(sum, hw.nums[j][i]);
		total += sum;
	}
	return total;
}

fn long part1() => solve(load_homework());
// fn long part2() => solve2(load_inventory());
