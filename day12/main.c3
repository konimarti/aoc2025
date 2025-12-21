module aoc2025::app;

import std::io, std::time, std::math, std::collections;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	// io::printfn("result: part 2: %d %s", part2(), c.mark());
}

const N = 6;
alias Present = char[3][3];
Present[N] presents;

struct Region
{
	long    w;
	long    l;
	long[N] num;
}

fn Region[] load_regions()
{
	$if $feature(TEST):
		String input = (String)file::load_temp("input_test")!!;
	$else
		String input = (String)file::load_temp("input")!!;
	$endif

	String[] lines = input.tsplit("\n", skip_empty: true);

	usz lineno = 1;
	for (usz n = 0; n < (usz)N; n++)
	{
		Present p;
		for (usz i = 0; i < 3; i++)
		{
			for (usz j = 0; j < 3; j++)
			{
				// io::printfn("i=%d, j=%d, input=%c", i, j, lines[lineno+i][j]);
				p[i][j] = lines[lineno+i][j] == '#' ? 1 : 0;
			}
		}
		presents[n] = p;
		lineno += 4;
	}

	List{Region} l;
	l.tinit();
	foreach (line: lines[lineno-1..])
	{
		String[] r = line.tsplit(": ", 2, skip_empty: true);
		String[] xy = r[0].tsplit("x", 2, skip_empty: true);

		long[N] nums;
		foreach (i, n: r[1].tsplit(" ", skip_empty: true))
		{
			nums[i] = n.trim().to_long()!!;
		}

		l.push({ xy[0].to_long()!!, xy[1].to_long()!!, nums });
	}

	return l.array_view();
}

alias Parity = long[<2>];

fn Parity count_parity(Present p)
{
	Parity parity;
	for (usz i = 0; i < 3; i++)
	{
		for (usz j = 0; j < 3; j++)
		{
			if (p[i][j] != 1) continue;
			parity += ((i * 3 + j) % 2 == 0) ? {1, 0} : {0, 1};
		}
	}
	return parity;
}

fn long solve(Region[] regs)
{
	long fit, area;

	Parity[N] parity;
	foreach (i, &p: parity) *p = count_parity(presents[i]);

	fit = 0;
	foreach (r: regs)
	{
		area = r.w * r.l;
		Parity a = {area/2, area/2};
		foreach (i, n: r.num) a -= n * parity[i];
		if (a[0] > 0 && a[1] > 0) fit++;
	}

	return fit;
}

fn long part1() => solve(load_regions());
fn long part2() => solve(load_regions());
