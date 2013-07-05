class GameObject
  def distance_to object
    vec = Vector[object.x, object.y] - Vector[@x, @y]
    return vec.magnitude
  end
end