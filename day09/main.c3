module aoc2025::app;

import std::io, std::time, std::math, std::collections;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	io::printfn("result: part 2: %d %s", part2(), c.mark());
}

alias Vec = long[<2>];
alias VecList = List{Vec};

fn VecList load_coords()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif
	VecList list;
	list.tinit();
	foreach (line: input.tsplit("\n", skip_empty: true))
	{
		String[] coords = line.tsplit(",", skip_empty: true);
		list.push({coords[0].to_long()!!, coords[1].to_long()!!});
	}
	return list;
}

fn Vec manhattan_distance(Vec a, Vec b) {
	int x = (int)math::abs(a[0] - b[0]) + 1;
	int y = (int)math::abs(a[1] - b[1]) + 1;
	return {x, y};
}

fn long solve(VecList coords)
{
	long area = 0;
	for (usz i = 0; i < coords.len() - 1; i++)
	{
		for (usz j = i + 1; j < coords.len(); j++)
		{
			Vec m = manhattan_distance(coords[i], coords[j]);
			if (m.x * m.y > area) area = m.x * m.y;
		}
	}
	return area;
}

fn Vec[2] norm(Vec[2] a)
{
	long xmin, ymin, xmax, ymax;
	xmin = min(a[0].x, a[1].x);
	ymin = min(a[0].y, a[1].y);
	xmax = max(a[0].x, a[1].x);
	ymax = max(a[0].y, a[1].y);
	return {{xmin,ymin},{xmax,ymax}};
}

fn bool overlap(Vec[2] a, Vec[2] b)
{
	return (a[0].x < b[1].x && a[1].x > b[0].x && a[0].y < b[1].y && a[1].y > b[0].y);
}

fn bool intersect(Vec[2] line, Edges *edges)
{
	Vec[2] a = norm(line);
	foreach (e: edges)
	{
		if (overlap(a, e)) return true;
	}
	return false;
}

alias Edges = List{Vec[2]};

// FIXME: too low: 1624020900

fn long solve2(VecList coords)
{
	Edges e;
	e.tinit();

	coords.push(coords[0]);
	for (usz i = 0; i < coords.len() - 1; i++)
	{
		usz j = i + 1;
		e.push(norm({coords[i], coords[j]}));
		// io::printfn("add edge: %s", e.last()!!);
	}
	coords.pop()!!;

	long area = 0;
	for (usz i = 0; i < coords.len() - 1; i++)
	{
		for (usz j = i + 1; j < coords.len(); j++)
		{
			if (intersect({coords[i],coords[j]}, &e)) continue;
			Vec m = manhattan_distance(coords[i], coords[j]);
			if (m.x * m.y > area)
			{
				area = m.x * m.y;
				io::printn("SELECTED:");
				io::printfn("a = %s", coords[i]);
				io::printfn("b = %s", coords[j]);
				io::printfn("area = %s", area);
			}
		}
	}
	return area;
}

fn long part1() => solve(load_coords());
fn long part2() => solve2(load_coords());
