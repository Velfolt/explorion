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