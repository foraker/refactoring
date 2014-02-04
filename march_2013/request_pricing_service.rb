require File.expand_path("../pricer_factory", __FILE__)

class RequestPricingService
  def self.price(request, number_of_pages)
    state_abbreviation = request.state.capitalize
    PricerFactory.factory(state_abbreviation).pages_price(number_of_pages, request.requested_by_doctor?)
  end
end
