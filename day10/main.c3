module aoc2025::app;

import std::io, std::time, std::math, std::collections;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	io::printfn("result: part 2: %d %s", part2(), c.mark());
}

alias IntList = List{long};
alias ButtonList = List{long};
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
					String rem = line[i+1..].trim().strip_end("}");
					foreach (num: rem.tsplit(",")) m.j.push(num.to_int()!!);
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
		long min = min_button_presses(m, m.i);
		// io::printfn("Machine %d: %d presses - buttons: %s", i, min, m.bi);
		total += min;
	}
	return total;
}

fn long min_button_presses(Machine m, ulong mi, HashMap{long, long} *comb = null)
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
		if (ind == mi)
		{
			if (press < min) min = press;
			if (comb) comb.[i] = press;
		}
	}
	return min >= long.max ? 0 : min;
}

fn long solve2(MachineList machines)
{
	long total = 0;
	foreach (i, m : machines)
	{
		long min = min_joltage_presses(m, m.j.to_tarray()) ?? -99;
		// io::printfn("Machine %d: %d presses", i, min);
		total += min;
	}
	return total;
}

fn long? min_joltage_presses(Machine m, long[] joltage)
{
	// Parity check: x = b + 2k (x key presses)
	ulong mi;
	bool done = true;
	foreach (ulong i, jolt: joltage)
	{
		done = done && jolt == 0;
		if (jolt % 2 == 1) mi ^= (ulong)(1 << (m.num_ind-i-1));
	}
	if (done) return 0;

	HashMap{long, long} combinations;
	combinations.tinit();
	(void)min_button_presses(m, mi, &combinations);

	List{long} min_press;
	min_press.tinit();

	long[] next_joltage = mem::temp_array(long, joltage.len);

	// Try all combinations
	combinations.@each(; long c, long presses)
	{
		next_joltage[..] = joltage[..];

		// "Press" buttons and adjust joltage
		foreach (i, buttons: m.bi)
		{
			if ((c & (long)(1<<i)) != 0)
			{
				foreach (j: buttons) next_joltage[j]--;
			}
		}

		// Check for invalid joltage (e.g. negative)
		bool invalid = false;
		foreach (jolt: next_joltage) invalid = invalid || jolt < 0;
		if (!invalid)
		{
			// Check all joltages should be even now
			// io::printfn("joltage even = %s", next_joltage);

			// Bifurcate (e.g. half it)
			foreach (&jolt: next_joltage) *jolt /= 2;
			// io::printfn("joltage half = %s", next_joltage);

			if (try next_press = min_joltage_presses(m, next_joltage))
			{
				min_press.push(presses + 2 * next_press);
			}
		}
	};

	if (min_press.len() == 0) return NOT_FOUND?;

	long min = min_press[0];
	foreach (press: min_press) min = (press < min) ? press : min;
	return min;
}

fn long part1() => solve(load_machines());
fn long part2() => solve2(load_machines());
