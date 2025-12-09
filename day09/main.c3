module aoc2025::app;

import std::io, std::time, std::math, std::collections;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	// io::printfn("result: part 2: %d %s", part2(), c.mark());
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
	return math::abs((a+{1,1}-b));
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

fn long part1() => solve(load_coords());
// fn long part2() => solve(load_map());
