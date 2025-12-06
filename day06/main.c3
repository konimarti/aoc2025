module aoc2025::app;

import std::io, std::time, std::math;
import std::sort;
import std::collections::list;
import std::collections::range;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	io::printfn("result: part 2: %d %s", part2(), c.mark());
}
struct Homework
{
	List{long}[4] nums;
	List{char} ops;
	usz nlines;
	usz len;

	String[] table;
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

	hw.table = input.trim().tsplit("\n", skip_empty: true);
	for (usz i = 0; i < nlines; i++)
	{
		hw.nums[i].tinit();
		foreach (num: hw.table[i].trim().tsplit(" ", skip_empty:true))
		{
			hw.nums[i].push(num.to_long()!!);
		}
	}
	hw.ops.tinit();
	foreach (ops: hw.table[nlines].trim().tsplit(" ", skip_empty:true))
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

fn usz num_digits(long num) => (long)math::log((double)num, 10) + 1;

fn long solve2(Homework hw)
{
	List{usz} startpos;
	startpos.tinit();
	startpos.push(0);
	foreach (i, c: hw.table[0])
	{
		if (c != ' ') continue;
		bool col = true;
		for (usz j = 0; j < hw.nlines; j++) col = col && hw.table[j][i] == ' ';
		if (col) startpos.push(i+1);
	}

	long total, sum;
	usz cols;
	total = 0;
	foreach (i, op: hw.ops)
	{
		cols = 0;
		for (usz j = 0; j < hw.nlines; j++)
		{
			usz ndigits = num_digits(hw.nums[j][i]);
			if (ndigits > cols) cols = ndigits;
		}

		OpFn opf = get_opts(op, &sum);

		usz start = startpos[i];
		for (usz y = start; y < start + cols; y++)
		{
			long num = 0;
			for (usz x = 0; x < hw.nlines; x++)
			{
				char c = hw.table[x][y];
				if (num > 0 && c == ' ') break;
				num *= 10;
				if (ascii::is_digit(c)) num += (long)(c - '0');
			}
			sum = opf(sum, num);
		}
		total += sum;
	}
	return total;
}

fn long part1() => solve(load_homework());
fn long part2() => solve2(load_homework());
