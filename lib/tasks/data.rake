namespace :data do
  desc "Import QuickBooks CSV data (FILE=path TYPE=account|vendor|customer|transactions BOOK=My rentals)"
  task import: :environment do
    file = ENV["FILE"]
    type = ENV["TYPE"]
    book_name = ENV.fetch("BOOK", "My rentals")

    if file.blank? || type.blank?
      abort "Usage: bin/rails data:import FILE=path/to/file.csv TYPE=account|vendor|customer|transactions [BOOK=My rentals]"
    end

    book = Book.find_or_create_by!(name: book_name)
    DataImporter::Importer.new(file: file, type: type, book: book).call
  rescue ArgumentError => error
    abort "Import failed: #{error.message}"
  end
end
