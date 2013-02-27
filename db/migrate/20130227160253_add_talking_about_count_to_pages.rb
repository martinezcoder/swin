class AddTalkingAboutCountToPages < ActiveRecord::Migration
  def change
    add_column :pages, :talking_about_count, :integer
  end
end
