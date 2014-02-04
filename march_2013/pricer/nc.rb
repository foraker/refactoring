module Pricer
  class Nc
    NC_FIRST_25 = 0.75 * 25
    NC_FIRST_100 = NC_FIRST_25 + 0.50 * 75
    NC_MIN_CHARGE = 10.00

    def self.pages_price(number_of_pages, requested_by_doctor = false)
      return (NC_FIRST_100 + (number_of_pages - 100) * 0.25) if number_of_pages > 100
      return (NC_FIRST_25 + (number_of_pages -  25) * 0.50) if number_of_pages > 25
      price = ((number_of_pages) * 0.75)
      return NC_MIN_CHARGE if price < NC_MIN_CHARGE #min charge
      return price
    end
  end
end
