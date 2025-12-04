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

const ROLL = '@';
alias Map = String[];

isz[2][*] dirs = { {-1, -1}, {0, -1}, {1, -1},
                   {-1,  0},          {1,  0},
		   {-1, +1}, {0, +1}, {1, +1} };

fn usz Map.count(&self, usz x, usz y)
{
	long count = 0;
	foreach (d: dirs)
	{
		if (try cell = self.get(x+d[0], y+d[1]))
		{
			if (cell == ROLL) count++;
		}
	}
	return count;
}

faultdef INVALID;
fn char? Map.get(&self, isz x, isz y)
{
	String[] m = *self;
	if (x < 0 || x >= m.len) return INVALID?;
	if (y < 0 || (m.len > 0 && y >= m[0].len)) return INVALID?;
	return m[x][y];
}

fn Map load_map()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif
	return input.tsplit("\n", skip_empty: true);
}

fn long count_rolls(Map m)
{
	long sum = 0;
	foreach (x, row: m) // rows
	{
		if (!row.len) continue;
		foreach (y, cell: row) // cols
		{
			if (cell == ROLL) sum += m.count(x,y) < 4 ? 1 : 0;
		}
	}
	return sum;
}

fn long part1() => count_rolls(load_map());
// fn long part2() => solve(12);
