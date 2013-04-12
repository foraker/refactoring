class InsightLookup

  def initialize(applicant_score, target_score)
    @applicant_score = applicant_score
    @target_score = target_score
  end

  def analyze
    target = nil
    applicant = ""
    moreless = ["more", "less"]
    
    unless @target_score.nil?
      target = "target "
      if @target_score < 40
        target += "low "
      elsif @target_score > 60
        target += "high "
        # moreless = ["less", "more"]
      else
        target += "general "
      end
    end
    
    if @applicant_score > 60 #overdeveloped
      if target == "target high "
        if @applicant_score > @target_score
          applicant = "#{moreless[0]} "
        else
          applicant = "#{moreless[1]} "
        end
      end
      applicant += "overdeveloped"
    elsif @applicant_score < 40 || @target_score.nil?
      if target == "target low "
        if @applicant_score < @target_score
          applicant = "#{moreless[0]} "
        else
          applicant = "#{moreless[1]} "
        end
      end
      applicant += "underdeveloped"
    end
    
    if applicant == ""
      return nil
    end
    
    return "#{target}applicant #{applicant} text"
  end
  
end
