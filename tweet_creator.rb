# frozen_string_literal: true

require 'csv'
require './const'

class TweetCreator
  ID_COLUMN_IDX = 0
  TITLE_COULMN_IDX = 1
  CONTENT_COLUMN_IDX = 2

  OUTPUT_TEXT = 'text.txt'

  def initialize(source_filename)
    @rows = CSV.foreach(source_filename).drop(1)
  end

  def pick_random_one
    tartget_row = rondom_select_row
    tweet_text = create_tweet_text(tartget_row)
  end

  def output_all_to_file
    tweet_texts = []
    @rows.each do |row|
      tweet_texts << create_tweet_text(row)
    end
    File.open(OUTPUT_TEXT, 'w') do |f|
      f.puts(tweet_texts.join("\n"))
    end
  end

  private

  def calc_max_sentence_length(row)
    MAX_TWEET_LENGTH - (row[TITLE_COULMN_IDX].length + row[ID_COLUMN_IDX].length + URL_BASE.length)
  end

  def extract_sentence(content, max_sentence_length)
    # 文で区切るパターン
    sentence_by_period = extract_sentence_by_period(content, max_sentence_length)
    if sentence_by_period.length <= max_sentence_length
      return sentence_by_period
    end

    # 括弧で区切るパターン
    sentence_by_parentheses = extract_sentence_by_parenthese(content, max_sentence_length)
    if sentence_by_parentheses.length <= max_sentence_length
      return sentence_by_parentheses
    end

    # どちらも長すぎたら、長さで
    extract_sentence_by_length(content, max_sentence_length)
  end

  def extract_sentence_by_period(content, _max_sentence_length)
    keyword_idx = content.index(KEY_WORD)
    # keyword前と後に分割
    first_part = content[0...keyword_idx]
    last_part = content[keyword_idx..-1]

    period = '。'

    # Sentence のstart index
    start_idx = first_part.rindex(period)
    if start_idx.nil?
      start_idx = 0
    else
      start_idx += 1 # period charcterを含まない為に+1
    end

    # Sentence の end index
    end_idx = last_part.index(period)
    end_idx = last_part.length if end_idx.nil?

    first_part_sentence = first_part[start_idx..-1]

    last_part_sentence = last_part[0..end_idx]

    first_part_sentence + last_part_sentence
  end

  def extract_sentence_by_parenthese(content, _max_sentence_length)
    keyword_idx = content.index(KEY_WORD)
    # keyword前と後に分割
    first_part = content[0...keyword_idx]
    last_part = content[keyword_idx..-1]

    start_parenthese = '「'
    end_parenthese = '」'

    # Sentence のstart index
    start_idx = first_part.rindex(start_parenthese)
    start_idx = 0 if start_idx.nil?

    # Sentence の end index
    end_idx = last_part.index(end_parenthese)
    end_idx = last_part.length if end_idx.nil?

    first_part_sentence = first_part[start_idx..-1]
    last_part_sentence = last_part[0..end_idx]

    first_part_sentence + last_part_sentence
  end

  def extract_sentence_by_length(content, max_sentence_length)
    keyword_idx = content.index(KEY_WORD)
    ellipsis = '...'

    end_idx = keyword_idx + max_sentence_length - ellipsis.length
    content[keyword_idx...end_idx] + ellipsis
  end

  def create_tweet_text(row)
    max_sentence_length = calc_max_sentence_length(row)
    sentence = extract_sentence(row[CONTENT_COLUMN_IDX], max_sentence_length)

    text = <<~TWEET
      #{sentence}

      - #{row[TITLE_COULMN_IDX]}
      #{URL_BASE}#{row[ID_COLUMN_IDX]}
    TWEET

    text
  end

  def rondom_select_row
    last_idx = @rows.length - 1
    target_idx = Random.rand(0..last_idx)
    @rows[target_idx]
  end
end

p TweetCreator.new(KEYWORD_ARTICLES_CSV_NAME).pick_random_one if $PROGRAM_NAME == __FILE__
