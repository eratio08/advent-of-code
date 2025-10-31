app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
    unicode: "https://github.com/roc-lang/unicode/releases/download/0.3.0/9KKFsA4CdOz0JIOL7iBSI_2jGIXQ6TsFBXgd086idpY.tar.br",
}

import cli.Stdout
import cli.Arg
import Day01
import Day02

main! : List Arg.Arg => Result {} _
main! = |args|
    when List.get(args, 1) |> Result.map_err(|_| ZeroArgsGiven) is
        Err(ZeroArgsGiven) ->
            Err(Exit(1, "Missing day argument, use e.g. '1.1'"))

        Ok(day_part) ->
            when Arg.display(day_part) is
                "1.1" -> Stdout.line!(Num.to_str(Day01.part_1))
                "1.2" -> Stdout.line!(Num.to_str(Day01.part_2))
                "2.1" -> Stdout.line!(Inspect.to_str(Day02.part_1({})))
                "2.2" -> Stdout.line!(Inspect.to_str(Day02.part_2({})))
                _ -> Err(Exit(1, "Unknown day ${Arg.display(day_part)}"))
