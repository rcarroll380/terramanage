require "csv"
require "date"

module DataImporter
  class Importer
    TYPES = %w[account vendor customer transactions].freeze

    def initialize(file:, type:, book:)
      @file = file
      @type = type.to_s.downcase
      @book = book
      raise ArgumentError, "Unsupported import type #{@type.inspect}. Use: #{TYPES.join(", ")}" unless TYPES.include?(@type)
    end

    def call
      rows = CSV.read(@file, headers: false)
      send(@type, rows)
    rescue Errno::ENOENT
      raise ArgumentError, "Import file not found: #{@file}"
    rescue CSV::MalformedCSVError => error
      raise ArgumentError, "Could not parse #{@file}: #{error.message}"
    end

    private
      def account(rows)
        header_index = rows.index { |row| normalize(row[0]) == "account" && normalize(row[1]) == "type" }
        raise ArgumentError, "Could not find an Account, Type header in #{@file}" unless header_index

        imported = rows[(header_index + 1)..].filter_map do |row|
          next if row[0].blank?

          number, name = parse_account(row[0])
          type = account_type(row[1])
          account = Account.find_or_initialize_by(book: @book, number: number)
          account.assign_attributes(name: name, account_type: type, description: row[3].presence, active: true)
          account.save!
          account
        end
        puts "Imported #{imported.length} accounts into #{@book.name}."
      end

      def vendor(rows)
        import_entities(rows, "vendor")
      end

      def customer(rows)
        import_entities(rows, "customer")
      end

      def transactions(rows)
        headers, data = table(rows)
        imported = data.filter_map do |row|
          next if row.values.all?(&:blank?)

          attributes = row.to_h.transform_keys { |key| normalize(key) }
          entity = find_entity(attributes["entity_id"] || attributes["entity"] || attributes["payee"] || attributes["vendor"] || attributes["customer"])
          account = find_account(attributes["account_id"] || attributes["account"])
          category_account = find_account(attributes["category_account_id"] || attributes["category_account"] || attributes["category"]) || account
          transaction = Transaction.create!(
            book: @book,
            date: Date.parse(required(attributes, "date")),
            number: attributes["number"] || attributes["check_number"],
            entity: entity,
            account: account,
            category_account: category_account,
            payment: attributes["payment"],
            deposit: attributes["deposit"],
            memo: attributes["memo"],
            reconciled: parse_boolean(attributes["reconciled"])
          )
          transaction
        end
        Transaction.recalculate_balances!(@book)
        puts "Imported #{imported.length} transactions into #{@book.name}."
      end

      def import_entities(rows, type)
        headers, data = table(rows)
        imported = data.filter_map do |row|
          attributes = row.to_h.transform_keys { |key| normalize(key) }
          name = attributes["name"] || attributes["display_name"] || attributes[type]
          next if name.blank?

          entity = Entity.find_or_initialize_by(name: name, entity_type: type)
          entity.assign_attributes(
            address_line1: attributes["address_line1"] || attributes["address"],
            address_line2: attributes["address_line2"],
            city: attributes["city"],
            state: attributes["state"],
            postal_code: attributes["postal_code"] || attributes["zip"],
            active: attributes.key?("active") ? parse_boolean(attributes["active"]) : true
          )
          entity.save!
          entity
        end
        puts "Imported #{imported.length} #{type}s."
      end

      def table(rows)
        header_index = rows.index { |row| row.any? { |value| normalize(value) == "date" || normalize(value) == "name" || normalize(value) == "display_name" } }
        raise ArgumentError, "Could not find a header row in #{@file}" unless header_index

        headers = rows[header_index].map { |value| value.to_s }
        [ headers, CSV::Table.new(rows[(header_index + 1)..].map { |row| CSV::Row.new(headers, row) }) ]
      end

      def find_account(reference)
        value = reference.to_s.strip
        return nil if value.blank?
        return @book.accounts.find(value) if value.match?(/\A[0-9a-f-]{36}\z/i)

        number, name = parse_account(value)
        @book.accounts.find_by(number: number) || @book.accounts.find_by(name: name) || @book.accounts.find_by(number: value)
      end

      def find_entity(reference)
        value = required_value(reference, "entity")
        return Entity.find(value) if value.match?(/\A[0-9a-f-]{36}\z/i)

        Entity.find_by!(name: value)
      end

      def parse_account(value)
        match = value.to_s.strip.match(/\A(\S+)\s+[—-]\s+(.+)\z/)
        match ? [ match[1], match[2] ] : [ value.to_s.strip, value.to_s.strip ]
      end

      def account_type(value)
        type = normalize(value).to_s
        type if Account.account_types.key?(type) || raise(ArgumentError, "Unsupported account type #{value.inspect}")
      end

      def normalize(value)
        value.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "_").sub(/\A_/, "").sub(/_\z/, "")
      end

      def required(attributes, key)
        required_value(attributes[key], key)
      end

      def required_value(value, key)
        raise ArgumentError, "Missing #{key} in #{@file}" if value.blank?

        value.to_s.strip
      end

      def parse_boolean(value)
        !%w[false 0 no n].include?(normalize(value))
      end
  end
end
