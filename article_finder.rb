# frozen_string_literal: true

require 'csv'
require 'nokogiri'
require './const'

def read_and_extract(filename, search_word)
  results = []
  # CSV出力用に改行削除
  # また、一部不正な改行文字がテキストに含まれてしまっており、適切なパースの邪魔をするため、それも削除
  articles = File.read(filename).gsub(/[\r\n]/, '').gsub(/<(BR|br)>/, '')

  # wikipediaの出力ファイルには複数のXML エレメント(doc エレメント)が並列して書かれており、全てをネストするルートエレメントが不在
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
