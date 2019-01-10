require "csv"
require "./const"

def extract_sentence(content, max_sentence_length)
    # 文で区切るパターン
    sentence_by_period = extract_sentence_by_period(content, max_sentence_length)
    if (sentence_by_period.length <= max_sentence_length)
        return sentence_by_period
    end

    # 括弧で区切るパターン
    sentence_by_parentheses = extract_sentence_by_parenthese(content, max_sentence_length)
    if (sentence_by_parentheses.length <= max_sentence_length)
        return sentence_by_parentheses
    end

    # どちらも長すぎたら、長さで
    return extract_sentence_by_length(content, max_sentence_length)
end

def extract_sentence_by_period(content, max_sentence_length)
    keyword_idx = content.index(KEY_WORD)
    # keyword前と後に分割
    first_part = content[0...keyword_idx]
    last_part = content[keyword_idx..-1]

    period = "。";

    # Sentence のstart index
    start_idx = first_part.rindex(period)
    if start_idx == nil
        start_idx = 0 
    else
        start_idx += 1 # period charcterを含まない為に+1
    end

    # Sentence の end index
    end_idx = last_part.index(period) 
    if end_idx == nil
        end_idx = last_part.length
    end

    first_part_sentence = first_part[start_idx..-1]

    last_part_sentence = last_part[0..end_idx]

    return first_part_sentence + last_part_sentence
end

def sentence()
end

def extract_sentence_by_parenthese(content, max_sentence_length)
    keyword_idx = content.index(KEY_WORD)
    # keyword前と後に分割
    first_part = content[0...keyword_idx]
    last_part = content[keyword_idx..-1]

    start_parenthese = "「";
    end_parenthese = "」";

    # Sentence のstart index
    start_idx = first_part.rindex(start_parenthese)
    if start_idx == nil
        start_idx = 0 
    end

    # Sentence の end index
    end_idx = last_part.index(end_parenthese)
    if end_idx == nil
        end_idx = last_part.length
    end

    first_part_sentence = first_part[start_idx..-1]
    last_part_sentence = last_part[0..end_idx]

    return first_part_sentence + last_part_sentence
end

def extract_sentence_by_length(content, max_sentence_length)
    keyword_idx = content.index(KEY_WORD)
    ellipsis = '...'

    end_idx = keyword_idx + max_sentence_length - ellipsis.length
    return content[keyword_idx...end_idx] + ellipsis
end

def outout()
end

def create_tweet_text(row)
    max_sentence_length = calc_max_sentence_length(row)
    sentence = extract_sentence(row[CONTENT_IDX], max_sentence_length)

    text = <<-TWEET
#{sentence}

- #{row[TITLE_IDX]}
#{URL_BASE}#{row[ID_IDX]}
    TWEET

    return text
end

def calc_max_sentence_length(row)
    MAX_TWEET_LENGTH - (row[TITLE_IDX].length + row[ID_IDX].length + URL_BASE.length)
end

tweet_texts = []
CSV.foreach(KEYWORD_ARTICLES_CSV_NAME).drop(1).each do |row|
    tweet_texts << create_tweet_text(row)
end

File.open('text.txt', 'w') do |f|
    f.puts(tweet_texts.join("\n"))
end
