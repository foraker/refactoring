require File.expand_path("../state_base", __FILE__)

module StatePricing
  class Illinois < StateBase
    HANDLING_CHARGE = 25.55
    FIRST_25 = HANDLING_CHARGE + 0.96 * 25
    FIRST_50 = FIRST_25 + 0.64 * 50

    def self.price(request, number_of_pages)
      self.new(number_of_pages).price
    end

    def price
      return HANDLING_CHARGE if number_of_pages < 1
      return (FIRST_50 + (number_of_pages - 50) * 0.32) if number_of_pages > 50
      return (FIRST_25 + (number_of_pages - 25) * 0.64) if number_of_pages > 25
      return (HANDLING_CHARGE + (number_of_pages) * 0.96)
    end

    def initialize(number_of_pages)
      @number_of_pages = number_of_pages
    end

    private
    
    attr_reader :number_of_pages
  end
end