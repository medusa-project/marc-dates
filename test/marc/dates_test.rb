require "test_helper"

##
# Point format tests:
#
# | ID | Format                |
# |----|-----------------------|
# | AC | YYYY:MM:DD            |
# | AD | YYYY-MM-DD            |
# | AE | YYYY                  |
# | AF | [YYYY]                |
# | AG | [[YYYY]               |
# | AH | YYYY]                 |
# | AI | [YYYY?]               |
# | AJ | YYYY?]                |
# | AK | YYYY, cYYYY           |
# | AL | cYYYY                 |
# | AM | [cYYYY]               |
# | AN | ©YYYY                 |
# | AO | Month YYYY            |
# | AP | Month, YYYY           |
# | AQ | [YYYY or YYYY]        |
# | AR | MM-YYYY               |
# | AS | MM-DD-YYYY            |
# | AT | DD Month YYYY         |
# | AU | YYYY [i.e. YYYY-YY]   |
# | AV | YYYY, i.e. YYYY-      |
# | AW | [cYYYY, YYYY]         |
# | AX | cYYYY [cYYYY or YYYY] |
# | AY | cYYYY, YYYY           |
# | AZ | [cYYYY.] YYYY         |
# | BA | ss. YYYY              |
# | BB | MDCCCXLVI [YYYY]      |
# | BC | [pref. YYYY]          |
# | BD | YYYY, c YYYY.         |
# | BE | YYYY, 'YY.            |
# | BF | Mon. YYYY.            |
# | BG | Mon. D, YYYY.         |
# | BH | [c. YYYY]             |
#
# Range format tests:
#
# | ID | Format                              |
# |----|-------------------------------------|
# | NA | YYYY-                               |
# | NB | YYYY-YYYY                           |
# | NC | YYYY-, cYYYY                        |
# | ND | YYY-]                               |
# | NE | [YYYY-YY]                           |
# | NF | [between YYYY and YYYY]             |
# | NG | [YYYY]-<YYYY >                      |
# | NH | [cYYYY-YYYY]                        |
# | NI | cYYYY-YYYY                          |
# | NJ | cYYYY-                              |
# | NK | YYYY/YYYY-                          |
# | NL | YYYY/YY-                            |
# | NM | cYYYY-cYYYY                         |
# | NN | [cYYYY]-YYYY                        |
# | NO | [YYYY/YYYY-YYYY/YYYY                |
# | NP | YYYY/YYYY-YYYY/YY                   |
# | NQ | [YYY-?]-                            |
# | NR | YYYY-YY [v. N YYYY]                 |
# | NS | YYYY-YY                             |
# | NT | Sho  wa 41-43 i.e. 1966-1968]       |
# | NU | YYYY/YYYY                           |
# | NV | YYYY/                               |
# | NW | /YYYY                               |
# | NX | [between Month YYYY and Month YYYY] |
#
class Marc::DatesTest < Minitest::Test

  def test_version_number
    refute_nil ::Marc::Dates::VERSION
  end

  # parse()

  def test_parse_with_book_tracker_dates
    # N.B.: dates.tsv is an export of all Book Tracker dates as of 2018-12-17
    # using the following query:
    #
    # SELECT date FROM books WHERE date IS NOT NULL;
    start_i = 0
    end_i   = 100000
    num_errors = 0
    File.open(File.join(__dir__, 'dates.tsv'), 'r').each_with_index do |line, index|
      next if index < start_i
      break if index > end_i

      date = nil
      begin
        date = Marc::Dates::parse(line)
      rescue Marc::Dates::FormatError
        # This is fine. Not all lines in the file are valid dates, and we've
        # explicitly rejected this one.
      rescue ArgumentError
        num_errors += 1
        puts "#{'**** FAILED | '}#{index} | #{line.strip}"
      else
        #puts "#{index} | #{line.strip} | #{date}"
      end
    end

    puts "#{num_errors} errors"
  end

  def test_parse_with_nil_argument
    assert_equal [], Marc::Dates.parse(nil)
  end

  def test_parse_with_unrecognizable_argument_1
    assert_raises Marc::Dates::FormatError do
      Marc::Dates.parse('cats')
    end
  end

  def test_parse_with_unrecognizable_argument_2
    assert_raises Marc::Dates::FormatError do
      Marc::Dates.parse('Telegraph Pub. Co.')
    end
  end

  def test_parse_with_AC
    assert_equal [Time.parse('1923-02-12 00:00:00')],
                 Marc::Dates.parse('1923:02:12')
  end

  def test_parse_with_AD
    assert_equal [Time.parse('1923-02-12 00:00:00')],
                 Marc::Dates.parse('1923-02-12')
  end

  def test_parse_with_AE
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('1923')
  end

  def test_parse_with_AF
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('[1923]')
  end

  def test_parse_with_AG
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('[[1923]')
  end

  def test_parse_with_AH
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('1923]')
  end

  def test_parse_with_AI
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('[1923?]')
  end

  def test_parse_with_AJ
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('1923?]')
  end

  def test_parse_with_AK
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('1923, c1925')
  end

  def test_parse_with_AL
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('c1923')
  end

  def test_parse_with_AM
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('[c1923]')
  end

  def test_parse_with_AN
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('©1923')
  end

  def test_parse_with_AO
    assert_equal [Time.parse('1923-10-01 00:00:00')],
                 Marc::Dates.parse('October 1923')
  end

  def test_parse_with_AP
    assert_equal [Time.parse('1923-10-01 00:00:00')],
                 Marc::Dates.parse('October, 1923')
  end

  def test_parse_with_AQ
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('[1923 or 1924]')
  end

  def test_parse_with_AR
    assert_equal [Time.parse('1923-03-01 00:00:00')],
                 Marc::Dates.parse('03-1923')
  end

  def test_parse_with_AS
    assert_equal [Time.parse('1923-03-23 00:00:00')],
                 Marc::Dates.parse('03-23-1923')
  end

  def test_parse_with_AT_1
    assert_equal [Time.parse('1923-02-05 00:00:00')],
                 Marc::Dates.parse('5 February 1923')
  end

  def test_parse_with_AT_2
    assert_equal [Time.parse('1923-03-20 00:00:00')],
                 Marc::Dates.parse('20 March 1923')
  end

  def test_parse_with_AU
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('1923 [i.e. 1923-25]')
  end

  def test_parse_with_AV
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('1923, i.e. 1924')
  end

  def test_parse_with_AW
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('[c1923, 1924]')
  end

  def test_parse_with_AX
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('c1923 [c1924 or 1925]')
  end

  def test_parse_with_AY
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('c1923, 1925')
  end

  def test_parse_with_AZ
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('[c1923.] 1925')
  end

  def test_parse_with_BA
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('[ca. 1923]')
  end

  def test_parse_with_BB
    assert_equal [Time.parse('1866-01-01 00:00:00')],
                 Marc::Dates.parse('MDCCCXLVI [1923]')
  end

  def test_parse_with_BC
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('[pref. 1923]')
  end

  def test_parse_with_BD
    assert_equal [Time.parse('1901-01-01 00:00:00')],
                 Marc::Dates.parse('1901, c 1897.')
  end

  def test_parse_with_BE
    assert_equal [Time.parse('1917-01-01 00:00:00')],
                 Marc::Dates.parse('1917, \'15.')
  end

  def test_parse_with_BF
    assert_equal [Time.parse('1917-03-01 00:00:00')],
                 Marc::Dates.parse('Mar. 1917.')
  end

  def test_parse_with_BG
    assert_equal [Time.parse('1980-02-08 00:00:00')],
                 Marc::Dates.parse('Feb. 8, 1980.')
  end

  def test_parse_with_BH
    assert_equal [Time.parse('1894-01-01 00:00:00')],
                 Marc::Dates.parse('[c. 1894]')
  end

  def test_parse_with_NA
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('1923-')
  end

  def test_parse_with_NB
    assert_equal [Time.parse('1923-01-01 00:00:00'),
                  Time.parse('1925-01-01 00:00:00')],
                 Marc::Dates.parse('1923-1925')
  end

  def test_parse_with_NC
    assert_equal [Time.parse('1923-01-01 00:00:00'),
                  Time.parse('1925-01-01 00:00:00')],
                 Marc::Dates.parse('1923-, c1925')
  end

  def test_parse_with_ND
    assert_equal [Time.parse('1920-01-01 00:00:00')],
                 Marc::Dates.parse('192-]')
    assert_equal [Time.parse('1920-01-01 00:00:00')],
                 Marc::Dates.parse('[192-]')
  end

  def test_parse_with_NE
    assert_equal [Time.parse('1925-01-01 00:00:00'),
                  Time.parse('1927-01-01 00:00:00')],
                 Marc::Dates.parse('[1925-27]')
  end

  def test_parse_with_NF
    assert_equal [Time.parse('1923-01-01 00:00:00'),
                  Time.parse('1925-01-01 00:00:00')],
                 Marc::Dates.parse('[between 1923 and 1925]')
  end

  def test_parse_with_NG
    assert_equal [Time.parse('1923-01-01 00:00:00'),
                  Time.parse('1925-01-01 00:00:00')],
                 Marc::Dates.parse('[1923]-<1925 >')
  end

  def test_parse_with_NH
    assert_equal [Time.parse('1923-01-01 00:00:00'),
                  Time.parse('1925-01-01 00:00:00')],
                 Marc::Dates.parse('[c1923-1925]')
  end

  def test_parse_with_NI
    assert_equal [Time.parse('1923-01-01 00:00:00'),
                  Time.parse('1925-01-01 00:00:00')],
                 Marc::Dates.parse('c1923-1925')
  end

  def test_parse_with_NJ
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('c1923-')
  end

  def test_parse_with_NK
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('1923/1924-')
  end

  def test_parse_with_NL
    assert_equal [Time.parse('1923-01-01 00:00:00')],
                 Marc::Dates.parse('1923/24-')
  end

  def test_parse_with_NM
    assert_equal [Time.parse('1923-01-01 00:00:00'),
                  Time.parse('1924-01-01 00:00:00')],
                 Marc::Dates.parse('c1923-c1924')
  end

  def test_parse_with_NN
    assert_equal [Time.parse('1923-01-01 00:00:00'),
                  Time.parse('1925-01-01 00:00:00')],
                 Marc::Dates.parse('[c1923]-1925')
  end

  def test_parse_with_NO
    assert_equal [Time.parse('1886-01-01 00:00:00'),
                  Time.parse('1888-01-01 00:00:00')],
                 Marc::Dates.parse('[1886/1887-1888/1889')
  end

  def test_parse_with_NP
    assert_equal [Time.parse('1886-01-01 00:00:00'),
                  Time.parse('1888-01-01 00:00:00')],
                 Marc::Dates.parse('1886/1887-1888/89')
  end

  def test_parse_with_NQ
    assert_equal [Time.parse('1880-01-01 00:00:00')],
                 Marc::Dates.parse('[188-?]-')
  end

  def test_parse_with_NR
    assert_equal [Time.parse('1918-01-01 00:00:00'),
                  Time.parse('1919-01-01 00:00:00')],
                 Marc::Dates.parse('1918-19 [v. 1 1919]')
  end

  def test_parse_with_NS
    assert_equal [Time.parse('1919-01-01 00:00:00')],
                 Marc::Dates.parse('1919-18.')
  end

  def test_parse_with_NT
    assert_equal [Time.parse('1966-01-01 00:00:00'),
                  Time.parse('1968-01-01 00:00:00')],
                 Marc::Dates.parse('Sho  wa 41-43 i.e. 1966-1968]')
  end

  def test_parse_with_NU
    assert_equal [Time.parse('1952-01-01 00:00:00'),
                  Time.parse('1958-01-01 00:00:00')],
                 Marc::Dates.parse('1952/1958')
  end

  def test_parse_with_NV
    assert_equal [Time.parse('1952-01-01 00:00:00')],
                 Marc::Dates.parse('1952/')
  end

  def test_parse_with_NW
    assert_equal [Time.parse('1952-01-01 00:00:00')],
                 Marc::Dates.parse('/1952')
  end

  def test_parse_with_NX
    assert_equal [Time.parse('1956-03-01 00:00:00'),
                  Time.parse('1962-02-01 00:00:00')],
                 Marc::Dates.parse('[between March 1956 and February 1962]')
  end

end
