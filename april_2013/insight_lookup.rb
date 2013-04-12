class InsightLookup
  INSIGHTS = {
    :applicant_overdeveloped_text                  => 'applicant overdeveloped text',
    :applicant_underdeveloped_text                 => 'applicant underdeveloped text',
    :target_general_applicant_overdeveloped_text   => 'target general applicant overdeveloped text',
    :target_general_applicant_underdeveloped_text  => 'target general applicant underdeveloped text',
    :target_high_applicant_more_overdeveloped_text => 'target high applicant more overdeveloped text',
    :target_high_applicant_less_overdeveloped_text => 'target high applicant less overdeveloped text',
    :target_high_applicant_underdeveloped_text     => 'target high applicant underdeveloped text',
    :target_low_applicant_more_underdeveloped_text => 'target low applicant more underdeveloped text',
    :target_low_applicant_less_underdeveloped_text => 'target low applicant less underdeveloped text',
    :target_low_applicant_overdeveloped_text       => 'target low applicant overdeveloped text',
  }

  attr_accessor :applicant, :target

  def initialize(applicant_score, target_score)
    self.applicant = Applicant.new(applicant_score)
    self.target    = Target.new(target_score)
  end

  def analyze
    INSIGHTS[key.to_sym] if !key.nil? and INSIGHTS.has_key?(key.to_sym)
  end

  private

  def key
    has_target? ? text_with_target : text_without_target
  end

  def has_target?
    target.has_score?
  end

  class Applicant
    attr_accessor :score

    def initialize(score)
      @score = score
    end

    def underdeveloped?
      @score < 40
    end

    def overdeveloped?
      @score > 60
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

  def text_without_target
    applicant.overdeveloped? ? :applicant_overdeveloped_text : :applicant_underdeveloped_text
  end

  def text_with_target
    return text_with_target_when_underdeveloped if applicant.underdeveloped?
    return text_with_target_when_overdeveloped if applicant.overdeveloped?
  end

  def text_with_target_when_underdeveloped
    if target.low?
      if applicant.under?(target.score)
        return :target_low_applicant_more_underdeveloped_text
      elsif applicant.over?(target.score)
        return :target_low_applicant_less_underdeveloped_text
      else
        return :target_low_applicant_less_underdeveloped_text
      end
    elsif target.high?
      return :target_high_applicant_underdeveloped_text
    else
      return :target_general_applicant_underdeveloped_text
    end
  end

  def text_with_target_when_overdeveloped
    if target.low?
      return :target_low_applicant_overdeveloped_text
    elsif target.high?
      if applicant.over?(target.score)
        return :target_high_applicant_more_overdeveloped_text
      elsif applicant.under?(target.score)
        return :target_high_applicant_less_overdeveloped_text
      else
        return :target_high_applicant_less_overdeveloped_text
      end
    else
      return :target_general_applicant_overdeveloped_text
    end
  end
end
