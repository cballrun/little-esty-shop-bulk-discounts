require 'rails_helper'

RSpec.describe HolidayFacade do
  it 'gets holiday name data for the next 3 holidays' do
    VCR.use_cassette("next_holiday_data", :allow_playback_repeats => true) do
      expect(HolidayFacade.get_holiday_name_data).to be_a(Array)
      expect(HolidayFacade.get_holiday_name_data).to eq(["Columbus Day", "Veterans Day", "Thanksgiving Day"])
    end
  end

  it 'gets holiday date data for the next 3 holidays' do
    VCR.use_cassette("next_holiday_data", :allow_playback_repeats => true) do
      expect(HolidayFacade.get_holiday_date_data).to be_a(Array)
      expect(HolidayFacade.get_holiday_date_data).to eq(["2022-10-10", "2022-11-11", "2022-11-24"])
    end
  end

  it 'gets holiday data with a poro' do
    VCR.use_cassette("next_holiday_data", :allow_playback_repeats => true) do
      expect(HolidayFacade.get_holiday_data).to be_a(Array)
      expect(HolidayFacade.get_holiday_data.count).to eq(3)
    end
  end

end