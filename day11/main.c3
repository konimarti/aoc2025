
import std::io, std::time, std::math, std::collections;

fn void main() => @pool()
{
	Clock c = clock::now();
	io::printfn("result: part 1: %d %s", part1(), c.mark());
	io::printfn("result: part 2: %d %s", part2(), c.mark());
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

alias Result = usz[<2>];
alias Memo = HashMap{String, Result};

fn Result dfs(String cur, String end, Connections c, bool dac, Memo *m)
{
	if (cur == end) return dac ? {0, 1} : {1, 0};

	String key = string::tformat("%s-%s", cur, dac);
	if (try result = m.[key]) return result;

	Result r;
	foreach (next: c[cur] ?? (StringList){})
	{
		r += dfs(next, end, c, dac || next == "dac", m);
	}

	m.[key] = r;

	return r;
}

fn long solve(Connections c)
{
	Memo m;
	m.tinit();
	Result svr_fft = dfs("you", "out", c, false, &m);
	return svr_fft.sum();
}

fn long solve2(Connections c)
{
	Memo m;
	m.tinit();
	Result svr_fft = dfs("svr", "fft", c, false, &m);

	m.clear();
	Result fft_out = dfs("fft", "out", c, false, &m);

	return svr_fft[1] * fft_out[0] + svr_fft[0] * fft_out[1];
}

fn long part1() => solve(load_connections());
fn long part2() => solve2(load_connections());
