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
alias ButtonIndexList = List{IntList};
alias MachineList = List{Machine};

struct Machine
{
	ulong      num_ind;
	ulong      i; // indicators: [.##.] is stored as '110' with size
	              //  and [...#.] is stored as '2'
	ButtonList b; // buttons as ulong
	ButtonIndexList bi; // buttons as indexes
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
		m.bi.tinit();
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
					IntList indexes;
					indexes.tinit();
					while (line[i] != ')') i++;
					String bstr = line[start + 1:(i-start-1)];
					foreach (b: bstr.tsplit(",", skip_empty: true))
					{
						usz index = (usz)b.to_int()!!;
						button ^= (ulong)1<<(m.num_ind-index-1);
						indexes.push(index);
					}
					m.b.push(button);
					m.bi.push(indexes);
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
		io::printfn("Machine %d: %d presses - buttons: %s", i, min, m.bi);
		total += min;
	}
	return total;
}

fn long min_button_presses(Machine m)
{
	long min = long.max;
	ulong ind, len;
	len = m.b.len();
	for (long i = 0; i < (long)(1 << len); i++) // Loop over every combination of buttons
	{
		long press = 0;
		ind = 0;
		for (usz j = 0; j < len; j++) // Loop over the available buttons
		{
			if (((ulong)i & (ulong)(1 << j)) != 0) // Check if this button is "pressed" in the given combination i
			{
				ind ^= m.b[j];
				press++;
			}
		}
		if (ind == m.i)
		{
			if (press < min) min = press;
		}
	}
	return min;
}

fn long solve2(MachineList machines)
{
	long total = 0;
	foreach (i, m : machines)
	{
		long min = min_button_presses(m);
		io::printfn("Machine %d: %d presses - buttons: %s", i, min, m.bi);
		total += min;
	}
	return total;
}

fn long part1() => solve(load_machines());
fn long part2() => solve2(load_machines());
