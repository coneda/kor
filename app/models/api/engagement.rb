class Api::Engagement < ActiveRecord::Base
  
  self.table_name = 'engagements'
  
  belongs_to :user
  belongs_to :related, :polymorphic => true
  has_many :additional, :as => :related, :class_name => "Api::Engagement", :conditions => "related_type = 'Api::Engagement'"
  
  validates_presence_of :user_id, :kind
  
  def user_credits
    user.credits
  end
  
  def self.in_a_row(user)
    result = {}
    
    reward_models.each do |name, config|
      max_in_a_row = config[:bonuses].keys.sort.last
      time_sum = config[:time_per_reward] * max_in_a_row
      user.engagements.
        where('created_at >= ?', Time.now - time_sum).
        group(:kind).
        count
    end
    
    
  end
  
  def self.reward(options = {})
    options[:kind] ||= 'rating'
    options[:reward_model] ||= :default
    options[:in_a_row] ||= 1
  
    m = reward_models[options[:reward_model]]
    
    engagement = create(
      :user => options[:user],
      :kind => options[:kind],
      :related => options[:related],
      :credits => m[:base_reward]
    )
    
    if m[:bonuses][options[:in_a_row]]
      create(
        :user => options[:user],
        :kind => "bonus_#{options[:in_a_row]}_in_a_row",
        :related => engagement,
        :credits => m[:bonuses][options[:in_a_row]],
        :in_a_row => options[:in_a_row]
      )
    else
      engagement
    end
  end
  
  def self.reward_models
    return {
      :default => {
        :base_reward => 1,
        :time_per_reward => 10.seconds,
        :bonuses => {
          5 => 1,
          25 => 6,
          100 => 25,
          250 => 65,
          500 => 150,
          1000 => 350
        } 
      }
    }
  end
  
  attr_accessor :in_a_row
  
end
