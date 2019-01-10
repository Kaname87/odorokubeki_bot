require "csv"
require 'nokogiri'
require "./const"

def read_and_extract(filename, search_word)
    results = []
    # CSV出力用に改行削除
    articles = File.read(filename).gsub(/[\r\n]/,"")

    # wikipediaの出力ファイルには複数のXML エレメント(doc エレメント)が並列して書かれており、全てをネストするルートエレメントが不在
    # この場合Nokogiriは一番先頭のXMLエレメントとその子供しかパースしてくれないので、
    # ルートエレメントを追加して、全体をvalidなXMLにする
    xml = "<root>#{articles}</root>"
    
    docs = Nokogiri::XML(xml).xpath('//doc')
    docs.each do |doc|
        if (doc.text.include?(search_word))
            result = []
            result << doc.attr('id')
            result << doc.attr('title')
            result << doc.text
    
            results << result
        end
    end
    return results
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
        csv << ['id', 'title', 'content']
    end
end

# ヘッダーのみ先に出力
init_output_file(ARTICLES_FILE_NAME)

# ディレクトリを走査し、ファイルの内容からキーワードにマッチするものを全て出力
Dir.glob("./extracted/*")  do |dir| 
    p "**********"
    p dir
    p "**********"
    Dir.glob("#{dir}/*") do |filename|

        p filename

        results = read_and_extract(filename, KEY_WORD)
        if (results.count > 0) 
            append_to_csv(ARTICLES_FILE_NAME, results)
        end
    end
end

p "DONE"
count = CSV.foreach(result_filename, headers: true).count
p "Number of records: #{count}"
