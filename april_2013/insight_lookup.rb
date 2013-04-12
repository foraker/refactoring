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

  def initialize(applicant_score, target_score)
    @applicant_score = Score.create_score(applicant_score)
    @target_score    = Score.create_score(target_score)
  end

  def analyze
    @applicant_score.text_with_target(@target_score)
  end

  private

  class Score < Struct.new(:score)
    include Comparable

    def self.create_score(score)
      return nil if score.nil?

      case
      when score > 60 then OverDevelopedScore.new(score)
      when score < 40 then UnderDevelopedScore.new(score)
      else Score.new(score)
      end
    end

    def <=>(other_score)
      score <=> other_score.score
    end

    def nil?
      score.nil?
    end

    def text_with_target(target_score)
      ApplicantText.new(target_score, self).to_s
    end

    def prefix
      'target_general'
    end

    def suffix
      'underdeveloped_text'
    end
  end

  class ApplicantText < Struct.new(:target_score, :applicant_score)

    def to_s
      return nil if applicant_score.instance_of?(Score) && !target_score.nil?

      INSIGHTS[[prefix, 'applicant', middle_key, suffix].compact.join("_").to_sym]
    end

    def middle_key
      middle ? 'more' : 'less' if has_middle?
    end

    def has_middle?
      target_score.class == applicant_score.class
    end

    def has_prefix?
      !target_score.nil?
    end

    def prefix
      target_score.prefix if has_prefix?
    end

    def middle
      applicant_score.middle(target_score)
    end

    def suffix
      applicant_score.suffix
    end
  end

  class OverDevelopedScore < Score
    def text_without_target
      INSIGHTS[:applicant_overdeveloped_text]
    end

    def middle(target_score)
      self > target_score
    end

    def prefix
      'target_high'
    end

    def suffix
      'overdeveloped_text'
    end
  end

  class UnderDevelopedScore < Score
    def underdeveloped?
      true
    end

    def prefix
      'target_low'
    end

    def middle(target_score)
      self < target_score
    end
  end
end
