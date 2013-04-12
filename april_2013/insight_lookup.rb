class InsightLookup < Struct.new(:applicant_score, :target_score)
  def analyze
    {
      [20, nil] => 'applicant underdeveloped text',
      [50, nil] => 'applicant underdeveloped text',
      [80, nil] => 'applicant overdeveloped text',
      [19, 20] => 'target low applicant more underdeveloped text',
      [20, 20] => 'target low applicant less underdeveloped text',
      [21, 20] => 'target low applicant less underdeveloped text',
      [80, 20] => 'target low applicant overdeveloped text',
      [20, 50] => 'target general applicant underdeveloped text',
      [80, 50] => 'target general applicant overdeveloped text',
      [20, 80] => 'target high applicant underdeveloped text',
      [79, 80] => 'target high applicant less overdeveloped text',
      [80, 80] => 'target high applicant less overdeveloped text',
      [81, 80] => 'target high applicant more overdeveloped text',
    }[[applicant_score, target_score]]
  end
end