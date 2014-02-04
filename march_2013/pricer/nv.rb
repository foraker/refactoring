module Pricer
  class Nv
    def self.pages_price(number_of_pages, requested_by_doctor = false)
      0.60 * number_of_pages #No administrative fee or additional service fee of any kind may be charged for furnishing a copy
    end
  end
end