require 'rubyXL'

class Excel
  attr_accessor :hash_workbook

  def initialize(source: nil)
    if source.class == Hash
      @hash_workbook = source
    elsif source.class == String
      read_file(source)
    end
  end

  def save_file(filepath)
    # rubyxl_workbook = hash_workbook_to_rubyxl_workbook
    # rubyxl_workbook.write(@hash_workbook[:filepath])
    hash_workbook_to_rubyxl_workbook.write(filepath)
  end

  def hash_workbook_to_rubyxl_workbook
    rubyxl_workbook = RubyXL::Workbook.new
    first_worksheet = true
    @hash_workbook.each do |hash_key, hash_value|
      if first_worksheet
        rubyxl_workbook.worksheets[0].sheet_name = hash_key
        first_worksheet = false
      else
        rubyxl_workbook.add_worksheet(hash_key)
      end
      hash_worksheet_to_rubyxl_worksheet(hash_value, rubyxl_workbook[hash_key])
    end
    rubyxl_workbook
  end

  def hash_worksheet_to_rubyxl_worksheet(hash_worksheet, rubyxl_worksheet)
    # 1. add all of the cells
    # 1.1 get the number of rows and columns



    # hash_worksheet[:worksheet].each do |hash_cell_key, hash_cell|
    #   rubyxl_worksheet.change_row_font_name(0, hash_cell[:row_font_name])
    #   rubyxl_worksheet.change_column_font_name(0, hash_cell[:column_font_name])
    # end
    worksheet = hash_worksheet[:worksheet]
    # rubyxl_worksheet.change_row_font_name(worksheet[:row_number], worksheet[:row_font_name])
    # rubyxl_worksheet.change_column_font_name(worksheet[:column_number], worksheet[:column_font_name])
    (0..(worksheet[:row_count])).to_a.each do |item1|
      rubyxl_worksheet.change_row_font_name(item1, worksheet[:row_font_name])
      rubyxl_worksheet
      (0..(worksheet[:column_count])).to_a.each do |item2|
        rubyxl_worksheet.change_column_font_name(item2, worksheet[:column_font_name])
        rubyxl_worksheet.add_cell(item1, item2, '')
      end
    end

    # rubyxl_worksheet.change_column_width(column_index, hash_cell[:width]) if hash_cell[:width]
    #
    # rubyxl_worksheet.change_row_font_name(row_index, hash_cell[:name]) if hash_cell[:name]
    # rubyxl_worksheet.change_row_font_size(row_index, hash_cell[:size])  if hash_cell[:size]
    hash_worksheet[:cells].each do |hash_cell_key, hash_cell|
      hash_cell_to_rubyxl_cell(hash_cell_key, hash_cell, rubyxl_worksheet)
    end
  end

  def hash_cell_to_rubyxl_cell(hash_cell_key, hash_cell, rubyxl_worksheet)
    row_index, column_index = RubyXL::Reference.ref2ind(hash_cell_key)

    index_b, index_a = RubyXL::Reference.ref2ind(hash_cell[:merge]) if hash_cell[:merge]
    rubyxl_worksheet.merge_cells(row_index, column_index, index_a, index_b) if hash_cell[:merge]
    if hash_cell[:formula]
      rubyxl_worksheet.add_cell(row_index, column_index, '', hash_cell[:formula]).set_number_format '0.00'
    else
      rubyxl_worksheet.add_cell(row_index, column_index, hash_cell[:value])
    end

    rubyxl_worksheet[row_index][column_index].change_contents(hash_cell[:sum], rubyxl_worksheet[row_index][column_index].formula) if hash_cell[:sum]



    rubyxl_worksheet[row_index][column_index].set_number_format(hash_cell[:format]) if hash_cell[:format]
    rubyxl_worksheet[row_index][column_index].change_fill(hash_cell[:fill]) if hash_cell[:fill]
    rubyxl_worksheet[row_index][column_index].change_horizontal_alignment(hash_cell[:align]) if hash_cell[:align]
    rubyxl_worksheet[row_index][column_index].set_number_format(hash_cell[:format]) if hash_cell[:format]
    rubyxl_worksheet[row_index][column_index].change_font_bold(hash_cell[:bold]) if hash_cell[:bold]

    if hash_cell[:border_all]
      rubyxl_worksheet[row_index][column_index].change_border('top' , hash_cell[:border_all])
      rubyxl_worksheet[row_index][column_index].change_border('bottom' , hash_cell[:border_all])
      rubyxl_worksheet[row_index][column_index].change_border('left' , hash_cell[:border_all])
      rubyxl_worksheet[row_index][column_index].change_border('right' , hash_cell[:border_all])
    end
  end

  def read_file(path)
    rubyxl_workbook = RubyXL::Parser.parse(path)
    @hash_workbook = rubyxl_workbook_to_hash_workbook(rubyxl_workbook)
  end

  def rubyxl_workbook_to_hash_workbook(rubyxl_workbook)
    hash_workbook = {}
    rubyxl_workbook.each do |rubyxl_worksheet|
      hash_worksheet = {row_count: rubyxl_worksheet.count, column_count: 1, cells: {}}
      rubyxl_worksheet_to_hash_worksheet(rubyxl_worksheet, hash_worksheet)
      populate_hash_worksheet_cells_to_block(hash_worksheet)
      hash_workbook[rubyxl_worksheet.sheet_name] = hash_worksheet
    end
    hash_workbook
  end

  def rubyxl_worksheet_to_hash_worksheet(rubyxl_worksheet, hash_worksheet)
    rubyxl_worksheet.each_with_index do |rubyxl_row, rubyxl_row_index|
      rubyxl_row_cells = rubyxl_row&.cells
      if rubyxl_row_cells.nil?
        hash_cell = {}
        hash_cell_key = RubyXL::Reference.ind2ref(rubyxl_row_index, 0)
        hash_worksheet[hash_cell_key] = hash_cell
      else
        rubyxl_row_cells.each_with_index do |hash_cell, rubyxl_column_index|
          hash_cell = {}
          hash_cell_key = RubyXL::Reference.ind2ref(rubyxl_row_index, rubyxl_column_index)
          hash_worksheet[:cells][hash_cell_key] = hash_cell
          hash_worksheet[:column_count] = rubyxl_column_index + 1 if rubyxl_column_index + 1 > hash_worksheet[:column_count]
        end
      end
    end
  end

  def populate_hash_worksheet_cells_to_block(hash_worksheet)
    hash_worksheet[:row_count].times do |hash_row_index|
      hash_worksheet[:column_count].times do |hash_column_index|
        hash_cell_key = RubyXL::Reference.ind2ref(hash_row_index, hash_column_index)
        hash_worksheet[hash_cell_key] = {} unless hash_worksheet[hash_cell_key]
      end
    end
  end
end
