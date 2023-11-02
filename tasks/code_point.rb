# frozen_string_literal: true

class CodePoint
  # https://datatracker.ietf.org/doc/html/rfc5892#section-2.6
  EXCEPTIONS = {
    0x00DF => "PVALID", # LATIN SMALL LETTER SHARP S
    0x03C2 => "PVALID", # GREEK SMALL LETTER FINAL SIGMA
    0x06FD => "PVALID", # ARABIC SIGN SINDHI AMPERSAND
    0x06FE => "PVALID", # ARABIC SIGN SINDHI POSTPOSITION MEN
    0x0F0B => "PVALID", # TIBETAN MARK INTERSYLLABIC TSHEG
    0x3007 => "PVALID", # IDEOGRAPHIC NUMBER ZERO
    0x00B7 => "CONTEXTO", # MIDDLE DOT
    0x0375 => "CONTEXTO", # GREEK LOWER NUMERAL SIGN (KERAIA)
    0x05F3 => "CONTEXTO", # HEBREW PUNCTUATION GERESH
    0x05F4 => "CONTEXTO", # HEBREW PUNCTUATION GERSHAYIM
    0x30FB => "CONTEXTO", # KATAKANA MIDDLE DOT
    0x0660 => "CONTEXTO", # ARABIC-INDIC DIGIT ZERO
    0x0661 => "CONTEXTO", # ARABIC-INDIC DIGIT ONE
    0x0662 => "CONTEXTO", # ARABIC-INDIC DIGIT TWO
    0x0663 => "CONTEXTO", # ARABIC-INDIC DIGIT THREE
    0x0664 => "CONTEXTO", # ARABIC-INDIC DIGIT FOUR
    0x0665 => "CONTEXTO", # ARABIC-INDIC DIGIT FIVE
    0x0666 => "CONTEXTO", # ARABIC-INDIC DIGIT SIX
    0x0667 => "CONTEXTO", # ARABIC-INDIC DIGIT SEVEN
    0x0668 => "CONTEXTO", # ARABIC-INDIC DIGIT EIGHT
    0x0669 => "CONTEXTO", # ARABIC-INDIC DIGIT NINE
    0x06F0 => "CONTEXTO", # EXTENDED ARABIC-INDIC DIGIT ZERO
    0x06F1 => "CONTEXTO", # EXTENDED ARABIC-INDIC DIGIT ONE
    0x06F2 => "CONTEXTO", # EXTENDED ARABIC-INDIC DIGIT TWO
    0x06F3 => "CONTEXTO", # EXTENDED ARABIC-INDIC DIGIT THREE
    0x06F4 => "CONTEXTO", # EXTENDED ARABIC-INDIC DIGIT FOUR
    0x06F5 => "CONTEXTO", # EXTENDED ARABIC-INDIC DIGIT FIVE
    0x06F6 => "CONTEXTO", # EXTENDED ARABIC-INDIC DIGIT SIX
    0x06F7 => "CONTEXTO", # EXTENDED ARABIC-INDIC DIGIT SEVEN
    0x06F8 => "CONTEXTO", # EXTENDED ARABIC-INDIC DIGIT EIGHT
    0x06F9 => "CONTEXTO", # EXTENDED ARABIC-INDIC DIGIT NINE
    0x0640 => "DISALLOWED", # ARABIC TATWEEL
    0x07FA => "DISALLOWED", # NKO LAJANYALAN
    0x302E => "DISALLOWED", # HANGUL SINGLE DOT TONE MARK
    0x302F => "DISALLOWED", # HANGUL DOUBLE DOT TONE MARK
    0x3031 => "DISALLOWED", # VERTICAL KANA REPEAT MARK
    0x3032 => "DISALLOWED", # VERTICAL KANA REPEAT WITH VOICED SOUND MARK
    0x3033 => "DISALLOWED", # VERTICAL KANA REPEAT MARK UPPER HALF
    0x3034 => "DISALLOWED", # VERTICAL KANA REPEAT WITH VOICED SOUND MARK UPPER HA
    0x3035 => "DISALLOWED", # VERTICAL KANA REPEAT MARK LOWER HALF
    0x303B => "DISALLOWED", # VERTICAL IDEOGRAPHIC ITERATION MARK
  }.freeze

  attr_reader :value, :ucdata

  def initialize(value, ucdata:)
    @value = value
    @ucdata = ucdata
  end

  def inspect
    "U+%04X" % value
  end

  def casefold(s)
    s.unpack("U*").map { |x| ucdata.ucd_cf[x] || x }.flatten.pack("U*")
  end

  def exception_value
    EXCEPTIONS.fetch(value, false)
  end

  def name
    return ucdata.ucd_data[value].first if ucdata.ucd_data[value]
    return "<noncharacter>" if ucdata.ucd_props[value]&.include?("Noncharacter_Code_Point")

    "<reserved>"
  end

  def general_category
    ucdata.ucd_data.fetch(value, [])[1]
  end

  def combining_class
    ucdata.ucd_data.fetch(value, [])[2]
  end

  def bidi_class
    ucdata.ucd_data.fetch(value, [])[3]
  end

  def unassigned?
    !(ucdata.ucd_props[value]&.include?("Noncharacter_Code_Point") || ucdata.ucd_data.key?(value))
  end

  def ldh?
    (value == 0x002d) || (0x0030..0x0039).cover?(value) || (0x0061..0x007a).cover?(value)
  end

  def join_control?
    properties.include?("Join_Control")
  end

  def properties
    ucdata.ucd_props.fetch(value, [])
  end

  def joining_type
    ucdata.ucd_as[value]
  end

  def char
    [value].pack("U*")
  end

  def nfkc_cf
    return char unless char.valid_encoding?

    casefold(char.unicode_normalize(:nfkc)).unicode_normalize(:nfkc)
  end

  def unstable?
    char != nfkc_cf
  end

  def ignorable_property?
    %w[Default_Ignorable_Code_Point White_Space Noncharacter_Code_Point].any? do |prop|
      ucdata.ucd_props[value]&.include?(prop)
    end
  end

  def ignorable_block?
    ["Combining Diacritical Marks for Symbols", "Musical Symbols",
     "Ancient Greek Musical Notation"].include?(block)
  end

  def block
    ucdata.ucd_block[value]
  end

  def old_hangul_jamo?
    %w[L V T].include?(hangul_type)
  end

  def hangul_type
    ucdata.ucd_hst[value]
  end

  def letters_digits?
    %w[Ll Lu Lo Nd Lm Mn Mc].include?(general_category)
  end

  def idna2008_status
    return exception_value if exception_value
    return "UNASSIGNED" if unassigned?
    return "PVALID" if ldh?
    return "CONTEXTJ" if join_control?
    return "DISALLOWED" if unstable?
    return "DISALLOWED" if ignorable_property?
    return "DISALLOWED" if ignorable_block?
    return "DISALLOWED" if old_hangul_jamo?
    return "PVALID" if letters_digits?

    "DISALLOWED"
  end

  def uts46_data
    ucdata.ucd_idnamt[value]
  end

  def uts46_status
    uts46_data&.join(" ")
  end

  def diagnose
    <<~MSG
      #{inspect}
      Name:             #{name}
      Exceptions:       #{exception_value}
      Unassigned:       #{unassigned?}
      Properties:       #{properties.sort.join(' ')}
      Join Control:     #{join_control?}
      NFKC CF:          #{nfkc_cf.unpack('U*').map { |x| 'U+%04X' % x }.join(' ')}
      Unstable:         #{unstable?}
      Ignorable Prop:   #{ignorable_property?}
      Block:            #{block || '-'}
      Ignorable Block:  #{ignorable_block?}
      Hangul Syll Type: #{hangul_type || '-'}
      Old Hangul Jamo:  #{old_hangul_jamo?}
      General Category: #{general_category}
      Letters Digits:   #{letters_digits?}
      Combining Class:  #{combining_class || '-'}
      Bidi Class:       #{bidi_class || '-'}
      IDNA 2008 status: #{idna2008_status}
      UTS 46 status:    #{uts46_status}
      (Unicode #{ucdata.version} [sys:#{ucdata.system_version}])
    MSG
  end
end
