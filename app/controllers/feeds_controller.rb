class FeedsController < ApplicationController
  before_action :set_feed, only: [:show, :edit, :update, :destroy]

  # GET /feeds
  # GET /feeds.json
  def index
    @feeds = Feed.all
  end

  # GET /feeds/1
  # GET /feeds/1.json
  def show
  end

  # GET /feeds/new
  def new
    @feed = Feed.new
  end

  # GET /feeds/1/edit
  def edit
  end

  #GET /feeds/1/retrieve
  def retrieve
    body, ok = SuperfeedrEngine::Engine.retrieve(@feed)
    if !ok
      redirect_to @feed, notice: body
    else
      @feed.notified JSON.parse(body)
      redirect_to @feed, notice: "Retrieved and saved entries"
    end
  end

  # POST /feeds
  # POST /feeds.json
  def create
    @feed = Feed.new(feed_params)

    respond_to do |format|
      if @feed.save
        body, ok = SuperfeedrEngine::Engine.subscribe(@feed, {:retrieve => true})
        if !ok
          redirect_to @feed, notice: "Feed was succesfully created but we could not subscribe: #{body}"
        else
          if body
            @feed.notified JSON.parse(body)
          end
          redirect_to @feed, notice: "Feed was successfully created and subscribed"
        end
      else
        render :new
      end
    end
  end

  # PATCH/PUT /feeds/1
  # PATCH/PUT /feeds/1.json
  def update
    respond_to do |format|
      if @feed.update(feed_params)
        body, ok = SuperfeedrEngine::Engine.unsubscribe(@feed)
        if !ok
          render :edit, notice: "Feed was succesfully updated, but we could not unsubscribe and resubscribe it. #{body}"
      else
        body, ok = SuperfeedrEngine::Engine.subscribe(@feed)
        if !ok
          render :edit, notice: "Feed was successfully updated, but we could not unsubscribe and resubscribe it #{body}"
        else
          redirect_to @feed, notice: 'Feed was successfully updated.'
        end
      end
    else
      render :edit
    end
   end
  end

  # DELETE /feeds/1
  # DELETE /feeds/1.json
  def destroy
    respond_to do |format|
      body, ok = SuperfeedrEngine::Engine.unsubscribe(@feed)
      if !ok
        redirect_to @feed, notice: body
      else
        @feed.destroy
        redirect_to feeds_url, notice: "Feed was succesfully destroyed"
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_feed
      @feed = Feed.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def feed_params
      params.require(:feed).permit(:title, :url)
    end
end
