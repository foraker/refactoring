class RequestPricingService
  def self.price(request, number_of_pages)
    return 0.00 if number_of_pages == nil
    state = request.state.upcase
    self.state_price(state.to_sym, request, number_of_pages)
  end

  private
  def self.state_price(state, request, number_of_pages)
    case state
    when :IL then IL(request, number_of_pages)
    when :TX then TX(request, number_of_pages)
    when :IN then IN(request, number_of_pages)
    when :NC then NC(request, number_of_pages)
    when :NJ then NJ(request, number_of_pages)
    when :CA then CA(request, number_of_pages)
    when :NY then NY(request, number_of_pages)
    when :NV then NV(request, number_of_pages)
    when :UT then UT(request, number_of_pages)
    else no_state(request, number_of_pages)
    end
  end

  def self.UT(request, number_of_pages)
    return 0 if number_of_pages <= 0
    15.00 + number_of_pages * 0.50
  end


  def self.NY(request, number_of_pages)
    return number_of_pages * 0.75 if request.requested_by_doctor?

    if number_of_pages <= 15
      number_of_pages * 2.00
    else
      30.00 + number_of_pages - 15
    end
  end

  def self.IL(request, number_of_pages)
    il_handling_charge = 25.55
    il_first_25 = il_handling_charge + 0.96 * 25
    il_first_50 = il_first_25 + 0.64 * 50
    
    return il_handling_charge if number_of_pages < 1
    return (il_first_50 + (number_of_pages - 50) * 0.32) if number_of_pages > 50
    return (il_first_25 + (number_of_pages - 25) * 0.64) if number_of_pages > 25
    return (il_handling_charge + (number_of_pages) * 0.96)


  end

  def self.TX(request, number_of_pages)
    tx_min_charge = 25.00
    if number_of_pages <= 20
      tx_min_charge
    else
      tx_min_charge + (number_of_pages - 20) * 0.50
    end
  end

  def self.CA(request, number_of_pages)
    ca_time_charge = 4.00
    0.10 * number_of_pages + ca_time_charge
  end

  def self.NC(request, number_of_pages)
    nc_first_25 = 0.75 * 25
    nc_first_100 = nc_first_25 + 0.50 * 75
    nc_min_charge = 10.00

    return (nc_first_100 + (number_of_pages - 100) * 0.25) if number_of_pages > 100
    return (nc_first_25 + (number_of_pages -  25) * 0.50) if number_of_pages > 25
    price = ((number_of_pages) * 0.75)
    return nc_min_charge if price < nc_min_charge
    return price
  end

  def self.NV(request, number_of_pages)
    0.60 * number_of_pages 
  end

  def self.IN(request, number_of_pages)
    in_labor_fee = 20.00
    in_first_10 = in_labor_fee
    in_first_50 = in_first_10 + 0.64 * 50
    return (in_first_50 + (number_of_pages - 50) * 0.25) if number_of_pages > 50  #>50
    return (in_first_10 + (number_of_pages - 25) * 0.50) if number_of_pages > 10  # 11-50
    return in_labor_fee
  end

  def self.NJ(request, number_of_pages)
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

  def self.no_state(request, number_of_pages)
    if request.requested_by_doctor?
      fee = 60.00 + number_of_pages * 1.00
    else
      return 185.00
    end
  end
end
