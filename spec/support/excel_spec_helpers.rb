module ExcelSpecHelpers

  def create_temp_xlsx_dir_unless_exists
    path = Pathname.new(ENV['TEMP_XLSX_PATH'])
    FileUtils.mkdir(path.to_s) unless path.exist?
  end

  def destroy_temp_xlsx_dir_if_exists
    path = Pathname.new(ENV['TEMP_XLSX_PATH'])
    FileUtils.rmtree(path.to_s) if path.exist?
  end

  def generate_empty_excel_file(filename)
    filepath = "#{ENV['TEMP_XLSX_PATH']}/#{filename}.xlsx"
    file = Excel.new(source: {})
    file.save_file(filepath)
    path = Pathname.new(filepath)
    expect(path.exist?)
  end

  def verify_empty_file_import(filename)
    filepath = "#{ENV['TEMP_XLSX_PATH']}/#{filename}.xlsx"
    file = Excel.new(source: filepath)
    expect(file.hash_workbook).to eq({"Sheet1"=>{row_count: 0, column_count: 0, rows: {}, columns: {}, cells: {}}})
  end

end
