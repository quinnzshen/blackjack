require './Deck'

class Hand
    attr_accessor :cards, :bet

    def initialize()
        @cards = Array.new
        @is_stand = false
        @bet = 0
        @deck = Deck.new()
    end

    def value()
        sum = 0
        for card in cards
            sum += card.to_i()
        end
        if has_ace and sum <= 11
            sum += 10
        end
        return sum
    end

    def hit()
        @cards += @deck.deal(1)
    end

    def has_ace()
        for card in cards
            if card.pip == 'Ace'
                return true
            end
        end
        return false
    end

    def stand()
        @is_stand = true
    end

    def is_stand()
        return @is_stand
    end

    def is_bust()
        if value > 21
            return true
        end
        return false
    end

    def is_split()
        return (cards.length == 2 and (cards[0].pip == cards[1].pip[0]))
    end

    def deal_hand()
        @cards = @deck.deal(2)
    end

    def split()
        other_hand = Hand.new()
        other_hand.cards = @cards.shift(1)
        return other_hand
    end

    def to_s()
        "[#{@cards.join(', ')}]"
    end
end