class GameObject
  def distance_to object
    vec = Vector[object.x, object.y] - Vector[@x, @y]
    return vec.magnitude
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
end