module Pricer
  class Il
    IL_HANDLING_CHARGE = 25.55
    IL_FIRST_25 = IL_HANDLING_CHARGE + 0.96 * 25
    IL_FIRST_50 = IL_FIRST_25 + 0.64 * 50

    def self.pages_price(number_of_pages, requested_by_doctor = false)
      return IL_HANDLING_CHARGE if number_of_pages < 1
      return (IL_FIRST_50 + (number_of_pages - 50) * 0.32) if number_of_pages > 50
      return (IL_FIRST_25 + (number_of_pages - 25) * 0.64) if number_of_pages > 25
      return (IL_HANDLING_CHARGE + (number_of_pages) * 0.96)
    end
  end
end