require "csv"

def extract_url(article)
    matched = /url="[\S]+/.match(article)
    url = matched[0].gsub!("url=\"", "").gsub!('"', '')
end

def extract_title(article)
    matched = /title=".+">/.match(article)
    title = matched[0].gsub!("title=\"", "").gsub!('">', '')
end

def extract_content(article, search_word)
    word_index = article.index(search_word)
    start_sub = [word_index - 30, 0].max
    end_sub = start_sub + 100
    content = "..." + article[start_sub..end_sub] + "..."
end


def read_and_extract(filename, search_word)
    results = []
    contents = File.read(filename)
    
    articles = contents.split("</doc>")
    articles.each do |article|
        if (article.index(search_word) != nil)
            article.delete!("\n")
            
            result = []
            result << extract_url(article)
            result << extract_title(article)
            result << extract_content(article, search_word)
            
            results << result
        end 
    end
    results
end

def write_csv(filename, results)
    CSV.open(filename, 'a') do |csv| # Add to existing text
        results.each do |result|
            csv << result
        end 
    end
end

def init_output_file(filename)
    CSV.open(filename, 'w') do |csv|
        csv << ['url', 'title', 'content']
    end
end

search_word = "驚くべきことに"
result_filename = 'result.csv'

init_output_file(result_filename)

Dir.glob("./extracted/*")  do |dir| 
    p "**********"
    p dir
    p "**********"
    Dir.glob("#{dir}/*") do |filename|
        p filename
        results = read_and_extract(filename, search_word)
        if (results.count > 0) 
            write_csv(result_filename, results)
        end
    end
end