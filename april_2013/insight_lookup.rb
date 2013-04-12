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
    @applicant_score = ApplicantScore.new(applicant_score)
    @target_score = TargetScore.new(target_score)
  end

  def analyze
    @target_score.score.nil? ? text_without_target : text_with_target
  end

  private
  def text_without_target
    @applicant_score.overdeveloped? ? INSIGHTS[:applicant_overdeveloped_text] : INSIGHTS[:applicant_underdeveloped_text]
  end

  def text_with_target
    target_key = @target_score.target_key
    applicant_modifier = @applicant_score.applicant_modifier_key(@target_score)
    insight_key = "#{target_key}_applicant_#{applicant_modifier}_text".to_sym
    puts insight_key
    return INSIGHTS[insight_key]
  end

  class Score
    include Comparable
    attr_accessor :score

    def initialize(score)
      @score = score
    end

    def underdeveloped?
      score < 40
    end

    def overdeveloped?
      score > 60
    end

    def <=> other
      if other.respond_to? :score
        score <=> other.score
      else
        score <=> other
      end
    end
  end

  class ApplicantScore < Score

    def applicant_modifier_key(target_score)
      modifier = if target_score.underdeveloped?
          if score < target_score.score
            "more_"
          elsif score >= target_score.score
            "less_"
          end
        elsif target_score.overdeveloped?
          if score > target_score.score
            "more_"
          elsif score <= target_score.score
            "less_"
          end
        else
          ""
        end
      
      status = if overdeveloped?
          "overdeveloped"
        elsif underdeveloped?
          "underdeveloped"
        else
          ""
        end      
      modifier + status
    end
    
    def applicant_status
    end
  end

  class TargetScore < Score
    def target_key
      if underdeveloped?
        "target_low"
      elsif overdeveloped?
        "target_high"
      else
        "target_general"
      end
    end
  end
end
