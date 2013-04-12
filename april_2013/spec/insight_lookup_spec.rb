require "./insight_lookup.rb"

describe InsightLookup do
  describe "#analyze" do
    context 'no target score' do
      it('returns right text with applicant score in low critical range') { InsightLookup.new(20, nil).analyze.should == 'applicant underdeveloped text' }
      it('returns right text with applicant score in general range') { InsightLookup.new(50, nil).analyze.should == 'applicant underdeveloped text' }
      it('returns right text with applicant score in high critical range') { InsightLookup.new(80, nil).analyze.should == 'applicant overdeveloped text' }
    end

    context 'target score in low critical range' do
      it('returns right text with applicant score in low critical range and lower than target') { InsightLookup.new(19, 20).analyze.should == 'target low applicant more underdeveloped text' }
      it('returns right text with applicant score in low critical range and equal to target') { InsightLookup.new(20, 20).analyze.should == 'target low applicant less underdeveloped text' }
      it('returns right text with applicant score in low critical range and higher than target') { InsightLookup.new(21, 20).analyze.should == 'target low applicant less underdeveloped text' }
      it('returns right text with applicant score in general range') { InsightLookup.new(50, 20).analyze.should == nil }
      it('returns right text with applicant score in high critical range') { InsightLookup.new(80, 20).analyze.should == 'target low applicant overdeveloped text' }
    end

    context 'target score in general range' do
      it('returns right text with applicant score in low critical range') { InsightLookup.new(20, 50).analyze.should == 'target general applicant underdeveloped text' }
      it('returns right text with applicant score in general range and lower than target') { InsightLookup.new(49, 50).analyze.should == nil }
      it('returns right text with applicant score in general range and equal to target') { InsightLookup.new(50, 50).analyze.should == nil }
      it('returns right text with applicant score in general range and higher than target') { InsightLookup.new(51, 50).analyze.should == nil }
      it('returns right text with applicant score in high critical range') { InsightLookup.new(80, 50).analyze.should == 'target general applicant overdeveloped text' }
    end

    context 'target score in high critical range' do
      it('returns right text with applicant score in low critical range') { InsightLookup.new(20, 80).analyze.should == 'target high applicant underdeveloped text' }
      it('returns right text with applicant score in general range') { InsightLookup.new(50, 80).analyze.should == nil }
      it('returns right text with applicant score in high critical range and lower than target') { InsightLookup.new(79, 80).analyze.should == 'target high applicant less overdeveloped text' }
      it('returns right text with applicant score in high critical range and equal to target') { InsightLookup.new(80, 80).analyze.should == 'target high applicant less overdeveloped text' }
      it('returns right text with applicant score in high critical range and higher than target') { InsightLookup.new(81, 80).analyze.should == 'target high applicant more overdeveloped text' }
    end
  end
end
