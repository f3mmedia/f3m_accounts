require_relative 'support/env'

include ExcelSpecHelpers


describe 'Read excel file' do

  before(:all) do
    destroy_temp_xlsx_dir_if_exists
    create_temp_xlsx_dir_unless_exists
  end

  after(:all) do
    destroy_temp_xlsx_dir_if_exists
  end

  it 'should open and read a file when passed a string' do
    filename = 'excel_read_spec_1'
    generate_empty_excel_file(filename)
    verify_empty_file_import(filename)
  end

end
