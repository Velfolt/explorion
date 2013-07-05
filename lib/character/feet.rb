class Feet < Chingu::GameObject
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