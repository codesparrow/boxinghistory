class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy, :retrieve]


  # GET /feeds
  def index
    @feeds = Feed.all
  end

  # GET /feeds/1
  def show
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1/edit
  def edit
  end

  # GET /feeds/1/retrieve
  def retrieve
    body, ok = SuperfeedrEngine::Engine.retrieve(@feed)
    if !ok
      redirect_to @feed , notice: body
    else
      @feed.notified JSON.parse(body)
      redirect_to @feed , notice: "Retrieved and saved entries"
    end
  end

  # POST /feeds
  def create
    @feed = Feed.new(feed_params)

    if @feed.save
      body, ok = SuperfeedrEngine::Engine.subscribe(@feed, {:retrieve => true})
      if !ok
        redirect_to @feed, notice: "Feed was successfully created but we could not subscribe: #{body}"
      else
        if body
          @feed.notified JSON.parse(body)
        end
        redirect_to @feed, notice: 'Feed was successfully created and subscribed!'
      end
    else
      render :new
    end
  end

  # PATCH/PUT /feeds/1
  def update
    if @feed.update(feed_params)
      body, ok = SuperfeedrEngine::Engine.unsubscribe(@feed)
      if !ok
        render :edit, notice: "Feed was successfully updated, but we could not unsubscribe and resubscribe it. #{body}"
      else
        body, ok = SuperfeedrEngine::Engine.subscribe(@feed)
        if !ok
          render :edit, notice: "Feed was successfully updated, but we could not unsubscribe and resubscribe it. #{body}"
        else
          redirect_to @feed, notice: 'Feed was successfully updated.'
        end
      end
    else
      render :edit
    end
  end

  # DELETE /feeds/1
  def destroy
    body, ok =  SuperfeedrEngine::Engine.unsubscribe(@feed)
    if !ok
      redirect_to @feed, notice: body
    else
      @feed.destroy
      redirect_to feeds_url, notice: 'Feed was successfully destroyed.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def feed_params
      params.require(:feed).permit(:title, :url)
    end
end