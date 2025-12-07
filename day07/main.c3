module aoc2025::app;

import std::io, std::time, std::math;
import std::collections::list;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	// io::printfn("result: part 2: %d %s", part2(), c.mark());
}

const SPLITTER = '^';
const BEAM = '|';
const START = 'S';

alias Vec = int[<2>];
alias VecList = List{Vec};
alias Map = String[];

faultdef INVALID;

fn char Map.set(&self, Vec p, char c) => self.[p.x][p.y] = c;
fn char? Map.get(&self, Vec p)
{
	Vec lower_bound = {0, 0};
	Vec upper_bound = {self.len, self.len > 0 ? self.[0].len : 0};
	if (p.comp_lt(lower_bound).or() || p.comp_ge(upper_bound).or()) return INVALID?;
	return self.[p.x][p.y];
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

const Vec DOWN = {-1, 0};

fn long solve(Map m)
{
	VecList q;
	q.tinit();

	// find start and put on queue
	foreach (int x, row: m)
	{
		if (try y = row.index_of_char(START)) q.push({x+1, (int)y});
	}

	long total = 0;
	while (try p = q.pop_first())
	{
		if (try c = m.get(p))
		{
			switch (c)
			{
				case BEAM: continue;
				case SPLITTER:
					total++;
					q.push({p.x,p.y-1});
					q.push({p.x,p.y+1});
				default:
					m.set(p, BEAM);
					q.push({p.x+1,p.y});
			}
		}
	}

	return total;
}

fn long part1() => solve(load_map());
// fn long part2() => solve(load_homework(), true);
