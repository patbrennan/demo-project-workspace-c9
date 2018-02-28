module VoteablePb
  extend ActiveSupport::Concern # makes all methods instance methods of the class when included
  
  included do
    # when included, execute this code
    has_many :votes, as: :voteable
  end
  
  def vote_count
    self.up_votes - self.down_votes
  end
  
  def up_votes
    self.votes.where(vote: true).size
  end
  
  def down_votes
    self.votes.where(vote: false).size
  end
end