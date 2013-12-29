class Card
    Suits = ["Clubs","Hearts","Spades","Diamonds"]
    Pips = ["2","3","4","5","6","7","8","9","10","Jack","Queen","King","Ace"]
 
    attr_reader :pip, :suit
 
    def initialize(pip,suit)
        @pip = pip
        @suit = suit
    end
 
    def to_s
        "#{@pip} #{@suit}"
    end

    def to_i
        if ["Jack","Queen","King"].include? @pip
            return 10
        elsif @pip == "Ace"
            return 1
        else
            return @pip.to_i
        end
    end
end
 
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

class Blackjack
    def initialize()
        @players = []
        @max_players = 3
        @dealers_hand = Hand.new()
    end

    # Initialize players
    def start_game()
        puts "Let's play some Blackjack!"
        puts "How many players do we have? (Up to #{@max_players} players allowed)"
        num_players = gets.chomp.to_i
        while num_players < 1 or num_players > @max_players
            puts "Invalid number of players. Please re-enter. (Up to #{@max_players} players allowed)"
            num_players = gets.chomp.to_i
        end

        for player in (1..num_players)
            @players.push(Player.new(player))
        end
    end

    # Print the current game state.
    def game_state()
        for player in @players
            puts player
        end
        puts "=== Dealer ==="
        puts "Hand: " + @dealers_hand.to_s()
    end

    # Plays a full single-round of Blackjack.
    def play_round()
        # Deal hand to all players
        for p in @players
            hand = Hand.new
            hand.deal_hand()
            p.hands << hand
        end

        # Dealer deals his own hand
        @dealers_hand.deal_hand()

        # Gather bets from all players
        for p in @players
            game_state()
            puts "Player #{p.player}, how much would you like to bet?"
            bet_amount = gets.chomp.to_i
            while !(p.can_bet(bet_amount))
                game_state()
                puts "Player #{p.player}, that's an invalid bet! Try again."
                bet_amount = gets.chomp.to_i
            end
            p.bet(bet_amount)

            for h in p.hands
                p.place_bet(h)
            end
        end

        # Allow players to finalize their bet(s) and hand(s)
        for player in @players
            for hand in player.hands
                while !(hand.is_stand())
                    valid_moves = ['h']
                    if hand.is_split and player.can_bet_double()
                        valid_moves += ['s', 'd', 'e']
                    elsif player.can_bet_double()
                        valid_moves += ['d', 'e']
                    else
                        valid_moves += ['e']
                    end

                    game_state()
                    puts "Player #{player.player}, what would you like to do for your #{hand} hand? Your valid moves: #{valid_moves}"
                    puts "Legend: ['h' -> hit, 's' -> split, 'd' -> double down, 'e' -> end turn]"

                    move = gets.chomp
                    while !(valid_moves.include? move)
                        game_state()
                        puts "Player #{player.player}, that is not a valid move! Try again. Your valid moves: #{valid_moves}"
                        puts "Legend: ['h' -> hit, 's' -> split, 'd' -> double down, 'e' -> end turn]"
                        move = gets.chomp
                    end

                    case move
                    when 'h'
                        hand.hit()
                    when 's'
                        new_hand = hand.split()
                        player.place_bet(new_hand)

                        hand.hit()
                        new_hand.hit()
                        player.hands << new_hand
                    when 'd'
                        player.place_bet(hand)
                        hand.hit()
                        hand.stand()
                    when 'e'
                        hand.stand()
                    end

                    if hand.is_bust()
                        puts "You busted!"
                        hand.stand()
                    end
                end
            end
        end

        # Determine dealer's ending hand
        while @dealers_hand.value() < 17
            @dealers_hand.hit()
        end

        puts "-=-=-=- Resulting Hands For This Round -=-=-=-"
        game_state()

        # Determine winnings of each player and their hand(s)
        for player in @players
            for hand in player.hands
                if (!hand.is_bust() and @dealers_hand.is_bust()) or (!hand.is_bust() and !@dealers_hand.is_bust and hand.value() > @dealers_hand.value())
                    player.win_hand(hand)
                    puts "Player #{player.player}'s #{hand} beat the dealer's #{@dealers_hand} hand!"
                elsif (hand.is_bust() and @dealers_hand.is_bust()) or (hand.value() == @dealers_hand.value())
                    player.tie_hand(hand)
                    puts "Player #{player.player}'s #{hand} tied with the dealer's #{@dealers_hand} hand!"
                else
                    player.lose_hand(hand)
                    puts "Player #{player.player}'s #{hand} lost to the dealer's #{@dealers_hand} hand! :("
                end
            end
        end

        # Determine who can continue playing
        continuing_players = []
        for player in @players
            if player.money != 0
                continuing_players << player
            else
                puts "Player #{player.player} has no money and is eliminated!"
            end
        end
        @players = continuing_players

        # Clear all playing hands.
        for player in @players
            player.hands = []
            player.bet = 0
        end
    end
                        
    def play()
        start_game()
        while @players.length > 0
            play_round()
        end
        puts "GAME OVER"
    end
end

game = Blackjack.new()
game.play()