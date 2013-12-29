require './Card'

class Deck
    def initialize
        @deck = []
        for suit in Card::Suits
            for pip in Card::Pips
                @deck << Card.new(pip,suit)
            end
        end
        @deck.shuffle!
    end
 
    def to_s
        "[#{@deck.join(", ")}]"
    end
 
    def shuffle!
        @deck.shuffle!
        self
    end
 
    def deal(num)
        if @deck.length == 0 # Ran out of cards! 
            initialize()
            @deck.shuffle!
        end
        @deck.shift(num)
    end
end