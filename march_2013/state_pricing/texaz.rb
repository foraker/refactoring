require File.expand_path("../state_base", __FILE__)

module StatePricing
  class Texaz
    MIN_CHARGE = 25.00

    def self.price(request, number_of_pages)
      new(request, number_of_pages).price
    end

    def price
      return  MIN_CHARGE if number_of_pages <= 20
      return (MIN_CHARGE + (number_of_pages - 20) * 0.50)
    end

    private

    attr_reader :number_of_pages

    def initialize(request, number_of_pages)
      @number_of_pages = number_of_pages
    end

  end
end

