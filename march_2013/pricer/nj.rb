module Pricer
  class Nj
    def self.pages_price(number_of_pages, requested_by_doctor = false)
      return 0 if number_of_pages <= 0
      price_per_page_low = 1.00
      search_fee = 10.00
      if number_of_pages > 100
         temp =  100 * price_per_page_low + (number_of_pages-100) * 0.25 + search_fee
         return temp>200 ? 200.00 : temp.round(2)
      else
         return number_of_pages * price_per_page_low + search_fee
      end
    end

  end
end