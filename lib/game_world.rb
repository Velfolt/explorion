class GameWorld < BasicGameObject
  attr_reader :viewport
  
  def initialize(options = {})
    super
    @tile_size = 64
    @codes = {1 => Color::WHITE, 2 => Color::BLUE, 3 => Color::RED, 4 => Color::GREEN}
    @viewport = self.parent.viewport
    @rects = []
  end
  
  def factor(num)
    @viewport.factor_x * num
  end
  
  def real_x(x)
    factor(x) - @viewport.x
  end
  
  def real_y(y)
    factor(y) - @viewport.y
  end
  
  def add_rect(rect)
    new_rect = Rect.new(rect[0], [rect[1][0] - rect[0][0], rect[1][1] - rect[0][1]])
    
    @rects << new_rect
  end
  
  def collide_point(x, y)
    @rects.select do |rect|
      rect.collide_point? x, y
    end
  end
  
  def collide_rect(bounding_box)
    @rects.select do |rect|
      rect.collide_rect? bounding_box
    end
  end
  
  def remove_rects(rects)
    rects.each do |rect|
      @rects.delete rect
    end
  end
  
  def draw_rect(rect, color)
    $window.draw_rect [real_x(rect[0]), real_y(rect[1]), factor(rect[2]), factor(rect[3])], color
  end
  
  def draw_filled_rect(rect, color)
    $window.fill_rect [real_x(rect[0]), real_y(rect[1]), factor(rect[2]), factor(rect[3])], color
  end
  
  def draw
    @rects.each do |rect|
      draw_filled_rect(rect, Color::WHITE)
    end
  end
end
