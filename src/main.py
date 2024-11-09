from fen_reader import FenReader
from board import Board
from move import Move

def main():
    # FenReader().read_from_file("res/delayed_alapin_11_moves.fen")
    board = Board()
    board.show()
    print("Moving e4")
    board.make_move(Move("e4", "e2", "e4", "p"))
    board.show()

if __name__ == '__main__': 
    main()
