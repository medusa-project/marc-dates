require 'marc/dates/format_error'
require 'marc/dates/version'
require 'time'

module Marc
  module Dates

    MONTH_NAMES = %w(january february march april may june july august
                     september october november december)

    ROMAN_NUMERALS = { I: 1, V: 5, X: 10, L: 50, C: 100, D: 500, M: 1000 }

    ##
    # Tries to create an array of Time instances from an arbitrary date string
    # as might appear in MARC metadata.
    #
    # @param date [String] Arbitrary date string.
    # @return [Array] Array of one Time instance for point dates, or two
    #                 instances for date ranges.
    #
    def self.parse(date)
      # One- or two-element array of normalized dates.
      range = []
      if date
        range = normalize(date).map{ |d| d.gsub(' ', '-').split('-') }
        range[0] = Time.new(*range[0]) if range[0]
        range[1] = Time.new(*range[1]) if range[1]
      end
      range
    end

    private

    def self.normalize(date)
      date = date.strip # don't mutate the argument

      # Replace ambiguous years "[NNN-]" with zero
      date.gsub!(/(\d+)-\]/, '\10]')

      # Remove brackets
      date.gsub!(/[\[\]()<>]/, '')

      # Remove various words
      date.gsub!(/(approximately|ca.|cop.|etc.|intro.|pref.|année)/i, '')

      # Remove various patterns
      date.gsub!(/(Guangxu ?\d+|Heisei ?\d+|Meiji ?\d+|Minguo ?\d+|Min guo ?\d+|Qing guangxu ?\d+|Shōwa ?\d+|Taisho ?\d+|Taishō ?\d+) ?/i, '')

      # Remove everything after " or", or " v."
      i = date.index(/( or| v.)/)
      date = date[0..(i - 1)].strip if i and i > 1

      # Replace "YYYY/YYYY" with "YYYY-YYYY"
      if date.match?(/^\d{3,4}\/\d{3,4}$/)
        date.gsub!('/', '-')
      end

      # Replace "YYYY/" and "/YYYY" with "YYYY"
      if date.match?(/^\d{3,4}\/$/) or date.match?(/^\/\d{3,4}$/)
        date.gsub!('/', '')
      end

      # Replace "between YYYY and YYYY" with "YYYY-YYYY"
      if date.match?(/between.*and/i)
        date.gsub!(/between/i, '')
        date.gsub!(' and ', '-')
      end

      # Replace YYY-? with YYY0
      date.gsub!(/(\d{3})-\?/, '\10')

      # Remove any "c" or "©" prepended to years
      date.gsub!(/([c©]\.? ?)(\d{3,4})/, '\2')

      # Remove various punctuation
      date.gsub!(/[.?,';]/, '')

      # Replace "DD Month YYYY" with "YYYY:MM:DD"
      date.gsub!(/(\d{1,2}) (#{month_names_regex_clause}) (\d{4})/i) { |m| "#{$3}:#{month_to_decimal($2).to_s.rjust(2, '0')}:#{$1.rjust(2, '0')}" }

      # Replace "Month YYYY" with "YYYY:MM"
      date.gsub!(/(#{month_names_regex_clause}) (\d{4})/i) { |m| "#{$2}:#{month_to_decimal($1).to_s.rjust(2, '0')}" }

      # Replace "Month DD YYYY" with "YYYY:MM:DD"
      date.gsub!(/(#{month_names_regex_clause}) (\d{1,2}) (\d{4})/i) { |m| "#{$3}:#{month_to_decimal($1).to_s.rjust(2, '0')}:#{$2.to_s.rjust(2, '0')}" }

      # Convert Roman numerals to decimals
      m = date.match(/[MDCLXVI]+/)
      if m and m[0].length > 2
        date.gsub!(/[MDCLXVI]+/) { |c| roman_to_decimal(c) }
      end

      # At this point, if the date does not contain any numerics, we don't
      # know what it is.
      if date.gsub(/[^0-9]/, '')&.empty?
        raise FormatError, 'Unrecognized date format'
      end

      # Remove the 2nd year of space-separated years (YYYY YYYY)
      date.gsub!(/(\d{4}) \d{4}/, '\1')

      # Replace YYYY/YYYY with YYYY
      date.gsub!(/(\d{4})\/\d{1,4}/, '\1')

      # If the date contains YYYY-YYYY, use that.
      m = date.match(/\d{3,4}-\d{3,4}/)
      date = "#{m}" if m

      # Replace lYYY with YYYY.
      date.gsub!(/l(\d{3})/, '1\1')

      # Replace some DD-MM-YYYY with YYYY-MM-DD
      date.gsub!(/([2-3][0-9])-([0-1][0-9])-(\d{4})/, '\3-\2-\1')

      # Replace some MM-DD-YYYY with YYYY-MM-DD
      date.gsub!(/([0-1][0-9])-([2-3][0-9])-(\d{4})/, '\3-\1-\2')

      # Replace remaining NN-NN-YYYY with YYYY-MM-DD
      date.gsub!(/(\d{1,2})-(\d{1,2})-(\d{4})/, '\2-\3-\1')

      # Replace remaining NN-YYYY with YYYY-NN
      date.gsub!(/^(\d{1,2})-(\d{4})/, '\2-\1')

      # Replace NN-NN-NN with NN:NN:NN and NN-NN with NN:NN so that the dashes
      # won't get mistaken for ranges
      unless date.match(/\d{4}-\d{4}/) or
          date.match(/\d{4}:\d{1,2}-\d{4}:\d{1,2}/) or
          date.match(/\d{4}:\d{1,2}:\d{1,2}-\d{4}:\d{1,2}:\d{1,2}/)
        date.gsub!(/(\d)-(\d)-(\d)/, '\1:\2:\3')
        date.gsub!(/(\d)-(\d)/, '\1:\2')
      end

      # If the format matches YYYY:NN and NN is > YY, assume it's a 2-digit
      # year rather than a month
      if date.match(/^\d{4}:\d{2}$/)
        parts = date.split(':')
        yy2 = parts[0][2..4].to_i
        if parts[1].to_i > yy2
          date = "#{parts[0]}-#{parts[0][0..1]}#{parts[1]}"
        elsif parts[1].to_i > 12
          date = parts[0]
        end
      end

      # If the date starts with "YYYY " then use the first 4 characters
      date.gsub!(/(\d{3,4}) .+/, '\1')

      range = date.split('-').map(&:strip)
      range.pop if range.length > 1 and range[1].empty?
      range.map{ |d| d.gsub(':', '-') }
    end

    ##
    # @return [String] Regex "or" clause in the form
    #                  (january|february|..|jan|feb|..)
    #
    def self.month_names_regex_clause
      full_names = MONTH_NAMES.join('|')
      abbr_names = MONTH_NAMES.map{ |n| n[0..2] }.join('|')
      "#{full_names}|#{abbr_names}"
    end

    ##
    # Converts a month name to a decimal month string.
    #
    def self.month_to_decimal(name)
      name = name.downcase
      MONTH_NAMES.each_with_index do |full_name, i|
        return i + 1 if full_name.start_with?(name)
      end
      return '01'
    end

    ##
    # Converts a Roman numeric string to a decimal.
    #
    def self.roman_to_decimal(date)
      dec = 0
      date.strip.each_char do |char|
        dec += ROMAN_NUMERALS[char.to_sym]
      end
      dec
    end

  end
end
