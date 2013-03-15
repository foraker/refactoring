require_relative 'states/abbreviations'

class Pricer
  attr_reader :number_of_pages, :request

  def initialize(number_of_pages, request = nil)
    @number_of_pages = number_of_pages
    @request = request
  end
end

class Illinois < Pricer
  HANDLING_CHARGE = 25.55
  FIRST_25 = HANDLING_CHARGE + 0.96 * 25
  FIRST_50 = FIRST_25 + 0.64 * 50

  def price
    case
      when number_of_pages < 1
        HANDLING_CHARGE
      when number_of_pages > 50
        FIRST_50 + (number_of_pages - 50) * 0.32
      when number_of_pages > 25
        FIRST_25 + (number_of_pages - 25) * 0.64
      else
        HANDLING_CHARGE + number_of_pages * 0.96
    end
  end
end

class Texas < Pricer
  MIN_CHARGE = 25.00

  def price
    if number_of_pages <= 20
      MIN_CHARGE
    else
      MIN_CHARGE + (number_of_pages - 20) * 0.50
    end
  end
end

class Indiana < Pricer
  LABOR_FEE = 20.00
  FIRST_10 = LABOR_FEE
  FIRST_50 = FIRST_10 + 0.64 * 50

  def price
    case
      when number_of_pages > 50
        FIRST_50 + (number_of_pages - 50) * 0.25
      when number_of_pages > 10
        FIRST_10 + (number_of_pages - 25) * 0.50
      else
        LABOR_FEE
    end
  end
end

class NorthCarolina < Pricer
  FIRST_25 = 0.75 * 25
  FIRST_100 = FIRST_25 + 0.50 * 75
  MIN_CHARGE = 10.00

  def price
    case
      when number_of_pages > 100
        FIRST_100 + (number_of_pages - 100) * 0.25
      when number_of_pages > 25
        FIRST_25 + (number_of_pages - 25) * 0.50
      else
        price = number_of_pages * 0.75
        price < MIN_CHARGE ? MIN_CHARGE : price
    end
  end
end

class NewJersey < Pricer
  FIRST_100 = 1.00
  AFTER_100 = 0.25
  SEARCH_FEE = 10.00

  def price
    return 0 if number_of_pages <= 0

    if number_of_pages > 100
      temp = SEARCH_FEE + 100 * FIRST_100 + (number_of_pages-100) * AFTER_100
      temp > 200 ? 200.00 : temp.round(2)
    else
      number_of_pages * FIRST_100 + SEARCH_FEE
    end
  end
end

class California < Pricer
  CA_TIME_CHARGE = 4.00

  def price
    0.10 * number_of_pages + CA_TIME_CHARGE
  end
end

class NewYork < Pricer
  FIRST_15 = 2.00
  AFTER_15 = 1.00

  def price
    if request.requested_by_doctor?
      number_of_pages * 0.75
    else
      if number_of_pages <= 15
        number_of_pages * FIRST_15
      else
        15 * FIRST_15 + (number_of_pages - 15) * AFTER_15
      end
    end
  end
end

class Nevada < Pricer
  def price
    0.60 * number_of_pages
  end
end

class Utah < Pricer
  def price
    if number_of_pages <= 0
      0
    else
      15.00 + number_of_pages * 0.50
    end
  end
end

class NoStatute < Pricer
  def price
    if request.requested_by_doctor?
      60.00 + number_of_pages * 1.00
    else
      185.00
    end
  end
end

class RequestPricingService
  def self.price(request, number_of_pages)
    return 0.00 unless number_of_pages

    state_abbreviation = request.state.upcase
    state_name = States::ABBREVIATIONS_MAPPING[state_abbreviation].gsub(" ", "")

    pricer = begin
      const_get(state_name).new(number_of_pages, request)
    rescue
      NoStatute.new(number_of_pages, request)
    end

    pricer.price
  end
end
