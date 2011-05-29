class ActionController::Routing::RouteSet
  def draw_with_file_publisher
    draw_without_file_publisher do |map|
      map.connect "/users_contents/*path",
        :controller=>"file_publisher/contents", :action=>"index"
      yield(map) # exec config/routes.rb
    end
  end
  alias_method_chain :draw, :file_publisher
end
