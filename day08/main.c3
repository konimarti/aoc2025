module aoc2025::app;

import std::io, std::time, std::math;
import std::sort;
import std::collections::list;
import std::collections::set;

fn void main() => @pool()
{
	solve(load_coords());
}

alias Vec = double[<3>];
alias VecList = List{Vec};

fn double calc_dist(Vec a, Vec b) => math::sqrt((a-b).dot(a-b));

fn VecList load_coords()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif
	VecList l;
	l.tinit();
	foreach (line: input.tsplit("\n", skip_empty: true))
	{
		String[] xyz = line.tsplit(",");
		if (xyz.len != 3) continue;
		l.push({xyz[0].to_double()!!, xyz[1].to_double()!!, xyz[2].to_double()!!});
	}
	return l;
}

alias Circuit = HashSet{long};
alias CircuitList = List{Circuit};

struct Dist
{
	usz x;
	usz y;
	double dist;
}
fn int Dist.compare_to(a, Dist b) => a.dist < b.dist ? -1 : (a.dist > b.dist ? 1 : 0);
alias DistList = List{Dist};

fn void solve(VecList coords)
{
	DistList dist;
	dist.tinit();

	// Calculate distances for each pair
	for(usz i = 0; i < coords.len() - 1; i++)
	{
		for(usz j = i + 1; j < coords.len(); j++)
		{
			dist.push({i, j, calc_dist(coords[i],coords[j])});
		}
	}
	sort::quicksort(dist.array_view());

	$if $feature(TEST):
		usz pairs = 10;
	$else
		usz pairs = 1000;
	$endif

	CircuitList cl; cl.tinit();
	Circuit* xc, yc;
	foreach (i, d: dist)
	{
		xc = null; yc = null;
		foreach (&c: cl)
		{
			if (c.contains(d.x)) xc = c;
			if (c.contains(d.y)) yc = c;
		}

		switch
		{
			case xc && yc && xc == yc: break;
			case xc && yc && xc != yc: xc.add_all_from(yc); yc.clear();
			case xc != null: xc.add(d.y);
			case yc != null: yc.add(d.x);
			default:
				Circuit new;
				new.tinit_with_values(d.x, d.y);
				cl.push(new);
		}

		if (i+1 == pairs)
		{
			usz[] len = mem::temp_array(usz, cl.len());
			foreach (j, c: cl) len[j] = c.len();
			sort::quicksort(len);
			io::printfn("part 1: result = %d", len[^1]*len[^2]*len[^3]);
		}

		foreach (c: cl) if (c.len() == coords.len())
		{
			io::printfn("part 2: result = %d", coords[d.x].x * coords[d.y].x);
			return;
		}
	}
}
