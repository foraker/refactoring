module Pricer
  class Ca
    CA_TIME_CHARGE = 4.00

    def self.pages_price(number_of_pages, requested_by_doctor = false)
      0.10 * number_of_pages + CA_TIME_CHARGE
    end
  end
end