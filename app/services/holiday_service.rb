
class HolidayService
  def self.get_data
    uri = 'https://date.nager.at/api/v3/NextPublicHolidays/US'
    response = HTTParty.get(uri)
    body = response.body
    parsed = JSON.parse(body, symbolize_names: true)
    binding.pry
  end


end