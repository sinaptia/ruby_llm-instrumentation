class WeatherTool < RubyLLM::Tool
  description "Get weather information for a location"
  param :location, desc: "City name"

  def execute(location:)
    { temp: 35, condition: "sunny", location: location }
  end
end
