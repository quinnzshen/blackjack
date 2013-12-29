require './Hand'

class Player
    attr_accessor :player, :money, :hands, :bet

    def initialize(player)
        @player = player
        @money = 1000
        @hands = Array.new
        @bet = 0
    end

    # Used for split and double-down
    def can_bet_double()
        return money >= @bet
    end

    def can_bet(amount)
        return money >= amount
    end

    def bet(amount)
        @bet = amount
    end

    def place_bet(hand)
        hand.bet += @bet
        @money -= @bet
    end

    # Get back the money you bet, plus winnings from dealer
    def win_hand(hand)
        @money += hand.bet * 2
    end

    # Get back the money you bet
    def tie_hand(hand)
        @money += hand.bet
    end

    # Money doesn't change, bet was already subtracted.
    def lose_hand(hand)
        @money = @money
    end

    def to_s()
        return_string = "=== Player #{@player} ===\n"
        return_string += "Money: #{@money}\n"
        return_string += "Hand(s): ["
        for hand in hands
            return_string += hand.to_s() + ", "
        end
        return_string += "]"
        return return_string
    end
end