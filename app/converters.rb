module Converters

  def self.from_index_to_algebraic(index:)
    # 0 -> a1, 1 -> b1, 8 -> a2, ... 63 -> h8
    rank = index / 8
    file = index % 8
    "#{(file + 'a'.ord).chr}#{rank + 1}"
  end

  # By 'algebraic', we really mean the square name. So e6, g2, ...
  def self.from_algebraic_to_index(algebraic:)
    rank = algebraic[0].ord - 'a'.ord
    file = algebraic[1].to_i
    
    file_index = (file - 1) * 8
    file_index + rank
  end

end
