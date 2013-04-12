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
    @applicant_score = applicant_score
    @target_score = target_score
  end

  def analyze
    @target_score.nil? ? text_without_target : text_with_target
  end

  private

  def text_without_target
    @applicant_score > 60 ? INSIGHTS[:applicant_overdeveloped_text] : INSIGHTS[:applicant_underdeveloped_text]
  end

  def text_with_target
    if @applicant_score < 40 # underdeveloped
      if @target_score < 40
        if @applicant_score < @target_score
          return INSIGHTS[:target_low_applicant_more_underdeveloped_text]
        elsif @applicant_score > @target_score
          return INSIGHTS[:target_low_applicant_less_underdeveloped_text]
        else
          return INSIGHTS[:target_low_applicant_less_underdeveloped_text]
        end
      elsif @target_score > 60
        return INSIGHTS[:target_high_applicant_underdeveloped_text]
      else
        return INSIGHTS[:target_general_applicant_underdeveloped_text]
      end
    elsif @applicant_score > 60 #overdeveloped
      if @target_score < 40
        return INSIGHTS[:target_low_applicant_overdeveloped_text]
      elsif @target_score > 60
        if @applicant_score > @target_score
          return INSIGHTS[:target_high_applicant_more_overdeveloped_text]
        elsif @applicant_score < @target_score
          return INSIGHTS[:target_high_applicant_less_overdeveloped_text]
        else
          return INSIGHTS[:target_high_applicant_less_overdeveloped_text]
        end
      else
        return INSIGHTS[:target_general_applicant_overdeveloped_text]
      end
    end
  end
end
