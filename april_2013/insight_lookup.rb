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
    #removed ternary operator so easier to read
    #made negative easier to read by removing check for nil
    if @target_score
      text_with_target
    else
      text_without_target
    end
  end

  private

  def text_without_target
    #removed ternary operator so easier to read
    #made negative easier to read by removing check for nil
    if @applicant_score > 60
      INSIGHTS[:applicant_overdeveloped_text]
    else
      INSIGHTS[:applicant_underdeveloped_text]
    end
  end
  
  
  def text_with_target
    #changed to case statements so easier to read
    case @applicant_score
    
    when 0..39 then
      text_with_low_target
    when 61..100 then
      text_with_high_target
    end
  end

  def text_with_low_target
   #changed to case statements so easier to read
   
    case @target_score
   
     when 0..39 then
       low_target_score
     when 40..60 then
       return INSIGHTS[:target_general_applicant_underdeveloped_text]
     when 61..100 then
       return INSIGHTS[:target_high_applicant_underdeveloped_text]
     end
  
  end #def
  
  def text_with_high_target    
    case @target_score

    when 0..39 then
         return INSIGHTS[:target_low_applicant_overdeveloped_text]
    when 40..60 then
        return INSIGHTS[:target_general_applicant_overdeveloped_text]
    when 61..100 then
          high_target_score
    end
    
  end #def
  
  def low_target_score
    if @applicant_score < @target_score
      return INSIGHTS[:target_low_applicant_more_underdeveloped_text]
    else
      return INSIGHTS[:target_low_applicant_less_underdeveloped_text]
    end
  end #def
  
  def high_target_score
     if @applicant_score > @target_score
        return INSIGHTS[:target_high_applicant_more_overdeveloped_text]
      else
        return INSIGHTS[:target_high_applicant_less_overdeveloped_text]
      end
  end #def
end #class
