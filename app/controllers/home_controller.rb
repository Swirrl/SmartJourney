class HomeController < ApplicationController
  before_filter :set_intro_colour

  caches_action :about, :help

  private

  def set_intro_colour
    @intro_colour = "blue"
  end

end