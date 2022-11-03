# TowersSolver

A sample solver for [Towers](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/towers.html) (aka Skyscrapers) game, featured in [Simon Tatham's Puzzle Collection](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/). Written in [Swift 5.0](https://swift.org). The project also features experimental [Loopy](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/loopy.html) (or 'Slitherlink'), [Net](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/net.html), [Pattern](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/pattern.html), and [Signpost](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/signpost.html) solvers.

Towers is a logic game where a _at most_ half-filled grid is presented and is to be filled with towers of height 1 through N _(N = length of square grid's side)_, such that all lines and columns have all possible tower heights, but no line or column has repeated tower heights.

Along the edges of the grid are numbered clues that tell how many towers can be seen from that edge when looking through to the other side of the grid in a straight line. Tall towers occlude smaller towers, so the puzzle is mostly about choosing correct sequences of towers such that the edges with the clues can 'see' the exact proper amount of towers, no more no less.


The executable sample currently only runs a static solution for a puzzle grid as follows:

```
            3   1   5           4      
  ╭───┬───┬───┬───┬───┬───┬───┬───╮    
3 │   │   │   │   │   │ 3 │   │   │    
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
3 │   │   │   │   │   │   │   │   │    
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
2 │ 4 │   │   │   │   │   │ 3 │   │    
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
1 │   │   │ 4 │   │   │   │   │   │ 3  
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
  │   │ 1 │   │   │   │   │   │ 4 │ 3  
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
4 │   │   │ 6 │   │   │   │   │   │    
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
  │   │   │   │   │   │   │   │ 2 │ 4  
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
3 │   │ 5 │   │   │ 1 │   │   │   │    
  ╰───┴───┴───┴───┴───┴───┴───┴───╯    
            1   4       2            
```

Solution:

```
            3   1   5           4      
  ╭───┬───┬───┬───┬───┬───┬───┬───╮    
3 │ 5 │ 6 │ 2 │ 8 │ 4 │ 3 │ 7 │ 1 │    
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
3 │ 6 │ 4 │ 7 │ 1 │ 3 │ 2 │ 8 │ 5 │    
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
2 │ 4 │ 8 │ 1 │ 6 │ 2 │ 5 │ 3 │ 7 │    
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
1 │ 8 │ 3 │ 4 │ 7 │ 5 │ 1 │ 2 │ 6 │ 3  
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
  │ 7 │ 1 │ 3 │ 2 │ 6 │ 8 │ 5 │ 4 │ 3  
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
4 │ 3 │ 2 │ 6 │ 5 │ 7 │ 4 │ 1 │ 8 │    
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
  │ 1 │ 7 │ 5 │ 3 │ 8 │ 6 │ 4 │ 2 │ 4  
  ├───┼───┼───┼───┼───┼───┼───┼───┤    
3 │ 2 │ 5 │ 8 │ 4 │ 1 │ 7 │ 6 │ 3 │    
  ╰───┴───┴───┴───┴───┴───┴───┴───╯    
            1   4       2              
```

But other puzzle combinations can be fed by utilizing the command line arguments:

```
OVERVIEW: 
Invokes a solver for one of Simon Tatham's puzzles available within this program.

USAGE: App <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  towers
  net
  loopy
  signpost
  pattern

  See 'App help <subcommand>' for detailed help.
```

Each solver takes in as argument a game ID for the appropriate game, and optionally a maximum number of guesses to use when solving the grid.

## Building and Running

Requires: Xcode 10.2 & Swift 5.0

- Clone the project and run `$ swift build`
- Run the resulting App that was built
  - Run `swift run App` with no arguments to start a demo solve of a Towers game, optionally enabling interactive/descriptive mode.
  - Run `swift run App --help` to check command line options for other solvers.

## Discussion

This solver uses trivial solution deductions (like solving for ones or W (size of grid)'s) and other more complex solving steps that use a tree for deducting possible combinations of values for each node (some ideas taken from http://www.conceptispuzzles.com/index.aspx?uri=puzzle/skyscrapers/techniques), and in the last case does backtracking guess attempts.

It's pretty simple, but fancy stuff. It's able to solve a pretty complex puzzle (the one above) in only ~0.25s with three guesses total.

## License

This is licensed under MIT license (see `LICENSE.md` for more info.)
