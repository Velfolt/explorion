#!/usr/bin/env ruby

Chingu::Text.trait :asynchronous

class Game < Chingu::Window
  def initialize
    super 640, 480, false
    self.input = { escape: :exit }
    
    push_game_state CharacterBuilder
  end
end

class Foot < Chingu::GameObject
  def initialize(options = {})
    super
    @step1_sound = Sound['step1.mp3']
    @step2_sound = Sound['step2.mp3']
    
    @animation = Chingu::Animation.new(:file => "foot.png")
    @frame_name = :idle
    @animation.frame_names = { :idle => 0..0, :move => 1..2 }
    @animation.on_frame 0 do @step1_sound.play if @frame_name == :move end
    @animation.on_frame 1 do @step2_sound.play if @frame_name == :move end
    
    @body = options[:body]
    @zorder = @body.zorder - 2
    
    @last_x = @body.x
    @last_y = @body.y
  end
  
  def select_animation(speed)
    delay = 200
    if speed == 0
      @frame_name = :idle
    else
      delay = 13 * (32 / speed)
      @frame_name = :move
    end
    
    if @animation.delay != delay
      @animation.delay = delay
      @animation.frame_names = { :idle => 0..0, :move => 1..2 }
    end
    
    if @angle != @body.angle
      @animation[@frame_name].reset
      @image = @animation[@frame_name]
    end
    
    @image = @animation[@frame_name].next
  end
  
  def update
    @last_x = @x
    @last_y = @y
    @x = @body.x
    @y = @body.y
    vec = Vector[@x - @last_x, @y - @last_y]
    @angle = @body.angle
    
    if vec.magnitude == 0
      select_animation 0
    else
      select_animation @body.speed
    end
  end
end

class Arm < Chingu::GameObject
  def initialize(options = {})
    super
    @animation = Chingu::Animation.new(:file => "arm.png")
    @animation.frame_names = { :idle => 0..0, :hold => 1..1, :armed => 2..2, :use => 3..3, :punch => 3..3 }
    @frame_name = :idle
    
    @body = options[:body]
    @zorder = @body.zorder - 1
  end
  
  def toggle_armed
    if armed?
      @frame_name = :idle
    else
      @frame_name = :armed
    end
  end
  
  def armed?
    @frame_name == :armed
  end
  
  #from ----------
  #\      )
  #  \   )  angle
  #    \
  #      \
  #        \
  #        distance
  def project options
    from = options[:from]
    angle = (options[:angle] + 90) * Math::PI / 180
    distance = options[:distance]
    
    a = distance * Math.cos(angle)
    b = distance * Math.sin(angle)
    
    [from[0] + a, from[1] + b]
  end
  
  def draw
    angle = (@angle + 180) % 360 - 180
    
    x2, y2 = project from: [@x, @y], angle: angle, distance: 50
    
    $window.draw_line @x, @y, Color::BLACK, x2, y2, Color::RED if armed?
    super
  end
  
  def update
    @image = @animation[@frame_name].next
    
    @angle = @body.angle
    @x = @body.x
    @y = @body.y
  end
end

class GameObject
  def distance_to object
    vec = Vector[object.x, object.y] - Vector[@x, @y]
    return vec.magnitude
  end
end

class Head < GameObject
  trait :asynchronous
  
  def initialize(options = {})
    super
    @image = Image['head.png']
    @body = options[:body]
    @zorder = @body.zorder + 1
    
    @last_spoke = 0
    
    @head_angle = 0
  end
  
  def say(message)
    return if Gosu::milliseconds - @last_spoke < 500
    
    text = Chingu::Text.create(text: message)
    text.x = @x
    text.y = @y - 30
    
    @last_spoke = Gosu::milliseconds
    
    text.async do |q|
      q.wait 250
      q.tween(750, :alpha => 0, :scale => 2)
      q.call :destroy
    end
  end
  
  def turn_to(angle)
    @head_angle = angle
  end
  
  def update
    @x = @body.x
    @y = @body.y
    
    @angle = @body.angle
    @angle = @head_angle if @head_angle != 0
  end
end

class Ball < GameObject
  def initialize(options = {})
    super
  end
  
  def update
    @y -= 2
  end
  
  def draw
    super
    $window.draw_circle @x, @y, 10, Color::WHITE
  end
end

class Character < Chingu::GameObject
  trait :asynchronous
  attr_reader :speed
  
  def initialize(options = {})
    super
    @image = Image['body.png']
    
    @speed = 1

    @head = Head.create body: self
    @arms = Arm.create body: self
    @feet = Foot.create body: self
    
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

class PlayableCharacter < Character
  def initialize(options = {})
    super
    
    @time_since_jump = 0
    
    self.input = { 
      [:holding_w, :holding_a, :holding_s, :holding_d] => :move,
      :z => lambda { toggle_armed },
      :p => :create_box,
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
  
  def create_box
    Box.create x: @x + 32, y: @y + 32, width: 10, height: 10
  end
  
  def update

  end
end

class Viewport
  def zoom(options = {})
    @zoom_complete = Gosu::milliseconds + options[:time]
    @zoom_factor = options[:factor]
    @factor_per_ms = (@zoom_factor - @factor_x) / options[:time]
    @last_ms = Gosu::milliseconds
    @zoom_on = true
  end
  
  def zoom_done
    @factor_x = @factor_y = @zoom_factor
    @zoom_on = false
  end
  
  def update
    return unless @zoom_on
    
    ms = Gosu::milliseconds
    ms_to_go = @zoom_complete - ms
    delta_ms = ms - @last_ms
    if ms_to_go < 0
      zoom_done
      return
    end
    
    current_factor = @factor_x
    factor_to_add = @factor_per_ms * delta_ms
    
    if current_factor < @zoom_factor
      if current_factor + factor_to_add > @zoom_factor
        factor_to_add = @zoom_factor - current_factor
      end
    else
      if current_factor + factor_to_add < @zoom_factor
        factor_to_add = @zoom_factor - current_factor
      end
    end
    
    @factor_x = @factor_y = current_factor + factor_to_add
    @last_ms = ms
  end
end

class Box < GameObject
  def initialize options = {}
    super
    @width = options[:width] || 2
    @height = options[:height] || 2
  end
  
  def draw
    $window.draw_rect [@x, @y, @width, @height], Color::BLUE
  end
end

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
    
    Box.create x: 200, y: 200
    
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
    Ball.destroy_if { |ball| ball.outside_window? }
    self.viewport.update
    self.viewport.center_around(@character)
  end
  
  def setup
    @character.x = $window.width/2
    @character.y = $window.height/2 - @character.image.height/2
  end
end

Game.new.show