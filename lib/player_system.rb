module PlayerSystem
  
  protected
  def player(player)
    return eval("Players::" + player.playerclass + ".new()")
  end
end