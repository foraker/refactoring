require 'pricer_factory'

describe "#get_pricer" do
   let(:request) do
    stub(state: "CO", number_of_pages: 2, requested_by_doctor?: false)
  end

    let(:pricer_factory) { PricerFactory.new(request) }

  it "returns the appropriate pricer based on request"
  it "returns a default pricer if no specific pricer is found"
end
