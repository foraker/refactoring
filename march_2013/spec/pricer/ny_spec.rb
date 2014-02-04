require File.expand_path("../../../pricer/ny", __FILE__)

module Pricer
  describe Ny do
    let (:ny_pricer) { Ny.new }

    it "should return the correct price for 0 pages" do
      ny_pricer.price_for_pages(0).should == 0 
    end

    it "should return the correct price for 1 pages" do
      ny_pricer.price_for_pages(1).should == 2.00
    end
  end
end

=begin
  describe "New York pricing" do
    before { request.stub(state: "NY") }

    it { should charge(0.00).for(0).pages }
    it { should charge(2.00).for(1).pages }
    it { should charge(28.00).for(14).pages }
    it { should charge(30.00).for(15).pages }
    it { should charge(31.00).for(16).pages }

    context "a doctor request" do
      before { request.stub(:requested_by_doctor? => true) }

      it { should charge(0).for(0).pages }
      it { should charge(0.75).for(1).pages }
      it { should charge(7.50).for(10).pages }
    end
  end
=end
