module aoc2025::app;

import std::io, std::time, std::math;
import std::sort;
import std::collections::list;
import std::collections::set;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	// io::printfn("result: part 2: %d %s", part2(), c.mark());
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

fn long solve(VecList coords)
{
	DistList dist;
	dist.tinit();

	// find distances
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

	// foreach (d : dist) io::printfn("x:%2d y:%2d dist:%.3f", d.x, d.y, d.dist);

	CircuitList cl; cl.tinit();
	Circuit considered; considered.tinit();
	foreach (i, d: dist)
	{
		$if $feature(TEST):
			if (i == 10) break;
		$else
			if (i == 1000) break;
		$endif

		long x = d.x;
		long y = d.y;
		// io::printfn("set     : %s", cl);
		// io::printfn("shortest: %s (%d) and %s (%d)", coords[x], x, coords[y], y);
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
					// merge
					xc.add_all_from(yc);
					yc.clear();
				}

			case xcons:
				// find circuit where x is and append y
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
				// find circuit where y is and append x
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
				// create new circuit with x and y
				Circuit new; new.tinit();
				new.add(x);
				new.add(y);
				cl.push(new);
				considered.add(x);
				considered.add(y);
		}
	}

	io::printfn("finalset: %s", cl);

	// multiply 3 largest circuits
	List{long} circuit_length;
	circuit_length.tinit();
	foreach (circuit: cl) circuit_length.push(circuit.len());
	sort::quicksort(circuit_length.array_view());

	io::printfn("sorted len: %s", circuit_length);

	return circuit_length[^1] * circuit_length[^2] * circuit_length[^3];
}

fn long part1() => solve(load_coords());
// fn long part2() => solve2(load_map());
