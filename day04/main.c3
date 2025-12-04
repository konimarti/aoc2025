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

faultdef INVALID;
const ROLL = '@';

alias Map = String[];
alias Pos = int[<2>];
alias Queue = List{Pos};

Pos[*] dirs = { {-1,-1}, {0,-1}, {1,-1}, {-1,0}, {1,0}, {-1,1}, {0,1}, {1,1} };

fn usz Map.count(&self, Pos p)
{
	usz count = 0;
	foreach (d: dirs)
	{
		if (try cell = self.get(p+d) && cell == ROLL) count++;
	}
	return count;
}

fn char? Map.get(m, Pos p)
{
	Pos lower_bound = {0, 0};
	Pos upper_bound = {m.len, m.len > 0 ? m[0].len : 0};
	if (p.comp_lt(lower_bound).or() || p.comp_ge(upper_bound).or()) return INVALID?;
	return m[p[0]][p[1]];
}

fn void Map.remove(&self, Pos p) => (*self)[p[0]][p[1]] = '.';

fn Map load_map()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif
	return input.tsplit("\n", skip_empty: true);
}

fn long solve(Map m, bool remove)
{
	Queue q;
	q.tinit();

	foreach (int x, row: m)
	{
		foreach (int y, cell: row)
		{
			if (cell == ROLL) q.push({x,y});
		}
	}

	long count = 0;
	while (try p = q.pop_first())
	{
		if (try cell = m.get(p) && cell == ROLL && m.count(p) < 4)
		{
			if (remove)
			{
				m.remove(p);
				foreach (d: dirs) q.push(p+d);
			}
			count++;
		}
	}
	return count;
}

fn long part1() => solve(load_map(), false);
fn long part2() => solve(load_map(), true);
