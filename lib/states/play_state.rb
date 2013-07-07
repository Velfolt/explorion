class PlayState < GameState
  trait :viewport
  trait :asynchronous
  
  def initialize
    super
    @original_cursor = $window.cursor
    $window.cursor = true
    
    boundary = 1000000000000
    self.viewport.game_area = [-boundary, -boundary, boundary, boundary]
    
    self.viewport.zoom factor: 1.0, time: 0
    
    @mouse_hint = MouseHint.new
    
    $world = @game_world = GameWorld.new
    
    @text = Chingu::Text.create(:text => 'Helloooo')
    
    @character = PlayableCharacter.create
    @font = Gosu::Font.new $window, 'Arial', 25

    self.input = { 
      :t => lambda { self.viewport.zoom factor: 0.5, time: 500 },
      :y => lambda { self.viewport.zoom factor: 1.0, time: 500 },
    }
  end
  
  def finalize
    $window.cursor = @original_cursor
  end
  
  def draw
    #@game_world.draw_ground
    super
  end
  
  def update
    super
    @mouse_hint.update
    self.viewport.update
    self.viewport.center_around(@character)
    $window.caption = "#{self.viewport.x} #{self.viewport.y} #{@character.x} #{@character.y}"
  end
  
  def draw
    @game_world.draw
    super
    @mouse_hint.draw
  end
  
  def setup
    @character.x = $window.width/2
    @character.y = $window.height/2 - @character.image.height/2
  end
end