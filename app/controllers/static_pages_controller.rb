class StaticPagesController < ApplicationController
  def index
  end
  def fight_schedule
  end
  def landing_page
    @posts = Post.limit(3)
  end
  def contact
  end
  def blog
  end
end
