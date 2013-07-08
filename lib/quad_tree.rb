class QuadTree
  QUAD_TREE_SIZE = 4
  
  def initialize(boundary)
    @boundary = boundary
    @points = Array.new
    
    #split quadtree into four areas
    @north_west = nil
    @north_east = nil
    @south_west = nil
    @south_east = nil
  end
  
  def insert(x, y, data)
    return false unless @boundary.collide_point?(x, y)
    
    if @points.length < QUAD_TREE_SIZE
      @points << [x, y, data]
      return true
    end

    subdivide if @north_west == nil

    return true if @north_west.insert(x, y, data)
    return true if @north_east.insert(x, y, data)
    return true if @south_west.insert(x, y, data)
    return true if @south_east.insert(x, y, data)

    false
  end
  
  def insert_rect(rect)
    insert(rect.x, rect.y, rect)
  end
  
  def remove_rect(rect)
    return unless @boundary.collide_rect?(rect)

    @points.each do |point|
      if point[2].is_a?(Rect)
        @points.delete point if rect.collide_rect?(point[2])
      else
        @points.delete point if rect.collide_point?(point[0], point[1])
      end
    end

    return if @north_west == nil

    @north_west.remove_rect(rect)
    @north_east.remove_rect(rect)
    @south_west.remove_rect(rect)
    @south_east.remove_rect(rect)
  end
  
  def subdivide
    x = @boundary.x
    y = @boundary.y
    half_width = @boundary.width/2
    half_height = @boundary.height/2
    
    @north_west = QuadTree.new Rect.new(x, y, half_width, half_height)
    @north_east = QuadTree.new Rect.new(x + half_width, y, half_width, half_height)
    @south_west = QuadTree.new Rect.new(x, y + half_height, half_width, half_height)
    @south_east = QuadTree.new Rect.new(x + half_width, y + half_height, half_width, half_height)
  end
  
  def query_rect(rect)
    points_in_range = []
    
    return points_in_range unless @boundary.collide_rect?(rect)

    @points.each do |point|
      if point[2].is_a?(Rect)
        points_in_range << point if rect.collide_rect?(point[2])
      else
        points_in_range << point if rect.collide_point?(point[0], point[1])
      end
    end

    return points_in_range if @north_west == nil

    points_in_range.concat @north_west.query_rect(rect)
    points_in_range.concat @north_east.query_rect(rect)
    points_in_range.concat @south_west.query_rect(rect)
    points_in_range.concat @south_east.query_rect(rect)

    return points_in_range
  end
end