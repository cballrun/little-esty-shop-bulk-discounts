require 'rails_helper'

RSpec.describe Holiday do
  it 'exists and has attributes' do
    VCR.use_cassette("next_holiday_data", :allow_playback_repeats => true) do
      holiday_data = HolidayService.get_data
    end
  end
end