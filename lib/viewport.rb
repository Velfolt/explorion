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