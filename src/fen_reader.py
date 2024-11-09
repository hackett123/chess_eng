'''
Ingests .fen files, or strings, and outputs a Board object
'''
class FenReader():
    def read_from_file(self, filename):
        with open(filename) as f:
            self.create_board(f.readline())
    
    def create_board(self, fen):
        parts = fen.split(" ")
        positions = parts[0]
        white_to_move = parts[1] == 'w'
        castle_chunk = parts[2]
        en_passent_target = parts[3]
        halfmove_clock = parts[4]
        fullmove_count = parts[5]
