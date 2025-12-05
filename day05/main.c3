module aoc2025::app;

import std::io, std::time;
import std::sort;
import std::collections::list;
import std::collections::range;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	io::printfn("result: part 2: %d %s", part2(), c.mark());
}

alias TypeId = long;
alias FreshRange = Range{TypeId};
alias FreshRangeList = List{FreshRange};
alias IdList = List{TypeId};

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
		inv.ranges.push({r[0].to_long()!!, r[1].to_long()!!});
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

fn long solve2(Inventory inv)
{
	sort::quicksort(inv.ranges.array_view(),
		fn int(FreshRange a, FreshRange b) {
			long d = a.start - b.start;
			if (d < 0) return -1;
			if (d > 0) return 1;
			return 0;
		});

	TypeId pivot = 0;
	long count = 0;
	while (try r = inv.ranges.pop_first())
	{
		switch
		{
			case pivot > r.end:   continue;
			case pivot < r.start: break;
			default:              r.start = pivot+1;
		}
		count += r.len();
		pivot = r.end;
	}
	return count;
}

fn long part1() => solve(load_inventory());
fn long part2() => solve2(load_inventory());
