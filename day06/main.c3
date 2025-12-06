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

char[4000][4] table;

alias OpType = long;
alias Accumulator = fn OpType(OpType, OpType);

fn OpType add(OpType acc, OpType elem) => acc + elem;
fn OpType mul(OpType acc, OpType elem) => acc * elem;

struct Block
{
	Slice2d{char} c;
	Accumulator   a;
	OpType        s;
}

alias Homework = List{Block};

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
	hw.tinit();

	String[] lines = input.tsplit("\n", skip_empty: true);
	foreach (row, line: lines[:nlines])
	{
		foreach (col, cell: line) table[row][col] = cell;
	}
	usz len;
	foreach (col, ops: lines[nlines])
	{
		if (ops == ' ') continue;
		len = 1;
		while (col+len < lines[nlines].len && lines[nlines][col+len] == ' ') len++;
		hw.push({
			.c = array::slice2d(&table, col, len, 0, nlines),
			.a = ops == '+' ? &add : &mul,
			.s = ops == '+' ? 0 : 1,
		});
	}
	return hw;
}

fn long solve(Homework hw, bool vert = false)
{
	long total = 0;
	foreach (block: hw)
	{
		if (!vert)
		{
			foreach (row: block.c)
			{
				if (try num = ((String)row).trim().to_long())
				{
					block.s = block.a(block.s, num);
				}
			}
		}
		else // part 2
		{
			char[4] col;
			for (usz ncol = 0; ncol < block.c.xlen; ncol++)
			{
				block.c.@each(; pos, c)
				{
					if (pos.x == ncol) col[pos.y] = c;
				};
				if (try num = ((String)col[..]).trim().to_long())
				{
					block.s = block.a(block.s, num);
				}
			}
		}
		total += block.s;
	}
	return total;
}

fn long part1() => solve(load_homework());
fn long part2() => solve(load_homework(), true);
