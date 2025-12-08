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
fn double Vec.dist(&self, Vec b)
{
	Vec d = *self - b;
	return math::sqrt(d.dot(d));
}
alias VecList = List{Vec};

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
			dist.push({i, j, coords[i].dist(coords[j])});
		}
	}

	sort::quicksort(dist.array_view(), fn int(Dist a, Dist b){
		if (a.dist < b.dist) return -1;
		if (a.dist > b.dist) return 1;
		return 0;
	});

	$if $feature(TEST):
		usz pairs = 10;
	$else
		usz pairs = 1000;
	$endif

	CircuitList cl; cl.tinit();
	Circuit considered; considered.tinit();
	foreach (i, d: dist)
	{
		if (i == pairs)
		{
			List{long} circuit_length;
			circuit_length.tinit();
			foreach (circuit: cl) circuit_length.push(circuit.len());

			sort::quicksort(circuit_length.array_view());

			io::printfn("part 1: result = %d", circuit_length[^1] * circuit_length[^2] * circuit_length[^3]);
		}

		long x = d.x;
		long y = d.y;
		bool xcons = considered.contains(x);
		bool ycons = considered.contains(y);
		switch
		{
			case xcons && ycons:
				Circuit *xc;
				Circuit *yc;
				foreach (&circuit: cl)
				{
					if (circuit.contains(x)) xc= circuit;
					if (circuit.contains(y)) yc= circuit;
				}
				if (yc!= xc)
				{
					// Merge circuits
					xc.add_all_from(yc);
					yc.clear();
				}

			case xcons:
				// Find circuit where x is and append y
				foreach (&circuit: cl)
				{
					if (circuit.contains(x))
					{
						circuit.add(y);
						considered.add(y);
						break;
					}
				}
			case ycons:
				// Find circuit where y is and append x
				foreach (&circuit: cl)
				{
					if (circuit.contains(y))
					{
						circuit.add(x);
						considered.add(x);
						break;
					}
				}
			default:
				// Create new circuit with x and y
				Circuit new; new.tinit();
				new.add(x);
				new.add(y);
				cl.push(new);
				considered.add(x);
				considered.add(y);
		}
		foreach (c: cl) if (c.len() == coords.len())
		{
			io::printfn("part 2: result = %d", coords[x].x * coords[y].x);
			return;
		}
	}

}
