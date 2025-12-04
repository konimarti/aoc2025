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

isz[2][*] dirs = { {-1, -1}, {0, -1}, {1, -1},
                   {-1,  0},          {1,  0},
		   {-1, +1}, {0, +1}, {1, +1} };

faultdef INVALID;
const ROLL = '@';

alias Map = String[];

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

fn char? Map.get(&self, isz x, isz y)
{
	String[] m = *self;
	if (x < 0 || x >= m.len) return INVALID?;
	if (y < 0 || (m.len > 0 && y >= m[0].len)) return INVALID?;
	return m[x][y];
}

fn void Map.remove(&self, isz x, isz y) => (*self)[x][y] = '.';

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

alias Pos = usz[2];
alias Queue = List{Pos};
fn long solve2(Map m)
{
	// Store all rolls in queue
	// Pop off first
	// If accessible, then remove
	// Push neighbors into queue

	Queue q;
	q.tinit();
	foreach (x, row: m) // rows
	{
		if (!row.len) continue;
		foreach (y, cell: row) // cols
		{
			if (cell == ROLL) q.push({x,y});
		}
	}

	long removed = 0;
	while (q.len())
	{
		Pos p = q.pop_first()!!;
		if (try cell = m.get(p[0], p[1]) && cell == ROLL && m.count(p[0], p[1]) < 4)
		{
			m.remove(p[0], p[1]);
			removed++;
			foreach (d: dirs) q.push({p[0] + d[0], p[1] + d[1]});
		}
	}
	return removed;
}

fn long part1() => count_rolls(load_map());
fn long part2() => solve2(load_map());
