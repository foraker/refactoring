require File.expand_path("../request_pricing_service", __FILE__)

describe RequestPricingService do
  let(:request) do
    stub(state: "CO", number_of_pages: 2, requested_by_doctor?: false)
  end

  describe "Illinois pricing" do
    before { request.stub(state: "IL") }

    it { should charge(25.55).for(0).pages }
    it { should charge(26.51).for(1).pages }
    it { should charge(48.59).for(24).pages }
    it { should charge(49.55).for(25).pages }
    it { should charge(65.55).for(50).pages }
    it { should charge(82.19).for(52).pages }
  end

  describe "Texas pricing" do
    before { request.stub(state: "TX") }

    it { should charge(25.00).for(0).pages }
    it { should charge(25.00).for(1).pages }
    it { should charge(25.00).for(19).pages }
    it { should charge(25.00).for(20).pages }
    it { should charge(25.50).for(21).pages }
  end

  describe "Indiana pricing" do
    before { request.stub(state: "IN") }

    it { should charge(20.00).for(0).pages }
    it { should charge(20.00).for(1).pages }
    it { should charge(20.00).for(10).pages }
    it { should charge(13.00).for(11).pages }
    it { should charge(32.50).for(50).pages }
    it { should charge(52.25).for(51).pages }
  end

  describe "North Carolina pricing" do
    before { request.stub(state: "NC") }

    it { should charge(10.00).for(0).pages }
    it { should charge(10.00).for(1).pages }
    it { should charge(18.75).for(25).pages }
    it { should charge(19.25).for(26).pages }
    it { should charge(56.25).for(100).pages }
    it { should charge(56.50).for(101).pages }
  end

  describe "New Jersey pricing" do
    before { request.stub(state: "NJ") }

    it { should charge(0).for(0).pages }
    it { should charge(11.00).for(1).pages }
    it { should charge(20.00).for(10).pages }
    it { should charge(110.00).for(100).pages }
    it { should charge(110.25).for(101).pages }
  end

  describe "California pricing" do
    before { request.stub(state: "CA") }

    it { should charge(4.00).for(0).pages }
    it { should charge(4.10).for(1).pages }
    it { should charge(5.00).for(10).pages }
  end

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

  describe "Nevada pricing" do
    before { request.stub(state: "NV") }

    it { should charge(0).for(0).pages }
    it { should charge(0.60).for(1).pages }
    it { should charge(6.00).for(10).pages }
  end

  describe "Utah pricing" do
    before { request.stub(state: "UT") }

    it { should charge(0).for(0).pages }
    it { should charge(15.50).for(1).pages }
    it { should charge(20.00).for(10).pages }
  end

  describe "a state without specific pricing statutes" do
    #before { request.stub(state: "CO") }
    before { request.stub(state: "CO") }
    it { should charge(185.00).for(0).pages }
    it { should charge(185.00).for(1).pages }
    it { should charge(185.00).for(10).pages }

    context "a doctor request" do
      before { request.stub(:requested_by_doctor? => true) }

      it { should charge(60.00).for(0).pages }
      it { should charge(61.00).for(1).pages }
      it { should charge(70.00).for(10).pages }
    end
  end
end

RSpec::Matchers.define :charge do |expected|
  chain :for do |page_count|
    @page_count = page_count
  end

  chain :pages do
    # Only for DSL readability
  end

  match do |actual|
    @price = described_class.price(request, @page_count)
    @price == expected
  end

  failure_message_for_should do
    "expected #{@page_count} pages to cost $#{expected}, got $#{@price}"
  end
end