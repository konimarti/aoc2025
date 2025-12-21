module aoc2025::app;

import std::io, std::time, std::math, std::collections;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	// io::printfn("result: part 2: %d %s", part2(), c.mark());
}

alias StringList = List{String};
alias Connections = HashMap{String, StringList};

fn Connections load_connections()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	Connections c;
	c.tinit();
	foreach (line: input.tsplit("\n", skip_empty: true))
	{
		StringList sl;
		sl.tinit();
		String[] items = line.tsplit(": ", 2, skip_empty: true);
		String key = items[0].trim();
		foreach (to: items[1].trim().tsplit(" ", skip_empty: true)) sl.push(to.trim());
		c[key] = sl;
	}
	return c;
}

fn long solve(Connections c)
{
	assert(c.has_key("you"));

	long count;

	StringList q;
	q.tinit();
	q.push("you");

	count = 0;
	while (try next = q.pop())
	{
		if (next == "out")
		{
			count++;
		}
		else if (try list = c[next])
		{
			foreach (l: list) q.push(l);
		}
	}
	return count;
}

fn long part1() => solve(load_connections());
// fn long part2() => solve2(load_machines());
