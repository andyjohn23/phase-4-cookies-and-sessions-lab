class ArticlesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordNotFound, with: :article_limit_reached

  def index
    articles = Article.all.includes(:user).order(created_at: :desc)
    render json: articles, each_serializer: ArticleListSerializer
  end

  def show
    article = Article.find(params[:id])
    cookies[:page_views] ||=0
    cookies[:page_views] = cookies[:page_views].to_i + 1
    session[:page_views] ||=0
    session[:page_views] += 1
    session[:page_view_remaaining] = 3
    render json: article
  end

  private

  def record_not_found
    render json: { error: "Article not found" }, status: :not_found
  end

  def article_limit_reached
    if session[:page_views] > 3
      render json: {error: "Article viewing limit reached"}, status: :unauthorized
    end
  end

end
