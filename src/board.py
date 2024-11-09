from move_generator import generate_black_legal_moves, generate_white_legal_moves
from renderable import Renderable
from move import Move

'''
maintains state of the game, including position, castle options, whose turn it is, who won if over
'''
class Board(Renderable):
    def __init__(self):
        self.piece_locations = {
            'p': ['a2', 'b2', 'c2', 'd2', 'e2', 'f2', 'g2', 'h2'],
            'r': ['a1', 'h1'],
            'n': ['b1', 'g1'],
            'b': ['c1', 'f1'],
            'q': ['d1'],
            'k': ['e1'],
            'P': ['a7', 'b7', 'c7', 'd7', 'e7', 'f7', 'g7', 'h7'],
            'R': ['a8', 'h8'],
            'N': ['b8', 'g8'],
            'B': ['c8', 'f8'],
            'Q': ['d8'],
            'K': ['e8']
        }

        # to simplify rendering
        self.board_string = "rnbqkbkrpppppppp00000000000000000000000000000000PPPPPPPPRNBQKBNR"
        self.moves = []
        self.white_to_move = True
        self.legal_castles = 'kqKQ'
    
    def make_move(self, move: Move):
        if self.is_legal_move(move):
            self.moves.append(move)
            self.update_positions(move)
            self.white_to_move != self.white_to_move
    
    def update_positions(self, move: Move):
        self.update_board_string(move.piece, move.from_loc, move.to_loc)
        self.update_piece_locations(move.piece, move.from_loc, move.to_loc)
    
    def update_board_string(self, piece, from_loc, to_loc):
        index_from = self.convert_algebraic_to_index(from_loc)
        index_to = self.convert_algebraic_to_index(to_loc)
        self.board_string = self.board_string[:index_from] + "0" + self.board_string[index_from+1:]
        self.board_string = self.board_string[:index_to] + piece + self.board_string[index_to+1:]
        # print("Updated board string to " + self.board_string)

    def update_piece_locations(self, piece, from_loc, to_loc):
        locs = self.piece_locations[piece]
        locs.remove(from_loc)
        locs.append(to_loc)
        # print("Update piece locations to", self.piece_locations)
    
    def convert_algebraic_to_index(self, loc):
        # a1 -> 0, a2 -> 1, ..., b1 -> 8, ..., h8 -> 63
        rank = ord(loc[0]) - ord('a')
        file = int(loc[1])

        file_index = (file - 1) * 8
        rank_index = rank - 1
        index = file_index + rank_index
        # print("Converted " + loc + " to " + str(index))
        return index

        pass
    
    def is_legal_move(self, move: Move):
        return True # TODO REMOVE
        legal = True
        if self.white_to_move:
            legal &= generate_white_legal_moves(self.piece_locations).include(move)
        else:
            legal &= generate_black_legal_moves(self.piece_locations).include(move)
        return legal
    
    def show(self):
        # Will use a basic cli output for now.
        ranks, rank = [], ""
        for i in range(len(self.board_string)):
            next_rank = ((i % 8 == 0) and (i > 0))
            if next_rank:
                ranks.append(rank)
                rank = ""
            piece_str = self.board_string[i] + ' '
            if piece_str == "0 ":
                piece_str = "- " 
            
            rank += piece_str
        # get last rank in
        ranks.append(rank)
                
        # flip for visual correctness
        ranks.reverse()

        for rank in ranks:
            print(rank)
