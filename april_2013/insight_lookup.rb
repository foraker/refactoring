class InsightLookup
  INSIGHTS = {
    :overdeveloped           => 'applicant overdeveloped text',
    :underdeveloped          => 'applicant underdeveloped text',
    :general_overdeveloped   => 'target general applicant overdeveloped text',
    :general_underdeveloped  => 'target general applicant underdeveloped text',
    :high_more_overdeveloped => 'target high applicant more overdeveloped text',
    :high_less_overdeveloped => 'target high applicant less overdeveloped text',
    :high_underdeveloped     => 'target high applicant underdeveloped text',
    :low_more_underdeveloped => 'target low applicant more underdeveloped text',
    :low_less_underdeveloped => 'target low applicant less underdeveloped text',
    :low_overdeveloped       => 'target low applicant overdeveloped text',
  }

  def initialize(applicant_score, target_score)
    @applicant_score = Score.new(applicant_score)
    @target_score    = Score.new(target_score)
  end

  def analyze
    @target_score.present? ? text_with_target : text_without_target
  end

  private

  def text_without_target
   @applicant_score.high? ? INSIGHTS[:overdeveloped] : INSIGHTS[:underdeveloped]
  end

  def text_with_target
    keys = [@target_score.to_key]

    if @applicant_score.general?
      return nil
    elsif @applicant_score.low?
      keys << @target_score.relative_to(:low, @applicant_score)
      keys << 'underdeveloped'
    elsif @applicant_score.high?
      keys << @target_score.relative_to(:high, @applicant_score)
      keys << 'overdeveloped'
    end

    INSIGHTS[keys.compact.join('_').to_sym]
  end

  class Score
    LOW_THRESHOLD  = 40
    HIGH_THRESHOLD = 60

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def low?
      @value < LOW_THRESHOLD
    end

    def high?
      @value > HIGH_THRESHOLD
    end

    def general?
      @value >= LOW_THRESHOLD && @value <= HIGH_THRESHOLD
    end

    def >(other)
      @value > other.value
    end

    def <(other)
      @value < other.value
    end

    def present?
      !@value.nil?
    end

    def relative_to(target, other)
      if target == :low && low?
        (self > other) ? 'more' : 'less'
      elsif target == :high && high?
        (self < other) ? 'more' : 'less'
      end
    end

    def to_key
      if low?
        'low'
      elsif high?
        'high'
      else
        'general'
      end
    end
  end

end