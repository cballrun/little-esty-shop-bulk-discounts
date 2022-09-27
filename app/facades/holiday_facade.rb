class HolidayFacade

  def self.get_holiday_data
    parsed = HolidayService.get_data
    holidays = parsed.map do |holiday_data|
      Holiday.new(holiday_data)
    end
    holidays[0..2]
  end

  def self.get_holiday_name_data
    parsed = HolidayService.get_data
    holiday_names = [parsed[0][:name], parsed[1][:name], parsed[2][:name]]
  end

  def self.get_holiday_date_data
    parsed = HolidayService.get_data
    holiday_dates = [parsed[0][:date], parsed[1][:date], parsed[2][:date]]
  end
end