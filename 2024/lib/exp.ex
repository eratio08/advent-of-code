defmodule Exp do
  @doc ~S"""
  Parses a single character.

  ## Example
  iex> import Exp
  iex> item().("abc")
  [{"a", "bc"}]
  """
  def item() do
    fn
      "" ->
        []

      cs ->
        [String.split_at(cs, 1)]
    end
  end

  @doc ~S"""
  Combinator, returns a parser return `a`.

  ## Example
  iex> import Exp
  iex> return("a").("bc")
  [{"a", "bc"}]
  """
  def return(a) do
    fn cs -> [{a, cs}] end
  end

  @doc ~S"""
  Combinator to transform a parser `p` by applying `f`.
  `f` has to return a new parser.

  ## Example
  iex> import Exp
  iex> bind(item(), fn c -> return("#{c}ba") end).("abc")
  [{"aba", "bc"}]
  """
  def bind(p, f) do
    fn cs -> p.(cs) |> Enum.flat_map(fn {a, cs} -> f.(a).(cs) end) end
  end

  @doc ~S"""
  Combinator, infix variant of `bind`.

  ## Example
  iex> import Exp
  iex> item() ~>> fn c -> return("#{c}ba") end.("abc")
  """
  def p ~>> f do
    bind(p, f)
  end

  @doc ~S"""
  Combinator to transform parser `p` by appluing `f`.

  ## Example
  iex> import Exp
  iex> map(item(), fn c -> "#{c}bc" end).("abc")
  [{"abc", "bc"}]
  """
  def map(p, f) do
    fn cs -> p.(cs) |> Enum.map(fn {c, cs} -> {f.(c), cs} end) end
  end

  @doc ~S"""
  Combinator, infxi variant of `map`.

  ## Example
  iex> import Exp
  iex> (item() >>> fn c -> "#{c}bc" end).("abc")
  [{"abc", "bc"}]
  """
  def p >>> f do
    map(p, f)
  end

  @doc ~S"""
  Combinator, lifts unary function `f` and applies it to the result of parser `p`.

  ## Example
  iex> import Exp
  iex> (lift(fn c -> "#{c}bc" end,item())).("abc")
  [{"abc", "bc"}]
  """
  def lift(f, p) do
    p >>> f
  end

  @doc ~S"""
  Combinator, lifts binary function `f` and applies it to the result of parser `p1` and `p2`.

  ## Example
  iex> import Exp
  iex> (lift2(fn a, b -> "#{a}#{b}bc" end,item(),item())).("abc")
  [{"abbc", "c"}]
  """
  def lift2(f, p1, p2) do
    p1 ~>> fn r1 -> p2 ~>> fn r2 -> return(f.(r1, r2)) end end
  end

  @doc ~S"""
  Create a failed parser.

  ## Example
  iex> import Exp
  iex> (zero() >>> fn x -> "#{x}bc" end).("abc")
  []
  """
  def zero() do
    fn _ -> [] end
  end

  @doc ~S"""
  Combinator, uses `p` and `q` to parse the input, both outputs are collected into the output list.

  ## Example
  iex> import Exp
  iex> and_(item(), return("d")).("abc")
  [{"a", "bc"}, {"d","abc"}]
  """
  def and_(p, q) do
    fn cs -> p.(cs) ++ q.(cs) end
  end

  @doc ~S"""
  Combinator, infix variant of `and_`.

  ## Example
  iex> import Exp
  iex> (item() &&& return("d")).("abc")
  [{"a", "bc"}, {"d","abc"}]
  """
  def p &&& q do
    and_(p, q)
  end

  @doc ~S"""
  Combinator, uses `p` to parse the input, if `p` fails `q` is used to parse the input.

  ## Example
  iex> import Exp
  iex> or_(zero(), return("d")).("abc")
  [{"d","abc"}]
  """
  def or_(p, q) do
    fn cs ->
      case p.(cs) do
        [] -> q.(cs)
        r -> r
      end
    end
  end

  @doc ~S"""
  Combinator, infix variant of `or_`.

  ## Example
  iex> import Exp
  iex> (zero() ||| return("d")).("abc")
  [{"d","abc"}]
  iex> (char("a") ||| return("d")).("abc")
  [{"a","bc"}]
  """
  def p ||| q do
    or_(p, q)
  end

  @doc ~S"""
  Creates a parser that parses input that statisfies the predicate `p`.

  ## Example
  iex> import Exp
  iex> sat(fn c -> c == "a" end).("abc")
  [{"a","bc"}]
  """
  def sat(p) do
    item()
    ~>> fn c ->
      if p.(c) do
        return(c)
      else
        zero()
      end
    end
  end

  @doc ~S"""
  Creates a parser that parses the given charactet `c`.

  ## Example
  iex> import Exp
  iex> char("a").("abc")
  [{"a","bc"}]
  """
  def char(c) do
    sat(fn c2 -> c == c2 end)
  end

  def string("") do
    return("")
  end

  @doc ~S"""
  Creates a parser that parses the given string `s`.

  ## Example
  iex> import Exp
  iex> string("ab").("abc")
  [{"ab","c"}]
  """
  def string(s) do
    {c, cs} = String.split_at(s, 1)
    char(c) ~>> fn a -> string(cs) ~>> fn as -> return(List.to_string([a | as])) end end
  end

  @doc ~S"""
  Combinator, matches parser `p` 0 or many times resulting in a list of matches.

  ## Example
  iex> import Exp
  iex> many(char("a")).("aac")
  [{["a", "a"], "c"}]
  iex> many(char("a")).("caa")
  [{[], "caa"}]
  """
  def many(p) do
    many1(p) ||| return([])
  end

  defp cons(x, xs) do
    [x | xs]
  end

  @doc ~S"""
  Combinator, matches parser `p` exactly `n` times.

  ## Example
  iex> import Exp
  iex> count(3,char("a")).("aaa")
  [{["a", "a", "a"], ""}]
  iex> count(4,char("a")).("aaa")
  []
  """
  def count(n, p) do
    case n do
      0 -> return([])
      n -> lift2(&cons/2, p, count(n - 1, p))
    end
  end

  @doc ~S"""
  Combinator, matches parser `p` 1 or many times resulting in a list of matches.

  ## Example
  iex> import Exp
  iex> many1(char("a")).("aac")
  [{["a", "a"], "c"}]
  iex> many1(char("a")).("caa")
  []
  """
  def many1(p) do
    p ~>> fn a -> many(p) ~>> fn as -> return([a | as]) end end
  end

  @doc ~S"""
  Combinator, matches parser `p` 0 or many times separated by parser `p_sep`, returning only matches of `p`.

  ## Example
  iex> import Exp
  iex> sepby(item(), char(",")).("a,a,c")
  [{["a", "a", "c"], ""}]
  iex> sepby(item(), char(",")).("aa,a,c")
  [{["a"], "a,a,c"}]
  iex> sepby(char("z"), char(",")).("a,a,c")
  [{[], "a,a,c"}]
  """
  def sepby(p, p_sep) do
    sepby1(p, p_sep) ||| return([])
  end

  @doc ~S"""
  Combinator, matches parser `p` 1 or many times separated by parser `p_sep`, returning only matches of `p`.

  ## Example
  iex> import Exp
  iex> sepby1(item(), char(",")).("a,a,c")
  [{["a", "a", "c"], ""}]
  iex> sepby1(char("z"), char(",")).("a,a,c")
  []
  """
  def sepby1(p, p_sep) do
    p ~>> fn a -> many(p_sep ~>> fn _ -> p end) ~>> fn as -> return([a | as]) end end
  end

  @doc ~S"""
  Combinator, matches parser `p` 0 or many times separated by parser `op`, will apply the result of `p` to the result of `op`.

  ## Example
  iex> import Exp
  iex> number_one_p = char("1") ~>> fn x -> return(String.to_integer(x)) end
  iex> addition_p = char("+") ~>> fn _ -> return(fn a, b -> a + b end) end
  iex> chain(number_one_p, addition_p, 0).("1+1+1")
  [{3, ""}]
  iex> chain(number_one_p, addition_p, 0).("2+1+1")
  [{0, "2+1+1"}]
  """
  def chain(p, op, a) do
    chain1(p, op) ||| return(a)
  end

  @doc ~S"""
  Combinator, matches parser `p` 1 or many times separated by parser `op`, will apply the result of `p` to the result of `op`.

  ## Example
  iex> import Exp
  iex> number_one_p = char("1") ~>> fn x -> return(String.to_integer(x)) end
  iex> addition_p = char("+") ~>> fn _ -> return(fn a, b -> a + b end) end
  iex> chain(number_one_p, addition_p, 0).("1+1+1")
  [{3, ""}]
  """
  def chain1(p, op) do
    p ~>> fn a -> rest(p, op, a) end
  end

  defp rest(p, op, a) do
    op ~>> fn f -> p ~>> fn b -> rest(p, op, f.(a, b)) end end ||| return(a)
  end

  @doc ~S"""
  Lexical Parser that matches whitespace.

  ## Example
  iex> import Exp
  iex> space().(" abc")
  [{[" "], "abc"}]
  iex> space().("   abc")
  [{[" ", " ", " "], "abc"}]
  """
  def space() do
    many(sat(&is_space/1))
  end

  defp is_space(c) do
    case c do
      " " ->
        true

      "\t" ->
        true

      "\n" ->
        true

      "\r" ->
        true

      _ ->
        false
    end
  end

  @doc ~S"""
  Lexical Parser that matches parser `p` followed by whitespace.

  ## Example
  iex> import Exp
  iex> token(string("abc")).("abc\n")
  [{"abc", ""}]
  """
  def token(p) do
    p ~>> fn a -> space() ~>> fn _ -> return(a) end end
  end

  @doc ~S"""
  Lexical Parser that matches the given string `s` followed by whitespace.

  ## Example
  iex> import Exp
  iex> symb("abc").("abc\n")
  [{"abc", ""}]
  """
  def symb(s) do
    token(string(s))
  end

  @doc ~S"""
  Run parser `p` on input `input`.

  ## Example
  iex> import Exp
  iex> apply_(symb("abc"), ("abc\n"))
  [{"abc", ""}]
  """
  def apply_(p, input) do
    p.(input)
  end
end
