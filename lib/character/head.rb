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