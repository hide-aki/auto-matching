module AutoMatching
  module Reader
    class Ikukuru < ReaderBase
      include Common::Ikukuru

      private
        def search_board
          logging_start(__method__)

          # ヒミツ掲示板 → いますぐ会いたい
          session.visit "https://sp.194964.com/bbs/show_genre.html?q=cm1BMmxOeU8zZE1tbnFkUzFmUWs3dz09"

          # 地域を移動
          session.visit "https://sp.194964.com/bbs/show_bbs_area_move.html?q=aTJVNnJuMDg5NVdhLytYK05tbG1vUT09"

          # 東京 選択
          session.visit "https://sp.194964.com/bbs/exec_bbs_area_move.html?q=a2YxRkxVbk15bUc5OVJQQnFTbE4yS2N4NVNVUmdOZUtVZkNFbm8yMmtqcz0%3D"

          # いますぐ会いたい
          session.visit "https://sp.194964.com/bbs/show_bbs.html?q=ZTJvTzJzRGhPQW5yRmsrdm5KeXhFdz09"
          # session.visit "https://sp.194964.com/bbs/show_bbs.html?q=TTVzV090eEJFdG42aEc3ZnYzeitXZz09"

          # TODO
          logging_end(__method__)
        end

        def read_board
          logging_start(__method__)
          post_data = {}
          @post_data_list = []

          converter = AutoMatching::Converter::Ikukuru.new

          value01 = []


          # TODO
          # 取得する大枠のテーブル設定
          value00 = session.all(".contentsTextContribute").map { |t| t.first(".refinedBbsDesign") }
          get_time = session.all(".timeContribute")
          get_post_title = session.all(".textComment")
          get_url = session.all(".textComment").map { |t| t.find(".refinedBbsDesign") }

          # fromが格納されている部分の取得
          15.times do
            value01 = session.all(".contentsTextContribute").each { |t|
              t.all(:css, "span")
            }
          end

          # 各要素取得
          category_list = session.find("#title").text.strip
          get_post_at = get_time.map { |t| t.text.strip }
          url_list = get_url.map { |t| t[:href] }
          title_list = get_post_title.map { |t| t.text.strip }
          get_sex = value00.map { |t| t.find("span.woman").text.strip }
          get_name_age = value00.map { |t| t.text.gsub(/♀/, "") }
          get_from = value01.map { |t| t.text }

          from_list, trip_from_list = converter.split_from_value(get_from)

          # Sider落ちるため保存はしませんが、旅行先の住所を格納している変数を下に記述しておく
          trip_from_list

          sex_list = converter.sex_value_change(get_sex)

          name_list, age_list = converter.split_name_age_value(get_name_age)

          post_at_list = converter.post_at_value_change(get_post_at)

          source_site_id = SourceSite.find_by(key: SourceSite::KEY_IKUKURU).id

          # postsのprefecture,city,addressには何も設定しない
          prefecture_list = ""
          city_list = ""
          address_list = ""

          # 配列の中にハッシュとして取得した要素を格納
          15.times.with_index do |i|
            post_data = { source_site_id: source_site_id,
              url: url_list[i], title: title_list[i], sex: sex_list[i], name: name_list[i],
              age: age_list[i], post_at: post_at_list[i], category: category_list,
              prefecture: prefecture_list, city: city_list, address: address_list, from: from_list[i]
            }
            @post_data_list[i] = post_data
          end

          logging_end(__method__)
        end

        def save_board
          logging_start(__method__)
          # TODO
          @post_data_list.each do |d|
            profile = {}
            profile[:source_site_id] = d[:source_site_id]
            profile[:name] = d[:name]
            profile[:age] = d[:age]
            profile[:sex] = d[:sex]
            profile[:from] = d[:from]

            post = {}
            post[:title] = d[:title]
            post[:url] = d[:url]
            post[:post_at] = d[:post_at]
            post[:category] = d[:category]
            post[:prefecture] = d[:prefecture]
            post[:city] = d[:city]
            post[:address] = d[:address]

            @profile = Profile.new(profile)
            @post = @profile.build_post(post)

            if @post.save!
              logger.debug("成功しました")
            else
              logger.debug("失敗しました")
            end
          end

          logging_end(__method__)
        end
    end
  end
end
