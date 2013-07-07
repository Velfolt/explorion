class MouseHint < GameObject
  def initialize(options = {})
    super
    
    @messages = [
      '',
      'Create',
      'Destroy'
    ]
    
    @message = 0
    
    @font = Gosu::Font.new $window, 'Arial', 25
    
    self.input = {
      :mouse_wheel_up => :next,
      :mouse_wheel_down => :previous,
      :mouse_left => :action,
      :mouse_right => :cancel,
      :holding_mouse_left => :hold_action,
      :released_mouse_left => :release_action
    }
    
    @create = [false, false]
  end
  
  def next
    @message = @message + 1
    if @message >= @messages.length
      @message = @messages.length - 1
    end
  end
  
  def previous
    @message = @message - 1
    if @message < 0
      @message = 0
    end
  end
  
  def real_x
    ($window.mouse_x + $world.viewport.x) / $world.viewport.factor_x
  end
  
  def real_y
    ($window.mouse_y + $world.viewport.y) / $world.viewport.factor_y
  end
  
  def action
    collide = $world.collide_point(real_x, real_y)
    if @messages[@message] == 'Create' && !@create[0] && !@create[1]
      @create[0] = [real_x - real_x % 16, real_y - real_y % 16]
    elsif @messages[@message] == 'Destroy' && collide
      $world.remove_rects(collide)
    end
  end
  
  def hold_action

  end
  
  def release_action
    if @messages[@message] == 'Create' && @create[0] && !@create[1]
      @create[1] = [real_x - real_x % 16, real_y - real_y % 16]
      $world.add_rect @create
      @create = [false, false]
    end
  end
  
  def cancel
    if @messages[@message] == 'Create' && @create[0] && !@create[1]
      @create = [false, false]
    end
  end
  
  def draw
    text = @messages[@message]
    
    if text.empty?
      text = "Create #{real_x}x#{real_y}"
    end
    
    @font.draw text, $window.mouse_x + 10, $window.mouse_y, 100000
    
    collides = $world.collide_point(real_x, real_y)
    
    if @messages[@message] == 'Create' && @create[0] && !@create[1]
      rect = Rect.new @create[0][0], @create[0][1], real_x - real_x % 16 - @create[0][0], real_y - real_y % 16 - @create[0][1] 
      
      $world.draw_rect(rect, Color::RED)
    elsif @messages[@message] == 'Create' && !@create[0] && !@create[1]
      rect = Rect.new real_x - real_x % 16, real_y - real_y % 16, 16, 16
      
      $world.draw_rect(rect, Color::RED)
    elsif @messages[@message] == 'Destroy' && collides
      collides.each do |rect|
        $world.draw_rect(rect, Color::BLUE)
      end
    end
  end
end