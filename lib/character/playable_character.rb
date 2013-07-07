class PlayableCharacter < Character
  def initialize(options = {})
    super
    
    @time_since_jump = 0
    
    self.input = { 
      [:holding_w, :holding_a, :holding_s, :holding_d] => :move,
      :z => lambda { toggle_armed },
      :k => lambda { say 'Who are you?' },
      :l => lambda { say 'Hello?' },
      :m => lambda { say 'HELLOOOO!!?' } 
    }
  end
  
  def move(x = 0, y = 0, speed = 1)
    x = -1 if holding? :a
    x = 1 if holding? :d
    y = -1 if holding? :w
    y = 1 if holding? :s
    
    @speed = 1
    @speed = 2 if holding? :left_shift
    if holding?(:space) && Gosu::milliseconds - @time_since_jump < 200
      @speed = 4
    end
    
    if Gosu::milliseconds - @time_since_jump > 500
      @time_since_jump = Gosu::milliseconds
    end
    
    super(x, y, @speed)
  end
  
  def update
  end
end