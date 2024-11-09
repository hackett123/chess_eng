# Modeling the Board

## Board Representation Options

Here we discuss a few possibilities for how one may opt to model what the board looks like internally to the application.

### Option 1. Hexadecimal

This is the C programmer's dream. We use 64 hexadecimal values to represent every square on the board. We assign a value to the possible contents of a square:

    0 => empty
    1 => white pawn
    2 => white rook
    3 => white knight
    4 => white bishop
    5 => white queen
    6 => white king
    7 => black pawn
    8 => black rook
    9 => black knight
    A => black bishop
    B => black queen
    C => black king

As the board is comprised of 8 ranks and 8 files, we can use this encoding to represent a single rank as 8 consecutive hex values, which fits in a single integer value. Now, we have 8 numbers that tell us what the board looks like.

```python
rank_0 = 0x23456432
rank_1 = 0x11111111
rank_2 = 0x00000000
rank_3 = 0x00000000
rank_4 = 0x00000000
rank_5 = 0x00000000
rank_6 = 0x77777777
rank_7 = 0x89ABCA98
```

Let's throw it into a list:

```python
ranks = [
    0x23456432,
    0x11111111,
    0x00000000,
    0x00000000,
    0x00000000,
    0x00000000,
    0x77777777,
    0x89ABCA98
]
```
Notice the board might look "upside down" visually, but `ranks[0]` will return the first rank and so on, so it makes sense.


### Option 2: One String to rule them all

We can also represent the board as a 64-char string, each char representing a position on the board. We use a different encoding here:

    0 => empty
    p => white pawn
    r => white rook
    n => white knight
    b => white bishop
    q => white queen
    k => white king
    P => black pawn
    R => black rook
    N => black knight
    B => black bishop
    Q => black queen
    K => black king

 The starting position then is:

```python
"rnbqkbkrpppppppp00000000000000000000000000000000PPPPPPPPRNBQKBNR"
```


Note: FEN notation, which is a universal method of sharing positions, uses a similar setup. Its starting position is this:

```python
rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
```

### Option 3: Hash of piece locations

Ultimately, the empty space on the chess board will grow as pieces are captured, and we eventually approach a barren board. Combine this with the annoyance of having to bother going and finding out where your pieces are from these hex or string representations above, just to encode it internally in a more usable manner. That leads us to this third notation, which maps piece types (reusing the lower/upper char representation from our string above) to their algebraic location on the board.

```python
piece_locations = {
    'p': ['a2', 'b2', ..., 'e2', ..., 'h2'],
    'r': ['a1', 'h1'],
    ...
    'R': ['a8', 'h8'],
    'P': ['a7', 'b7', ..., 'h7']
}
```

## Finding pieces and making moves in each representation

In this section we discuss how to answer simple questions and perform simple operations on the board. In each we will answer "what is on square e4?", "Where are white's pieces?", and "perform the move e4".

### Hex

Bitwise operations rule this world.

- What is on a square:
    - Get int at the correct rank
    - Bitwipe left so desired position is highest bit
    - Bitwipe right so desired position is lowest pit
    - Return mapped value of that int
- Where are white's pieces:
    - Annoying to answer. Systematically fetch each 4-bit chunk from each of the ints in order. Anytime a value in range [1, 6] is found, add that to our output
- Moving a piece:
    - First wipe its original position:
        - Bitwise AND where everything is a 1 except for the 'index' of the piece, which is a 0
    - Then write to the new position:
        - Wipe the original piece (same as first step)
        - Bitwise OR, where everything is a 0 except for the 'index' of the piece, which is the hex value of the moved piece

### One String

Indexing is the endgame here.

What is on e4:
- e file => offset of 4 (a = 0, b = 1, ...)
- fourth rank => offset of 24
- so, str[28] is the piece on e4

Where are white's pieces:
- Do a one-time parse through the string. Every time a lowercase letter is found, spit out its position and value.

Performing move pawn e2 -> e4:
in python if we use an actual string, we need to do slicing:

```python
    board = board[:27] + board[12] + board[29:]
    board = board[:12] + '0' + board[13:]
```

We are then left with:

```python
"rnbqkbkrppp0pppp000000000000000000p0000000000000PPPPPPPPRNBQKBNR"
```

We can see this is obviously less efficient than the hex setup as we create multiple new strings for each move which is much less efficient than bitwise operations. We can solve this really easily with an actual list of chars.

### Piece Dictionary

What is on e4:
- This is actually annoying! We are forced to iterate over every key in our hash until we find 'e4' in a key's list, then we return that key.

Where are white's pieces?
- This is the easiest to answer. Return all the lowercase key/value pairs.

Make the move e4:
- We get the white pawns - `piece_locations['p']` - and replace the e2 val with e4. Our piece locations now updates to this:

```python
piece_locations = {
    'p': ['a2', 'b2', ..., 'e4', ..., 'h2'],
    'r': ['a1', 'h1'],
    ...,
    'q': ['d1'],
    ...
    'R': ['a8', 'h8'],
    'P': ['a7', 'b7', ..., 'h7']
}
```

### Summary

We see that each model has questions it answers easily and others that are more complicated:

- "What is on e4" is simplest for the string and hardest for the piece locations hash
- "Where are white's pieces" is simplest for the piece locations hash and hardest for the hex
- "Make move X" doesn't have any clear winners or losers
