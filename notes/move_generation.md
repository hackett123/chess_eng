
# Move Generation

For whichever player has the turn, we may generate all legal moves in the position for them.

Interface:

```python
class MoveGenerator():
    def generate_legal_moves(piece_locations, white_to_move?)
```

The application would use the move generator interface for either:
- Validate legality of input move by player
- Feed into an algorithm that chooses a move
- Determine if end condition of game is met

The piece locations is actually a copied hash of what option 3 was in the board modeling doc, but it is not the case that it MUST match the board model. It just is simplest for the move generator to receive the information in this form.

## Working with board model, and our general interface

Although we discussed in `./modeling_the_board.md` different ways to store the board state in our application, note that the board representation is actually only partially relevant to a move generator. The move generator only needs to know three things:
- (1) what piece am I making moves for?
- (2) what square am I on right now?
- (3) are any pieces in my way?

We can maintain model independence here by standardizing **algebraic notation** as our method of communication for moves and piece locations. Consider the square e4. We know how to easily find e4 and its contents in all 3 discussed implementations of the board state, so we don't need to couple the board model with the move generator. Likewise, the move generator can feed back algebraic moves without caring how the board processes it.

With that being said, we can now confidently move forward into move generation.

## Rules for Movement, if you don't know
Rules for movement:
- Pawns: "forward", or "two forward", or "diagonal" if applicable
    - advanced moves - en passent handling, promotion handling
- King: 8 surrounding squares
- Bishop: each diagonal direction until it hits edge or another piece
- Rook: each horizontal/vertical direction until it hits edge or another piece
- Queen: every direction until it hits edge or another piece
- Knight: permute all +- (1, 2) and (2, 1) directional moves. In other words, the L piece.

As an example, the moves for a bishop from g5 on an otherwise empty board is:
- Bh6 (the up-right diagonal)
- Bf6, Be7, Bd8 (the up-left diagonal)
- Bh4 (the down-right diagonal)
- Bf4, Be3, Bd2, Bc1 (the down-left diagonal)

Some starter code to help visualize this creation is below:
```python
def legal_moves(piece, loc):
    match piece:
        case 'p':
            ...
        case 'P':
            ...
        case 'b':
            return bishop_moves(loc)
        case 'r':
            return rook_moves(loc)
        case 'q':
            return bishop_moves(loc) + rook_moves(loc)
        case 'k':
            return bishop_moves(loc, max_radii=1) + rook_moves(loc, max_radii=1)
        case 'n':
            return knight_moves(loc)
        ...

def bishop_moves(loc):
    return generate_up_right_diagonal_moves(loc) + ...
    

def generate_up_right_diagonal_moves(loc):
    rank = loc[0]
    file = loc[1]
    tmp_rank = rank
    tmp_file = file
    while tmp_rank <= 'h' and tmp_file <= '8'
        tmp_rank = chr(ord(tmp_rank) + 1)
        tmp_file = chr(ord(tmp_file) + 1)
        potential_square = f'{tmp_rank}{tmp_file}'
        moves.push(f'B{potential_square}')
    return moves
```

We have thus far neglected answering `(3) are any pieces in my way?`. To answer, we need to utilize the `piece_locations` hash provided. During the move generation methods, adapt to add this stop condition:

```python
    potential_square = f'{tmp_rank}{tmp_file}'
    if potential_square in friendly_pieces:
        return
    if potential_square in enemy_pieces:
        moves.push(f'<piece>x{potential_square}')
        return
    moves.push(f'<piece>{potential_square}')
```

That should cover answering questions 1-3. Let's now start looking at some additional requirements around legality of moves

## Pruning Illegal Moves

A legal move requires a piece to move in its prescribed manner, without jumping over pieces (knight excluded) or occupying the same square as a friendly, and also ensuring:
- If currently in check, the move creates a position where my king is not in check
- If not in check, the move does not create a position where my king is in check

To handle this, we need the move generator to understand if a resulting position after a move has their own king in check.

To do so, we may think to just generate all of our opponents legal moves, and see if any include "piece takes king". But this is recursive, and ultimately is invalid without careful consideration. Suppose we have a position where white's king is on f1, the white bishop is on b5, and black has a knight of c6, a queen on a6, and their king is on e8. Black to move, they are evaluating all of their knight moves, let's just say Nd4. To see if this produces an illegal move, we evaluate white's moves, and arrive on Bxe8, where the king is. But if we try to evaluate the legality of THAT move, we'll see the bishop cannot move because black's queen on a6 is ALSO pinning the bishop. So, the basic recursive move generation is overly complicated, and requires adding conditions like "a move is illegal even if my oppponents move is illegal because check doesn't actually requrie captures so pins are allowed for checks" etc. So rather than try to re-use our move generation algorithm recursively, we can make it easier on ourselves.

A second option is to consider our own king's "vision" after any proposed move by its own pieces.
- Imagine shooting rays of light from our king. If any hit an enemy piece unobstructed, and that piece can travel on the light's direction, we would be in check.
- Also, for the knights, imagine throwing lightbulbs at the L distant squares I suppose. The truth is that because knights see through pieces, we would alraedy know if we were in check regardless of the piece move (unless it is to take us OUT of check). Since we are assuming here that we started NOT in check, the knights can be skipped.

But we can hit a new insight here - there are moves a piece can dream about, and moves a piece can perform. 

## Other Considerations

Note that it is ultimately not the job of the move generator to answer questions like "is the game over?". But, with the exception of clock-based game ending conditions, or the 50 move rule, a game is only over if the move generator returns an empty list for a player on their turn.