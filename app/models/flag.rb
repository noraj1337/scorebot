class Flag < ActiveRecord::Base
  belongs_to :team
  belongs_to :service
  has_many :captures

  TOTAL_FLAGS = 50_120

  def self.reallocate(ending_round)
    transaction do
      scoring_teams = Team.
        joins(:redemptions).
        where(redemptions: {round: ending_round}).
        distinct.to_a

      divisor = scoring_teams.length
      available = Team.legitbs.flags.length

      return if (divisor == 0) || (available == 0)
      
      bundle_size = (available / divisor).floor
      remainder = available % divisor

      until scoring_teams.empty?
        team = scoring_teams.pop
        Team.legitbs.flags.limit(bundle_size).each do |f|
          f.team = team
          f.save
        end
      end
    end
  end
end
