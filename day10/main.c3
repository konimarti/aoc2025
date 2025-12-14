module aoc2025::app;

import std::io, std::time, std::math, std::collections;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	// io::printfn("result: part 2: %d %s", part2(), c.mark());
}

alias IntList = List{usz};
alias ButtonList = List{ulong};
alias MachineList = List{Machine};

struct Machine
{
	ulong      num_ind;
	ulong      i; // indicators: [.##.] is stored as '110' with size
	              //  and [...#.] is stored as '2'
	ButtonList b; // buttons
	IntList    j; // joltage
}

fn MachineList load_machines()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif
	MachineList ml;
	ml.tinit();
	foreach (line: input.tsplit("\n", skip_empty: true))
	{
		Machine m;
		m.b.tinit();
		m.j.tinit();
		for (usz i = 0; i < line.len; i++)
		{
			switch (line[i])
			{
				case '[':
					i++;
					while (line[i] != ']')
					{
						m.num_ind++;
						m.i <<= 1;
						if (line[i] == '#') m.i += 1;
						i++;
					}
				case '(':
					ulong button = 0;
					usz start = i;
					while (line[i] != ')') i++;
					String bstr = line[start + 1:(i-start-1)];
					foreach (b: bstr.tsplit(",", skip_empty: true))
					{
						usz index = (usz)b.to_int()!!;
						button ^= (ulong)1<<(m.num_ind-index-1);
					}
					m.b.push(button);
				case '{':
					nextcase;
					// TBD
				default: continue;
			}
		}
		ml.push(m);
	}
	return ml;
}

fn long solve(MachineList machines)
{
	long total = 0;
	foreach (i, m : machines)
	{
		long min = min_button_presses(m);
		io::printfn("Machine %d: %d presses", i, min);
		total += min;
	}
	return total;
}

struct Press
{
	usz   pressed; // Number of presses
	ulong indicator;
}
alias Queue = List{Press};

fn long min_button_presses(Machine m)
{
	long min = 0;
	Queue q;
	q.tinit();
	q.push({0, 0});
	while (try p = q.pop_first())
	{
		if (p.indicator == m.i) return p.pressed;
		foreach (button: m.b)
		{
			if (p.indicator ^ button == m.i) return p.pressed + 1;
			q.push({p.pressed+1, p.indicator ^ button});
		}
	}

	return 0;
}

fn long part1() => solve(load_machines());
// fn long part2() => solve2(load_coords());
