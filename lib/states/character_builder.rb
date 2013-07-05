class CharacterBuilder < GameState
  trait :viewport
  trait :asynchronous
  
  def initialize
    super
    @original_cursor = $window.cursor
    $window.cursor = true
    
    boundary = 1000000000000
    
    self.viewport.zoom factor: 1.0, time: 0
    self.viewport.game_area = [-boundary, -boundary, boundary, boundary]
    
    @title = Chingu::Text.create(:text => 'Character Builder', :x => 20, :y => 20, :size => 30)
    @character = PlayableCharacter.create
    Character.create x: 20, y: 100
    Character.create x: 60, y: 100
    Character.create x: 90, y: 100
    Character.create x: 150, y: 100

    self.input = { 
      :t => lambda { self.viewport.zoom factor: 0.1, time: 1000 },
      :y => lambda { self.viewport.zoom factor: 1.0, time: 500 },
      :left_mouse_button => lambda { Character.each { |character| character.walk_to ($window.mouse_x + self.viewport.x) / self.viewport.factor_x, ($window.mouse_y + self.viewport.y) / self.viewport.factor_y } }
    }
  end
  
  def finalize
    $window.cursor = @original_cursor
  end
  
  def update
    super
    self.viewport.update
    self.viewport.center_around(@character)
  end
  
  def setup
    @character.x = $window.width/2
    @character.y = $window.height/2 - @character.image.height/2
  end
end