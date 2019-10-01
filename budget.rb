require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:budget] ||= []
end

helpers do
  def update_total
    total = 0
    @budget.each do |indiv_budgets|
      total += indiv_budgets[:amount].to_i
    end
    total
  end

  def todate_spending_total
    todate_spending = 0
    @budget.each do |indiv_budgets|
      todate_spending += indiv_budgets[:todate]
    end
    todate_spending
  end

  def amount_left_total
    amount_left = 0
    @budget.each do |indiv_budgets|
      amount_left += (indiv_budgets[:amount].to_i - indiv_budgets[:todate].to_i)
    end
    amount_left
  end

  def find_months
    # code to get an array on months included so far in the data
  end
end

get "/" do
  redirect "/budget"
end

get "/budget" do
  @budget = session[:budget]
  erb :budget
end

get "/new_category" do
  erb :new_category
end

# go to overall month budget
get "/budget/months" do
  @budget = session[:budget]
  erb :months
end

# go to specific month's budget
get "/budget/:month" do
  redirect "/"
end

# add a new category
post "/new_category" do
  category_name = params[:category_name]
  category_amount = params[:category_amount]
  @todate_amount = 0
  session[:budget] << {category: category_name, amount: category_amount, todate: @todate_amount}
  session[:success] = "The budget has been created."
  redirect "/budget"
end

# add to current spending
post "/new_spending/:id" do
  id = params[:id].to_i
  amount = params[:new_spending].to_i
  session[:budget][id][:todate] += amount

  redirect "/budget"
end
