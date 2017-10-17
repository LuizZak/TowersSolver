# TowersSolver

A sample solver for [Towers](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/js/towers.html) (aka Skyscrapers) game, featured in [Simon Tatham's Puzzle Collection](https://www.chiark.greenend.org.uk/~sgtatham/puzzles/). Written in [Swift 4.0](https://swift.org).

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

But other puzzle combinations can be fed by changing the initial grid in `main.swift` and they'll all (most likely) be solved correctly as well.

## Building and Running

Requires: Xcode 9.0 & Swift 4.0

- Clone the project and run `$ swift build`
- Run the resulting App that was built, optionally opting-in running in interactive mode (which I recommend, cause it's cool to see the solver's thought process).

## Discussion

This solver uses trivial solution deductions (like solving for ones or W (size of grid)'s) and other more complex solving steps that use a tree for deducting possible combinations of values for each node (some ideas taken from http://www.conceptispuzzles.com/index.aspx?uri=puzzle/skyscrapers/techniques), and in the last case does backtracking guess attempts.

It's pretty simple, but fancy stuff. It's able to solve a pretty complex puzzle (the one above) in only ~0.25s with three guesses total.

## License

This is licensed under MIT license (see `LICENSE.md` for more info.)
