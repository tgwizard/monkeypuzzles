MonkeyPuzzles.controllers :categories do
  # get :sample, :map => "/sample/url", :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  get :index do
    @categories = Category.all
    render "categories/index"
  end

  get :show, :map => "categories/:slug" do
    @category = Category.find params[:slug]
    if @category.nil?
      raise error 404
    end
    @puzzles = @category.puzzles
    @title = "#{@category.title} puzzles"
    render "categories/show"
  end

end
