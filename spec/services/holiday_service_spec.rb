require 'rails_helper'

RSpec.describe HolidayService do

  it 'gets data from the API' do
    VCR.use_cassette("next_holiday_data", :allow_playback_repeats => true) do
      expect(HolidayService.get_data).to be_a(Array)
      expect(HolidayService.get_data[0]).to be_a(Hash)
    end
  end
end