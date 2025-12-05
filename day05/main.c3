module aoc2025::app;

import std::io, std::time;
import std::collections::list;
import std::collections::range;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	// io::printfn("result: part 2: %d %s", part2(), c.mark());
}

alias Id = ulong;
alias FreshRangeList = List{Range{Id}};
alias IdList = List{Id};

struct Inventory
{
	FreshRangeList ranges;
	IdList         list;
}

fn Inventory load_inventory()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	Inventory inv;
	inv.ranges.tinit();
	inv.list.tinit();

	String[] blocks = input.trim().tsplit("\n\n", 2, true);
	foreach (range: blocks[0].trim().tsplit("\n", skip_empty: true))
	{
		String[] r = range.tsplit("-", 2, skip_empty: true);
		inv.ranges.push({r[0].to_ulong()!!, r[1].to_ulong()!!});
	}

	foreach (id: blocks[1].trim().tsplit("\n", skip_empty: true))
	{
		inv.list.push(id.to_ulong()!!);
	}

	return inv;

}

fn long solve(Inventory inv)
{
	long count = 0;
	while IDLOOP: (try id = inv.list.pop_first())
	{
		foreach (range : inv.ranges)
		{
			if (range.contains(id))
			{
				count++;
				continue IDLOOP;
			}
		}
	}
	return count;
}

fn long part1() => solve(load_inventory());
// fn long part2() => solve(load_map(), true);
