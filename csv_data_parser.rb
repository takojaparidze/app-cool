require 'csv'
require 'date'
require 'logger'

class CsvDataParser
  attr_reader :input_file, :output_file, :logger

  def initialize(input_file, output_file)
    @input_file = input_file
    @output_file = output_file
    @logger = Logger.new($stdout)
    @logger.level = Logger::INFO
  end

  def parse_and_transform
    logger.info("Starting the CSV parsing process.")
    begin
      CSV.open(@output_file, "wb", write_headers: true, headers: ["ID", "Name", "Processed Date"]) do |csv|
        CSV.foreach(@input_file, headers: true) do |row|
          begin
            transformed_row = transform_data(row)
            csv << transformed_row
          rescue StandardError => e
            logger.error("Failed to process row #{row['ID']}: #{e.message}")
          end
        end
      end
      logger.info("CSV processing completed successfully.")
    rescue StandardError => e
      logger.error("Failed to open or process CSV files: #{e.message}")
    end
  end

  private

  def transform_data(row)
    row["Date"] = Date.parse(row["Date"]).strftime("%Y-%m-%d") rescue nil
    raise StandardError, "Date conversion failed for ID #{row['ID']}" unless row["Date"]
    [row["ID"], row["Name"], row["Date"]]
  end
end
