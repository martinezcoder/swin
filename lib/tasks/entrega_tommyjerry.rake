namespace :db do
  
  task delete_broken_data_days: :environment do
    delete_broken_data_days
  end

  task delete_broken_data_days: :environment do
    create_and_set_free_plan_to_all_users
  end


  def delete_broken_data_days
    days = PageDataDay.where("day > ?", 99999999)
    days.each do |d|
      d.destroy
    end
    stream = PageStream.all
    stream.each do |s|
      s.destroy
    end
  end

  def create_and_set_free_plan_to_all_users
    free = Plan.new
    free.name = "free"
    free.num_competitors = 10
    free.num_lists = 2
    free.price = 0.0
    free.save
    users = User.all
    users.each do |u|
      u.set_plan!(free)
      u.save 
    end
  end

end