# frozen_string_literal: true

require 'csv'
require 'nokogiri'
require './const'

def read_and_extract(filename, search_word)
  results = []

  articles = read_and_clean(filename)

  # Wikipediaの出力ファイルには複数のXML エレメント(doc エレメント)が並列して書かれており、全てをネストするルートエレメントが不在
  # この場合Nokogiriは一番先頭のXMLエレメントとその子供しかパースしてくれないので、
  # ルートエレメントを追加して、全体をvalidなXMLにする
  xml = "<root>#{articles}</root>"

  docs = Nokogiri::XML(xml).xpath('//doc')

  docs.each do |doc|
    next unless doc.text.include?(search_word)

    result = []
    result << doc.attr('id')
    result << doc.attr('title')
    result << doc.text

    results << result
  end
  results
end

def read_and_clean(filename)
  # CSV出力用に改行削除
  # また、一部不正な改行タグがテキストに含まれてしまっており、適切なパースの邪魔をするため、それも削除
  # <証明> や <明日天気になあれ> など特殊な<>の使用方があるため、すべて別の文字に置き換える。
  # docタグのみ残す
  all_file_content = ''
  File.readlines(filename).each do |line|
    text = line.gsub(/[\r\n]/, '').gsub(/<(BR|br)>/, '')
    next if text.empty?

    matched = text.match(/<.+>/)

    if matched.nil?
      all_file_content += text
      next
    end

    raise 'Unexpected Case' if matched.length > 1

    has_tag_text = matched[0]
    all_file_content += if has_tag_text =~ /^<doc/ || has_tag_text =~ %r{/doc>$}
                          # doc タグはそのまま
                          text
                        else
                          # doc 以外で<>を使ってる場合、別の記号に変更
                          has_tag_text.tr('<', '[').tr('>', ']')
                        end
  end
  all_file_content
end

def append_to_csv(filename, results)
  CSV.open(filename, 'a') do |csv| # 追記
    results.each do |result|
      csv << result
    end
  end
end

def init_output_file(filename)
  CSV.open(filename, 'w') do |csv|
    csv << %w[id title content]
  end
end

if $PROGRAM_NAME == __FILE__
  # ヘッダーのみ先に出力
  init_output_file(KEYWORD_ARTICLES_CSV_NAME)

  # ディレクトリを走査し、ファイルの内容からキーワードにマッチするものを全て出力
  Dir.glob('./extracted/*') do |dir|
    p '**********'
    p dir
    p '**********'
    Dir.glob("#{dir}/*") do |filename|
      p filename

      results = read_and_extract(filename, KEY_WORD)
      append_to_csv(KEYWORD_ARTICLES_CSV_NAME, results) if results.count > 0
    end
  end

  p 'DONE'
  count = CSV.foreach(KEYWORD_ARTICLES_CSV_NAME, headers: true).count
  p "Number of records: #{count}"
end
