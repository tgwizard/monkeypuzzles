MonkeyPuzzles.controllers :puzzles do
  # get :sample, :map => "/sample/url", :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  get :index, :provides => [:html, :atom, :rss] do
    @puzzles = Puzzle.all
    @title = "All puzzles"
    render "puzzles/index"
  end

  get :show, :map => "puzzles/:slug" do
    @puzzle = Puzzle.find params[:slug]
    raise error 404 if @puzzle.nil?
    @title = @puzzle.title
    render "puzzles/show_puzzle"
  end

  get :show_answer, :map => "puzzles/:slug/answer" do
    @puzzle = Puzzle.find params[:slug]
    raise error 404 if @puzzle.nil?
    @title = "Answer for #{@puzzle.title}"
    render "puzzles/show_answer"
  end

  post :like, :map => '/puzzles/:slug/like', :provides => :json do
    require_login!
    puzzle = Puzzle.find params[:slug]
    raise error 404 if puzzle.nil?
    action = params[:action]

    case action
    when 'like'
      like = Like.where(:puzzle_id => puzzle.id, :user_id => user.id).first
      if !like
        like = Like.new(:puzzle_id => puzzle.id, :user_id => user.id)
        if !like.save
          raise error 500, "Can't save like: #{like.errors.full_messages}"
        end
      end
    when 'unlike'
      like = Like.where(:puzzle_id => puzzle.id, :user_id => user.id).destroy_all
    else
      raise error 401, "Unknown action #{action}"
    end

    puzzle.reset_likes!

    render :status => 'ok', :action => action, :num_likes => puzzle.num_likes
  end

  post :comments, :map => "puzzles/:slug/comments", :provides => :json do
    require_login!
    puzzle = Puzzle.find params[:slug]
    raise error 404 if puzzle.nil?

    content = params[:content].strip

    c = Comment.new(:puzzle_id => puzzle.id, :content => content, :user_id => user.id)
    if !c.save
      flash[:comment] = c.errors.full_messages
      redirect url_for(:puzzles, :show, :slug => puzzle.slug) + '#post-comment'
    else
      puzzle.reset_comments!
      redirect url_for(:puzzles, :show, :slug => puzzle.slug)
    end
  end
end
