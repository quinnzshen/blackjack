require './Player'

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