module Players
  
   class Edinet_player
    require "rexml/document"
    require "bigdecimal"
    require 'gettext/utils'
    include REXML
    include Validate
    
    def initialize()
    end

    def set_request(request)
      @request = request
    end
    
    def set_content(current_user,content,params)
      @current_user = current_user
      @content = content
      @content_properties = {}
      @content.contents_propertiess.each{|property|
      @content_properties[property[:property_key]] = property[:property_value]
      }
      if !params["dragflag"]
        @params = params
      else
            flagparams = Hash.new
        flagparams = params
        flagparams["contents_upload"]="flag"
        @params = flagparams
      end
    end
    
    # 画面入力項目チェック
    def validate(current_user,params)
      if is_empty(params["contents_upload"]["xbrlfile_path"])
        raise "ERR_0x01025801"
      end
      
      #XBRL解析、データ取得
      if File::extname(params["contents_upload"]["xbrlfile_path"].original_filename) != ".xbrl"
        raise "ERR_0x01025802"
      end
    end
    
    # プレーヤ設定保存時の処理
    def config_save
      
    end
    
      
    #コンフィグデータが必要な場合
    def config_create
      #aaaa
    end
    
    #出力用HTML
    def get_html
      RuntimeSystem.content_save_dir(@content)
      storefilename = ""
      if @params["contents_upload"] == "flag"
        storefilename = @content_properties["xbrlfile_path"]
      else
        fileobj = @params["contents_upload"]["xbrlfile_path"]
        storefilename = @content_properties["xbrlfile_path"]
        filepath = RuntimeSystem.get_upload_file(@content, @params["contents_upload"]["xbrlfile_path"], storefilename)
      end
      html=""
      xtoh()
      return html
    end
    
    
    #indexファイルでファイルアップロード処理
    def index
      @file = []
      @file = Array.new(1)
    end
    
    #各要素ブロックのタグ名を配列に格納
    def gettag()
      tags = []
      tags[0] = "//jpfr-di:EntityNameJaEntityInformation" #会社名
      tags[1] = "//jpfr-t-cte:NetSales" #売上高　①
      tags[2] = "//jpfr-t-cte:OperatingIncome" #営業利益　②
      tags[3] = "//jpfr-t-cte:OrdinaryIncome" #経常利益　③
      tags[4] = "//jpfr-t-cte:NetIncome" #当期純利益　④
      tags[5] = "//jpfr-t-cte:Assets" #総資産　⑤
      tags[6] = "//jpfr-t-cte:NetAssets" #自己資本　⑥
      tags[7] = "//jpfr-t-cte:CapitalStock" #資本金　⑦
      tags[8] = "//jpfr-t-cte:RetainedEarnings" #利益剰余金　⑧
      return tags
    end
    
    #ファイル保存ディレクトリパスを定義
    def getContentsPath()
      return "./users/userdiv/userid/channelid/pageid/contentsid/"
    end
    
    #3桁ごとにカンマ区切りするmoney関数を定義
    def money(num)
     return (num.to_s =~ /[-+]?\d{4,}/) ? (num.to_s.reverse.gsub(/\G((?:\d+\.)?\d{3})(?=\d)/, '\1,').reverse) : num.to_s
   end
   
   def accountingItem
      @netSales3 = ""
      @operatingIncome3 = "" 
      @ordinaryIncome3 = ""
      @netIncome3 = ""
      @netSales1 = ""
      @operatingIncome1 = ""
      @ordinaryIncome1 = "" 
      @netIncome1 = ""
      @assets3 = ""
      @netAssets3 = ""
      @capitalAdequacyRatio = ""
      @capitalStock3 = ""
      @retainedEarnings3 = ""
   end
  
  #ここから本番開始。ファイル読み込み、XBRL解析、HTML出力
  def xtoh
    
  #ページ背景色取得   
      #アップロードされたファイルのデータ取得
     fileObjs = Array.new(1)
     #p fileObjs[0] = @params["contents_upload"]["xbrlfile_path"]
     fileObjs[0] = File.open(RuntimeSystem.content_save_dir(@content)+@content_properties["xbrlfile_path"])   
     #205対応以前
     #fileObjs[0] = @params["contents_upload"]["xbrlfile_path"]
     
     
 #以前はここで下記のflashで作成完了＆エラー表示しようとしていましたが、この書き方がどうしてもバグを招くので別途エラーチェックのブロック（雛形のkickの部分ですね）をいれようと思います。
 #!flg ? flash[:notice] = "作成されたページはVASDAQ.TVのChannelとして設定・閲覧が可能です" : flash[:error] = "参照ファイルを入力して下さい"
 #redirect_to :action => "index"if flg
   
      k = 0
      fileObjs.length.times{
        fileobj = fileObjs[k]
       

    
        str = fileobj.read
        doc = Document.new str             
        tags = gettag()
        operationalElem = []
        #operationalElemに格納する値は下記(自己資本比率、ROE、ROAの各値を計算する為)
        #operationalElem[0] = NetIncome（CurrentYearNonConsolidatedDuration） #当期純利益(最新)
        #operationalElem[1] = Assets（CurrentYearNonConsolidatedInstant） #総資産(最新)
        #operationalElem[2] = NetAssets（CurrentYearNonConsolidatedInstant） #自己資本(最新)
        accountingItem
        for j in 0...tags.length
          
         XPath.each( doc,tags[j])do|elems|  
          case j
            when 0
            # => "会社名" 
             @companyName = elems.text
            when 1
            # => "売上高"
             @NetSales = elems
                if elems.attribute("contextRef").value == "Prior1YearNonConsolidatedDuration"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netSales1 = elems.text
                     @decimal = _("一円")
                      end
                     @netSales1 = money(dividCalc)

                    elsif elems.attribute("contextRef").value == "Prior1YearConsolidatedDuration"
                  @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netSales2 = elems.text
                     @decimal = _("一円")
                  end
                 @netSales2 = money(dividCalc)
                 
                elsif elems.attribute("contextRef").value == "CurrentYearNonConsolidatedDuration"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netSales3 = elems.text
                     @decimal = _("一円")
                      end
                     @netSales3 = money(dividCalc)
                     
                    elsif elems.attribute("contextRef").value == "CurrentYearConsolidatedDuration"
                 @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal =_("千円")
                   else @netSales4 = elems.text
                     @decimal = _("一円")
                  end
                 @netSale4 = money(dividCalc)
               end
             
            when 2
            # => "営業利益"
             @OperatingIncome = elems
                if elems.attribute("contextRef").value == "Prior1YearNonConsolidatedDuration"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @operatingIncome1 = elems.text
                     @decimal = _("一円")
                  end
                 @operatingIncome1 = money(dividCalc)
                elsif elems.attribute("contextRef").value == "Prior1YearConsolidatedDuration"
                  @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @operatingIncome2 = elems.text
                     @decimal = _("一円")
                  end
                 @operatingIncome2 = money(dividCalc) 
                elsif elems.attribute("contextRef").value == "CurrentYearNonConsolidatedDuration"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @operatingIncome3 = elems.text
                     @decimal = _("一円")
                  end
                 @operatingIncome3 = money(dividCalc)
                elsif elems.attribute("contextRef").value == "CurrentYearConsolidatedDuration"
                 @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @operatingIncome4 = elems.text
                     @decimal = _("一円")
                  end
                 @operatingIncome4 = money(dividCalc)
                end
             
            when 3
            # => "経常利益"
             @OrdinaryIncome = elems
                if elems.attribute("contextRef").value == "Prior1YearNonConsolidatedDuration"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @ordinaryIncome1 = elems.text
                     @decimal = _("一円")
                  end
                 @ordinaryIncome1 = money(dividCalc)
                elsif elems.attribute("contextRef").value == "Prior1YearConsolidatedDuration"
                  @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @ordinaryIncome2 = elems.text
                     @decimal = _("一円")
                  end
                 @ordinaryIncome2 = money(dividCalc) 
                elsif elems.attribute("contextRef").value == "CurrentYearNonConsolidatedDuration"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @ordinaryIncome3 = elems.text
                     @decimal = _("一円")
                  end
                 @ordinaryIncome3 = money(dividCalc)
                elsif elems.attribute("contextRef").value == "CurrentYearConsolidatedDuration"
                 @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @ordinaryIncome4 = elems.text
                     @decimal = _("一円")
                  end
                 @ordinaryIncome4 = money(dividCalc)
                end

            when 4
            # => "当期純利益"
             @NetIncome = elems
                if elems.attribute("contextRef").value == "Prior1YearNonConsolidatedDuration"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netIncome1 = elems.text
                     @decimal = _("一円")
                  end
                 @netIncome1 = money(dividCalc)
                elsif elems.attribute("contextRef").value == "Prior1YearConsolidatedDuration"
                  @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netIncome2 = elems.text
                     @decimal = _("一円")
                  end
                 @netIncome2 = money(dividCalc)
                 elsif elems.attribute("contextRef").value == "Prior1YTDConsolidatedDuration"
                  @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netIncome2 = elems.text
                     @decimal = _("一円")
                  end
                 @netIncome2 = money(dividCalc) 
                elsif elems.attribute("contextRef").value == "CurrentYearNonConsolidatedDuration"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netIncome3 = elems.text
                     @decimal = _("一円")
                  end
                 @netIncome3 = money(dividCalc)
                 operationalElem << elems.text.to_f
                 elsif elems.attribute("contextRef").value == "CurrentYTDNonConsolidatedDuration"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netIncome3 = elems.text
                     @decimal = _("一円")
                  end
                 @netIncome3 = money(dividCalc)
                elsif elems.attribute("contextRef").value == "CurrentYearConsolidatedDuration"
                 @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netIncome4 = elems.text
                     @decimal = _("一円")
                  end
                 @netIncome4 = money(dividCalc)
                 elsif elems.attribute("contextRef").value == "CurrentYTDConsolidatedDuration"
                 @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netIncome4 = elems.text
                     @decimal = _("一円")
                  end
                 @netIncome4 = money(dividCalc)
                 operationalElem << elems.text.to_f
                end
             
            when 5
             # => "総資産"
             @Assets = elems
                if elems.attribute("contextRef").value == "Prior1YearNonConsolidatedInstant"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @assets1 = elems.text
                     @decimal = _("一円")
                  end
                 @assets1 = money(dividCalc)
                elsif elems.attribute("contextRef").value == "Prior1YearConsolidatedInstant"
                  @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @assets2 = elems.text
                     @decimal = _("一円")
                  end
                 @assets2 = money(dividCalc) 
                elsif elems.attribute("contextRef").value == "CurrentYearNonConsolidatedInstant"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @assets3 = elems.text
                     @decimal = _("一円")
                  end
                 @assets3 = money(dividCalc)
                 operationalElem << elems.text.to_f
                 elsif elems.attribute("contextRef").value == "CurrentQuarterConsolidatedInstant"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @assets3 = elems.text
                     @decimal = _("一円")
                  end
                 @assets3 = money(dividCalc)
                 operationalElem << elems.text.to_f
                elsif elems.attribute("contextRef").value == "CurrentYearConsolidatedInstant"
                 @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @assets4 = elems.text
                     @decimal = _("一円")
                  end
                 @assets4 = money(dividCalc)
                 operationalElem << elems.text.to_f
                 elsif elems.attribute("contextRef").value == "CurrentYTDConsolidatedInstant"
                 @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @assets4 = elems.text
                     @decimal = _("一円")
                  end
                 @assets4 = money(dividCalc)
                end
             
            when 6
            # => "自己資本"
             @NetAssets = elems
                if elems.attribute("contextRef").value == "Prior1YearNonConsolidatedInstant"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netAssets1 = elems.text
                     @decimal = _("一円")
                  end
                 @netAssets1 = money(dividCalc)
                elsif elems.attribute("contextRef").value == "Prior1YearConsolidatedInstant"
                  @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netAssets2 = elems.text
                     @decimal = _("一円")
                  end
                 @netAssets2 = money(dividCalc) 
                elsif elems.attribute("contextRef").value == "CurrentYearNonConsolidatedInstant"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netAssets3 = elems.text
                     @decimal = _("一円")
                  end
                 @netAssets3 = money(dividCalc)
                 operationalElem << elems.text.to_f
                 elsif elems.attribute("contextRef").value == "CurrentQuarterConsolidatedInstant"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netAssets3 = elems.text
                     @decimal = _("一円")
                  end
                 @netAssets3 = money(dividCalc)
                 operationalElem << elems.text.to_f
                elsif elems.attribute("contextRef").value == "CurrentYearConsolidatedInstant"
                 @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netAssets4 = elems.text
                     @decimal = _("一円")
                  end
                 @netAssets4 = money(dividCalc)
                 operationalElem << elems.text.to_f
                 elsif elems.attribute("contextRef").value == "CurrentYTDConsolidatedInstant"
                 @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @netAssets4 = elems.text
                     @decimal = _("一円")
                  end
                 @netAssets4 = money(dividCalc)
                end

            when 7
             # => "資本金"
             @CapitalStock = elems
                if elems.attribute("contextRef").value == "Prior1YearNonConsolidatedInstant"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @capitalStock1 = elems.text
                     @decimal = _("一円")
                      end
                     @capitalStock1 = money(dividCalc)
                    elsif elems.attribute("contextRef").value == "Prior1YearConsolidatedInstant"
                  @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @capitalStock2 = elems.text
                     @decimal = _("一円")
                  end
                 @capitalStock2 = money(dividCalc) 
                elsif elems.attribute("contextRef").value == "CurrentYearNonConsolidatedInstant"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @capitalStock3 = elems.text
                     @decimal = _("一円")
                      end
                     @capitalStock3 = money(dividCalc)
                    elsif elems.attribute("contextRef").value == "CurrentYearConsolidatedInstant"
                 @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @capitalStock4 = elems.text
                     @decimal = _("一円")
                  end
                 @capitalStock4 = money(dividCalc)                 
                end                 
             
            when 8
             # => "利益剰余金"
             @RetainedEarnings = elems
                if elems.attribute("contextRef").value == "Prior1YearNonConsolidatedInstant"
                  @s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @retainedEarnings1 = elems.text
                     @decimal = _("一円")
                  end
                 @retainedEarnings1 = money(dividCalc)
                elsif elems.attribute("contextRef").value == "Prior1YearConsolidatedInstant"
                  @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @retainedEarnings2 = elems.text
                     @decimal = _("一円")
                  end
                 @retainedEarnings2 = money(dividCalc) 
                elsif elems.attribute("contextRef").value == "CurrentYearNonConsolidatedInstant"
                  s_or_c = _("単独")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @retainedEarnings3 = elems.text
                     @decimal = _("一円")
                  end
                 @retainedEarnings3 = money(dividCalc)
                elsif elems.attribute("contextRef").value == "CurrentYearConsolidatedInstant"
                 @s_or_c = _("連結")
                  case
                   when elems.attribute("decimals").value == "-6"
                    then dividCalc = elems.text.to_i / 1000000
                     @decimal = _("百万円")
                   when elems.attribute("decimals").value == "-3"
                    then dividCalc = elems.text.to_i / 1000
                     @decimal = _("千円")
                   else @retainedEarnings4 = elems.text
                     @decimal = _("一円")
                  end
             @retainedEarnings4 = money(dividCalc)                 
            end
        end
           end
       end
    #自己資本比率、ROE、ROAを計算
    capitalAdequacyRatio = operationalElem[2] / operationalElem[1] * 100
    @capitalAdequacyRatio = capitalAdequacyRatio.round(1).to_s

    
    roe = operationalElem[0] / operationalElem[2] * 100
    @roe = roe.round(1).to_s
    
    roa = operationalElem[0] / operationalElem[1] * 100
    @roa = roa.round(1).to_s 
    #HTMLファイル作成開始
    
       File.open( RuntimeSystem.content_save_dir(@content) + "index.html","w"){|f|
        f.write "<html>"
          f.write "<head>"
          f.write "<meta http-equiv='content-type' content='text/html;charset=UTF-8' />"
          f.write "<meta http-equiv='Content-Type'
              content='text/css;
              charaset=UTF-8'>"
          f.write "<STYLE type=text/css>"
          f.write "<!--
                   body,table{color:全体の文字色;
                   font-size:文字の大きさpx}
                   a:link{color:全体のリンク色}
                   a:visited{color:訪問済みのリンク色}
                   a:hover{color:リンクを触れたときの色}
                   a:active{color:クリック中のリンク色}
                   -->"
                   
         f.write  ".title{
                   background: #FFFFFF;         
                   border: 8px outset #66CCCC;
                   color: #ff7f00;
                   font-size: 200%;
                   font-weight:900;
                   text-align:center;
                   height: 40px;
                   }

                   .gyouseki{
                   background: #ff7f00;
                   border: 2px ridge #66CCCC;
                   color: #FFFFFF;
                   font-weight:bold;
                   text-align:center;
                   height: 30px;
                   }

                   .term1{
                   background: #000000;
                   border: 2px ridge #66CCCC;
                   color: #00FFFF;
                   font-weight:bold;
                   text-align:center;
                   height: 30px;
                   }

                   .record1{
                   background: #000000;
                   border: 2px ridge #66CCCC;
                   color: #FFFF00;
                   text-align:right;
                   font-weight:bold;
                   height: 30px;
                   }

                   .zaimu{
                   background: #ff7f00;
                   border: 2px ridge #66CCCC;
                   color: #FFFFFF;
                   font-weight:bold;
                   text-align:center;
                   height: 30px;
                   }

                   .term2{
                   background: #000000;
                   border: 2px ridge #66CCCC;
                   color: #00FFFF;
                   font-weight:bold;
                   text-align:center;
                   height: 30px;
                   }

                   .record2{
                   background: #000000;
                   border: 2px ridge #66CCCC;
                   color: #FFFF00;
                   text-align:right;
                   font-weight:bold;
                   height: 30px;
                   }

                   .shihyou{
                   background: #ff7f00;
                   border: 2px ridge #66CCCC;
                   color: #FFFFFF;
                   font-weight:bold;
                   text-align:center;
                   height: 30px;
                   }

                   .term3{
                   background: #000000;
                   border: 2px ridge #66CCCC;
                   color: #00FFFF;
                   font-weight:bold;
                   text-align:center;
                   height: 30px;
                   }

                   .record3{
                   background: #000000;
                   border: 2px ridge #66CCCC;
                   color: #FFFF00;
                   text-align:right;
                   font-weight:bold;
                   height: 30px;
                   }

                   .yoshin{
                   background: #ff7f00;
                   border: 2px ridge #66CCCC;
                   color: #FFFFFF;
                   font-weight:bold;
                   text-align:center;
                   height: 30px;
                   }

                   .term4{
                   background: #000000;
                   border: 2px ridge #66CCCC;
                   color: #00FFFF;
                   font-weight:bold;
                   text-align:center;
                   height: 30px;
                   }

                   .record4{
                   background: #000000;
                   border: 2px ridge #66CCCC;
                   color: #FFFF00;
                   text-align:left;
                   font-weight:bold;
                   height: 30px;
                   }"
                   
           f.write "</STYLE>"
              #画面自動遷移処理（今回ドロップ）
             #f.write "<meta http-equiv='refresh'
              #content='8; url="+ @companyName.to_s + ".html'>"
              
         f.write "<body style='background-color: #c0c0c0; margin:0px;'> \n"
         
          f.write "<table align='center' cellspacing='0' cellpadding='0'> \n"              
            f.write "<tr> \n"
             f.write "<td width='300px'class='title'>" + @companyName.to_s + "\n"     
             f.write "</td> \n"              
             f.write "</tr> \n"              
           f.write "</table>\n"
           
             f.write "<br>" 
             
            f.write "<table align='center' cellspacing='0' cellpadding='0'> \n"                    
            f.write "<tr> \n"
            f.write "<td width='70px' class='gyouseki'>#{_('決算')}</td>" 
            f.write "<td width='350px' ></td>" 
            f.write "<td width='70px' class='gyouseki'>#{_('金額単位')}</td>\n"                 
            f.write "</tr> \n"
            f.write "<tr> \n"
            f.write "<td class='term1'>#{@s_or_c}</td>"
            f.write "<td width='350px'></td>" 
            f.write "<td class='term1'>#{@decimal}</td> \n"
            f.write "</tr> \n"
            f.write "</table>"
               
           f.write "<br>"                      


           f.write "<table  align='center' cellspacing='0' cellpadding='0'>"               
             f.write "<tr>"
              f.write "<td width='120px' class='gyouseki'>#{_("業績評価期")}</td>"
              f.write "<td width='100px' class='gyouseki'>#{_('売上高')}</td>"
              f.write "<td width='100px' class='gyouseki'>#{_('営業利益')}</td>"
              f.write "<td width='100px' class='gyouseki'>#{_('経常利益')}</td>"
              f.write "<td width='100px' class='gyouseki'>#{_('当期純利益')}</td>"
             f.write "</tr>"
              
             f.write "<tr>"
              f.write "<td class='term1'>#{_('今期')}</td>"
              f.write "<td class='record1'>#{@netSales3}</td>"
              f.write "<td class='record1'>#{@operatingIncome3}</td>"
              f.write "<td class='record1'>#{@ordinaryIncome3}</td>"
              f.write "<td class='record1'>#{@netIncome3}</td>"
             f.write "</tr>"

             f.write "<tr>"
              f.write "<td class='term1'>#{_('前期')}</td>"
              f.write "<td class='record1'>#{@netSales1}</td>"
              f.write "<td class='record1'>#{@operatingIncome1}</td>"
              f.write "<td class='record1'>#{@ordinaryIncome1}</td>"
              f.write "<td class='record1'>#{@netIncome1}</td>"
             f.write "</tr>"
           f.write "</table>"
           
           f.write "<br>"   

           f.write "<table  align='center' cellspacing='0' cellpadding='0'>"               
             f.write "<tr>"
              f.write "<td width='120px' class='gyouseki'>#{_('財務評価期')}</td>"
              f.write "<td width='100px' class='gyouseki'>#{_('総資産')}</td>"
              f.write "<td width='100px' class='gyouseki'>#{_('自己資本')}</td>"
              f.write "<td width='110px' class='gyouseki'>#{_('自己資本比率')}</td>"
              f.write "<td width='100px' class='gyouseki'>#{_('資本金')}</td>"
             f.write "</tr>"
              
             f.write "<tr>"
              f.write "<td class='term1'>#{_('今期')}</td>"
              f.write "<td class='record1'>#{@assets3}</td>"
              f.write "<td class='record1'>#{@netAssets3}</td>"
              f.write "<td class='record1'>#{@capitalAdequacyRatio}%</td>"
              f.write "<td class='record1'>#{@capitalStock3}</td>"                 
           f.write "</table>"
           
           f.write "<br>" 

           f.write "<table  align='center' cellspacing='0' cellpadding='0'>"                    
            f.write "<tr>"
              f.write "<td width='130px' class='gyouseki'>#{_('財務指標評価期')}</td>"                 
              f.write "<td width='100px' class='gyouseki'>#{_('利益余剰金')}</td>"                  
              f.write "<td width='150px' class='gyouseki'>ROE<br>#{_('株主資本利益率')}</td>" 
              f.write "<td width='150px' class='gyouseki'>ROA<br>#{_('総資産収益率')}</td>"
            f.write "</tr>"
              
            f.write "<tr>"
              f.write "<td class='term1'>#{_('今期')}</td>"
              f.write "<td class='record1'>#{@retainedEarnings3}</td>"
              f.write "<td class='record1'>#{@roe}%</td>"
              f.write "<td class='record1'>#{@roa}%</td>"
            f.write "</tr>"

           f.write "</table>"                                
         f.write "</body>"
        f.write "</html>"            
       }
    
     }
#    redirect_to :action => "index"
    end
  end
end