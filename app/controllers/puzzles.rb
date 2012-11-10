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

end
