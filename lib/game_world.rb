class GameWorld < BasicGameObject
  attr_reader :viewport
  
  def initialize(options = {})
    super
    @tile_size = 64
    @codes = {1 => Color::WHITE, 2 => Color::BLUE, 3 => Color::RED, 4 => Color::GREEN}
    @viewport = self.parent.viewport

    @quadtree = QuadTree.new(Rect.new(-1000000, -1000000, 2000000, 2000000))
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
    
    @quadtree.insert_rect(new_rect)
  end
  
  def window_rect
    x = (0 + $world.viewport.x) / $world.viewport.factor_x
    y = (0 + $world.viewport.y) / $world.viewport.factor_y
    w = ($window.width + $world.viewport.x) / $world.viewport.factor_x
    h = ($window.height + $world.viewport.y) / $world.viewport.factor_y
    
    window_rect = Rect.new(x, y, w - x, h - y)
  end
  
  def collide_point(x, y)
    rects = @quadtree.query_rect(window_rect)
    
    rects.select do |rect|
      rect[2].collide_point? x, y
    end
  end
  
  def collide_rect(bounding_box)
    rects = @quadtree.query_rect(window_rect)
    
    rects.select do |rect|
      rect[2].collide_rect? bounding_box
    end
  end
  
  def remove_rects(rects)
    rects.each do |rect|
      @quadtree.remove_rect rect[2]
    end
  end
  
  def draw_rect(rect, color)
    $window.draw_rect [real_x(rect[0]), real_y(rect[1]), factor(rect[2]), factor(rect[3])], color
  end
  
  def draw_filled_rect(rect, color)
    $window.fill_rect [real_x(rect[0]), real_y(rect[1]), factor(rect[2]), factor(rect[3])], color
  end
  
  def draw
    rects = @quadtree.query_rect(window_rect)

    rects.each do |point|
      draw_filled_rect(point[2], Color::WHITE)
    end
  end
end
