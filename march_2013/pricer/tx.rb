module Pricer
  class Tx
    TX_MIN_CHARGE = 25.00

    def self.pages_price(number_of_pages, requested_by_doctor = false)
      return TX_MIN_CHARGE if number_of_pages <= 20
      return (TX_MIN_CHARGE + (number_of_pages - 20) * 0.50)
    end
  end
end