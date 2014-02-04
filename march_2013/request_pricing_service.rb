class RequestPricingService
  def self.price(request, number_of_pages)
    if number_of_pages
      state = request.state.upcase
      begin
        return RequestPricingService.send("pages_price", request, number_of_pages)
      # rescue Exception # TOO DANGEROUS
      rescue NoMethodError
        puts "None of the states match pricing rules we defined, #{request.state} for request"
        pages_price_NOSTATUTE(request, number_of_pages)
      end
   else
     0.00
   end
  end

  IL_HANDLING_CHARGE = 25.55
  IL_FIRST_25 = IL_HANDLING_CHARGE + 0.96 * 25
  IL_FIRST_50 = IL_FIRST_25 + 0.64 * 50

  TX_MIN_CHARGE = 25.00

  IN_LABOR_FEE = 20.00
  IN_FIRST_10 = IN_LABOR_FEE
  IN_FIRST_50 = IN_FIRST_10 + 0.64 * 50

  NC_FIRST_25 = 0.75 * 25
  NC_FIRST_100 = NC_FIRST_25 + 0.50 * 75
  NC_MIN_CHARGE = 10.00

  CA_TIME_CHARGE = 4.00

  def self.pages_price(request, number_of_pages)
    case request.state
      when "IL"
        return IL_HANDLING_CHARGE if number_of_pages < 1
        return (IL_FIRST_50 + (number_of_pages - 50) * 0.32) if number_of_pages > 50
        return (IL_FIRST_25 + (number_of_pages - 25) * 0.64) if number_of_pages > 25
        return (IL_HANDLING_CHARGE + (number_of_pages) * 0.96)
      when "TX"
        return TX_MIN_CHARGE if number_of_pages <= 20
        return (TX_MIN_CHARGE + (number_of_pages - 20) * 0.50)
      when "IN"
        return (IN_FIRST_50 + (number_of_pages - 50) * 0.25) if number_of_pages > 50  #>50
        return (IN_FIRST_10 + (number_of_pages - 25) * 0.50) if number_of_pages > 10  # 11-50
        return IN_LABOR_FEE
      when "NC"
        return (NC_FIRST_100 + (number_of_pages - 100) * 0.25) if number_of_pages > 100
        return (NC_FIRST_25 + (number_of_pages -  25) * 0.50) if number_of_pages > 25
        price = ((number_of_pages) * 0.75)
        return NC_MIN_CHARGE if price < NC_MIN_CHARGE #min charge
        return price
      when "NJ"
        return 0 if number_of_pages <= 0
        price_per_page_low = 1.00
        search_fee = 10.00
        if number_of_pages > 100
           temp =  100 * price_per_page_low + (number_of_pages-100) * 0.25 + search_fee
           return temp>200 ? 200.00 : temp.round(2)
        else
           return number_of_pages * price_per_page_low + search_fee
        end
      when "CA"
        0.10 * number_of_pages + CA_TIME_CHARGE
      when "NY"
        if request.requested_by_doctor?
          number_of_pages * 0.75
        else
          if number_of_pages <=15
            return number_of_pages * 2.00
          else
            return 15 * 2.00 + ((number_of_pages - 15) * 1.00)
          end
        end
      when "NV"
        return 0.60 * number_of_pages
      when "UT"
        return 0 if number_of_pages <= 0
        15.00 + number_of_pages * 0.50
      #when "NOSTATUTE"
      else #"NOSTATUTE"
        if request.requested_by_doctor?
          fee = 60.00 + number_of_pages * 1.00
        else
          return 185.00
        end
    end
  end
end