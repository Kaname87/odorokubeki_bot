require "csv"
require "./const"

def extract_sentence(content) 
    # 文で区切るパターン
    sentence_by_period = extract_sentence_by_period(content)
    if (sentence_by_period.length <= MAX_SENTENCE_LENGTH)
        return sentence_by_period
    end
    
    # 括弧で区切るパターン
    sentence_by_parentheses = extract_sentence_by_parenthese(content)
    if (sentence_by_parentheses.length <= MAX_SENTENCE_LENGTH)
        return sentence_by_parentheses
    end

    # どちらも長すぎたら、長さで
    return extract_sentence_by_length(content)
end

def extract_sentence_by_period(content)
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

def extract_sentence_by_parenthese(content)
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

def extract_sentence_by_length(content)
    keyword_idx = content.index(KEY_WORD)
    ellipsis = '...'

    end_idx = keyword_idx + MAX_SENTENCE_LENGTH - ellipsis.length
    return content[keyword_idx...end_idx] + ellipsis
end

def outout()
end

def create_tweet_text(row)
    sentence = extract_sentence(row[CONTENT_IDX])
     
    text = <<-EOS
#{sentence}

- #{row[TITLE_IDX]}
#{row[URL_IDX]}
    EOS
    
    return text
end

# p ARTICLES_FILE_NAME

tweet_texts = []
CSV.foreach(ARTICLES_FILE_NAME).drop(1).each do |row|    
    tweet_texts << create_tweet_text(row)
end

File.open('text.txt', 'w') do |f|
    f.puts(tweet_texts.join("\n"))
end

a = "ウィル・ロジャース(Will Rogers)、エドガー・ライス・バローズなどと並び賞されている。 驚くべきことに、それほど莫大な量の仕事をしていたにもかかわらず、バトラーはあくまでパートタイムの作家であった。彼は銀行家としてフルタイムで働き、彼の属するロ"

b = "Greg Pratoはオールミュージックにおいて5点満点中4点を付け「前作とほぼ同様に良い作品だが、驚くべきことに、理由は分からないが1991年秋にリリースされてから間もなく、視界から消えていった」「バンドが継続的に表現してきたサイエンス・フィクション的な虚構は、音楽と歌詞の両方を通じて伝わっており、初期ピンク・フロイド（『おせっかい』の頃）やラッシュ（『鋼の抱擁（英語版）』の頃）にヘヴィメタル的な鋭利さを加味したように響く」と評している[4]。"
# extract_sentence_by_parenthese(b)
# p extract_sentence_by_length(b).length
# p extract_sentence_by_length(b)


# a = "手可能性、装弾の入手可能性と選択、すべてを考慮すると、むしろ驚くべきことに勝者は7mm-08レミントンだ。\n    - 7mm-08レミントン7mm-08レミントン7mm-08レミントン（英：\"7mm-08 Remington\"）はライフル実包。1958年ごろに開発された 7mm/308 として知られるワイルドキャット・カートリッジをほとんど直接コピーしたものである。名称からわかるとおり、.308ウィンチェスターの薬きょうをネック・ダウンし を装着できるようにしたもので、それに伴い薬きょうの全長がわずかに長くなっている。.308 Win をベースとした実包の中でも.243ウィンチェスターに次いで二番目に人気が高いが、元となった .308 はこれら両方よりも普及している 。1980年にレミントン・アームズ社が自らの名前を命名し、同社のライフルであるとモデル700の口径の選択肢として提供したことで普及した。7mm-08 は工場装弾の選択肢の幅が非常に広く、手詰を行わない人々にとっても選択肢となり得る。重さ100から195グレーンの弾頭が使用できる。130-150グレーンの弾頭はほとんどの狩猟用に適しているが、長距離においては高い弾道係数を確保するためにさらに重い弾頭を選択することになると考えられる。構成によっては中型あるいはさらに大型の獲物や標的射撃に供するため、154から195グレーンの弾頭が使用されることもある。通常、7mm-08 では中程度の燃焼速度のライフル用火薬が最もうまく機能するとされている。7mm-08 は弾頭重量の選択肢の幅が広く、バーミント、狩猟、、長距離射撃などに適しており、同様ににも適している。長距離の標的射撃とメタリック・シルエット射撃においては、0.625 BC (G1) でプラスチック・チップ付きの162グレーン A-Max 弾頭が非常に精度が高いとされている。この A-Max 弾頭とシエラの150グレーンの MatchKing はシルエット射手に人気がある。7mm-08レミントンは密林や大きく開けた場所を含めたほとんどの狩猟環境で使用できる。また、.308ウィンチェスターや.30-06スプリングフィールドと比べると、7mmというわずかに小さい径の弾頭は一般的によりよい弾道係数 (BC) を持っているので、飛翔中に抗力と横風の影響を受けにくく、同等の弾頭重量においてはより平坦な軌道となる。そして、その軌道は.270ウィンチェスターに匹敵するとされている。リコイルは .243 Win よりもわずかに大きいが、ほとんどの場合は .308 Win よりも小さい。このリコイルの小ささは年少者や初心者に向いているが、経験者やハンターにとっても同様に有用である。\"Shooting Industry\" の Howard Brant は「7mm-08 は狩猟においてはなんとも大当たりの商品である。北米や他の場所にみられる中型のビッグ・ゲームすべてを効率的に仕留めるのに十分すぎる威力をもった最高の実包だ。」と述べている。雑誌 \"Petersen's Hunting\" の Wayne van Zwoll は「効率的な薬きょうの設計と、北アメリカのほとんどのビッグ・ゲームに適した弾頭重量の選択肢の多さのおかげで、7mm-08 は狩猟全般においては最高の選択肢である。リコイルも小さく、軽量なショート・アクション・ライフルに最適だ。また、140グレーンの弾頭は.308の150グレーン弾頭よりも500ヤード地点の標的に対してより早く同等のエネルギーを持って着弾するため、メタリック・シルエットで好まれている。」と述べた。同様にエルクにとっては\"致命的\"であるとも述べた。\"Field & Stream\" の David E. Petzal は「7mm-08 の利点は非常に軽量なこと、砲口爆風があまり生じないこと、用途に合わせた弾頭重量の豊富さ、そしてその一流の精度である。」と述べた"
# p extract_sentence(a)