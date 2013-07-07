require_relative 'head'
require_relative 'feet'
require_relative 'arm'

class Character < Chingu::GameObject
  trait :asynchronous
  trait :bounding_box
  attr_reader :speed
  
  def initialize(options = {})
    super
    @image = Image['body.png']
    cache_bounding_box
    
    @speed = 1

    @head = Head.create body: self
    @arms = Arm.create body: self
    @feet = Feet.create body: self
    
    @walk_to = []
    
    @warn = false
  end
  
  def toggle_armed
    @arms.toggle_armed
  end
  
  def armed?
    @arms.armed?
  end
  
  def say message
    @head.say message
  end
  
  def angle_diff object
    diff = @angle - object.angle
    diff = (diff + 180) % 360 - 180
  end
  
  def move(x = 0, y = 0, speed = 1)
    vec = Vector[x,y]
    
    x = vec.normalize[0] / vec.magnitude
    y = vec.normalize[1] / vec.magnitude
    
    @angle = Math.atan2(y, x) / Math::PI * 180 - 90
    
    x2, y2 = project from: [@x, @y], angle: @angle, distance: speed
    
    x = 0 unless $world.collide_rect(self.bounding_box.inflate(-4, -4).move(x2 - @x, 0)).empty?
    y = 0 unless $world.collide_rect(self.bounding_box.inflate(-4, -4).move(0, y2 - @y)).empty?
    
    @speed = speed
    
    @x += x * speed
    @y += y * speed
  end
  
  def turn_head_to(object)
    delta_x = @x - object.x
    delta_y = @y - object.y
    
    proximity = Math.sqrt(delta_x * delta_x + delta_y * delta_y)
    
    if proximity > 150
      @head.turn_to 0
      return
    end
    
    angle = Math.atan2(delta_y, delta_x) / Math::PI * 180 + 90
    diff = @angle - angle
    diff = (diff + 180) % 360 - 180
    
    if diff.abs < 90
      @head.turn_to angle
    else
      @head.turn_to 0
    end
  end
  
  def turn_to(object)
    delta_x = @x - object.x
    delta_y = @y - object.y
    
    angle = Math.atan2(delta_y, delta_x) / Math::PI * 180 + 90
    diff = @angle - angle
    diff = (diff + 180) % 360 - 180
    
    if diff.abs < 45
      @head.turn_to angle
    else
      @head.turn_to 0
      @angle = angle
    end
  end
  
  def walk_to(x, y)
    @walk_to << [x, y]
  end
  
  def walk_towards object
    @walk_to << [object.x, object.y]
  end
  
  def update
    if @walk_to.length > 0
      
      vec = Vector[@walk_to.first[0], @walk_to.first[1]] - Vector[@x, @y]
      
      if vec.magnitude > 20
        normalized = vec.normalize
        move normalized[0], normalized[1]
      else
        @walk_to.delete_at 0
      end
    end
    
    player = PlayableCharacter.all.first
    
    #walk_towards player if distance_to(player) < 100
    if distance_to(player) < 100
      if @warn && !armed?
        toggle_armed
        turn_to player
      elsif !@warn && player.armed? && angle_diff(player) == -180
        say 'Put that down, please...' 
        @warn = true
      else
        turn_head_to player
      end
    end
  end
end