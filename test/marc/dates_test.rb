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
#
# Range format tests:
#
# | ID | Format                  |
# |----|-------------------------|
# | NA | YYYY-                   |
# | NB | YYYY-YYYY               |
# | NC | YYYY-, cYYYY            |
# | ND | YYY-]                   |
# | NE | [YYYY-YY]               |
# | NF | [between YYYY and YYYY] |
# | NG | [YYYY]-<YYYY >          |
# | NH | [cYYYY-YYYY]            |
# | NI | cYYYY-YYYY              |
# | NJ | cYYYY-                  |
# | NK | YYYY/YYYY-              |
# | NL | YYYY/YY-                |
# | NM | cYYYY-cYYYY             |
# | NN | [cYYYY]-YYYY            |
# | NO | [YYYY/YYYY-YYYY/YYYY    |
# | NP | YYYY/YYYY-YYYY/YY       |
#
class Marc::DatesTest < Minitest::Test

  def test_version_number
    refute_nil ::Marc::Dates::VERSION
  end

  # parse()

  def test_parse_with_nil_argument
    assert_equal [], Marc::Dates.parse(nil)
  end

  def test_parse_with_unrecognizable_argument
    assert_equal [Time.new('cats')], Marc::Dates.parse('cats')
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

end
