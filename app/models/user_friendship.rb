class UserFriendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'

  attr_accessible :user, :friend, :user_id, :friend_id, :state

  state_machine :state, initial: :pending do
  	after_transition on: :accept, do: :send_acceptance_email

  	state :requested

  	event :accept do
  		transition any => :accepted
  	end
  end

  #use self. for class method
  def self.request(user1, user2)
  	#use transaction - if something wrong, neither friendship will be created
  	transaction do
  		#can use create instead of UserFriendship.create in class method
  		friendship1 = create!(user: user1, friend: user2, state: 'pending')
  		friendship2 = create!(user: user2, friend: user1, state: 'requested')
 		
  		friendship1.send_request_email
  		friendship1
 		end
  end

  def send_request_email
  	UserNotifier.friend_requested(id).deliver
  end

  def send_acceptance_email
  	UserNotifier.friend_request_accepted(id).deliver
  end
end
