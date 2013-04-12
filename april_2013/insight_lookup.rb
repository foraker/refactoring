class InsightLookup
  INSIGHTS = {
    no_target: {
      overdeveloped_applicant: {
        bullseye: 'applicant overdeveloped text',
      },
      underdeveloped_applicant: {
        bullseye: 'applicant underdeveloped text',
      },
      general_applicant: {
        bullseye: 'applicant underdeveloped text',
      },
    },

    general_target: {
      overdeveloped_applicant: {
        bullseye: 'target general applicant overdeveloped text',
      },
      underdeveloped_applicant: {
        bullseye: 'target general applicant underdeveloped text',
      },
    },

    high_target: {
      overdeveloped_applicant: {
        overshot: 'target high applicant more overdeveloped text',
        bullseye: 'target high applicant less overdeveloped text',
        undershot: 'target high applicant less overdeveloped text',
      },
      underdeveloped_applicant: {
        undershot: 'target high applicant underdeveloped text',
        bullseye: 'target high applicant underdeveloped text',
      },
    },

    low_target: {
      overdeveloped_applicant: {
        undershot: 'target low applicant overdeveloped text',
        bullseye: 'target low applicant overdeveloped text',
      },
      underdeveloped_applicant: {
        undershot: 'target low applicant less underdeveloped text',
        bullseye: 'target low applicant less underdeveloped text',
        overshot: 'target low applicant more underdeveloped text',
      },
    },
  }

  attr_accessor :applicant, :target

  def initialize(applicant_score, target_score)
    self.applicant = Applicant.new(applicant_score)
    self.target    = Target.new(target_score)
  end

  def analyze
    begin
      INSIGHTS[target_key][applicant_key][overshoot_key]
    rescue NoMethodError
      nil
    end
  end

  private

  def target_key
    "#{target.state}_target".to_sym
  end

  def applicant_key
    "#{applicant.state}_applicant".to_sym
  end

  def overshoot_key
    if !target.has_score?
      return :bullseye
    end

    if target.high?
      return :overshot if applicant.over?(target.score)
      return :undershot if applicant.under?(target.score)
    end

    if target.low?
      return :overshot if applicant.under?(target.score)
      return :undershot if applicant.over?(target.score)
    end

    return :bullseye
  end

  class Applicant
    attr_accessor :score

    def initialize(score)
      @score = score
    end

    def state
      return 'general' if general?
      return 'overdeveloped' if overdeveloped?
      return 'underdeveloped'
    end

    def underdeveloped?
      @score < 40
    end

    def overdeveloped?
      @score > 60
    end

    def general?
      @score < 60 and @score > 40
    end

    def over?(score)
      self.score > score
    end

    def under?(score)
      self.score < score
    end
  end

  class Target
    attr_accessor :score

    def initialize(score)
      @score = score
    end

    def state
      return :no if !has_score?
      return :general if general?
      return :low if low?
      return :high if high?
    end

    def low?
      @score < 40
    end

    def high?
      @score > 60
    end

    def general?
      @score < 60 and @score > 40
    end

    def has_score?
      !score.nil?
    end
  end
end
