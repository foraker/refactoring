module Pricer
  class In
    IN_LABOR_FEE = 20.00
    IN_FIRST_10 = IN_LABOR_FEE
    IN_FIRST_50 = IN_FIRST_10 + 0.64 * 50

    def self.pages_price(number_of_pages, requested_by_doctor = false)
      return (IN_FIRST_50 + (number_of_pages - 50) * 0.25) if number_of_pages > 50  #>50
      return (IN_FIRST_10 + (number_of_pages - 25) * 0.50) if number_of_pages > 10  # 11-50
      return IN_LABOR_FEE
    end
  end
end