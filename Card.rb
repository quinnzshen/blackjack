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