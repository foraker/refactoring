module Pricer
  class Ut
    def self.pages_price(number_of_pages, requested_by_doctor = false)
      return 0 if number_of_pages <= 0
      15.00 + number_of_pages * 0.50
    end
  end
end