#!/usr/bin/env ruby

Chingu::Text.trait :asynchronous
RequireAll.require_all File.dirname(__FILE__)

class Game < Chingu::Window
  def initialize
    super 1280, 720, false
    self.input = { escape: :exit }
    
    push_game_state CharacterBuilder
  end
end

Game.new.show