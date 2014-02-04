module Pricer
  class Default

    def self.pages_price(number_of_pages, requested_by_doctor = false)
      if requested_by_doctor
        fee = 60.00 + number_of_pages * 1.00
      else
        return 185.00
      end
    end
  end

end