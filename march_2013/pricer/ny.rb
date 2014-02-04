module Pricer
  class Ny
    def self.pages_price(number_of_pages, requested_by_doctor = false)
      if requested_by_doctor
        number_of_pages * 0.75
      else
        if number_of_pages <=15
          return number_of_pages * 2.00
        else
          return 15 * 2.00 + ((number_of_pages - 15) * 1.00)
        end
      end
    end
  end
end