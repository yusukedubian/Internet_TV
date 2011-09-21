# Author::    N.O
# Copyright:: Copyright (c) 2010 VASDAQ Group All Rights Recieved
# License::   GPL

# チャンネルコントローラー
class ChannelsController < ApplicationController
  CLASS_NAME = self.name
  before_filter :login_required
  before_filter :find_users
  include Validate
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    #@channels = @user.channels.find(:all, :order => "channel_no")
    begin
      #channel = current_user.channels.find_by_channel_no(1)
      if !channel = current_user.channels.find_by_channel_no(1)
        #new user
        #make channel data
        channel = Channel.new(:name=>"default",:channel_no => 1, :background =>"#cfcfcf", :width=>"800", :height=>"600")
        current_user.channels << channel
        mypage = Mypage.new(:channel_id => channel.id)
        current_user.mypages << mypage
        
        #make page data
        page = Page.new(:name=>"page1", :page_no => 1,:switchtime =>60,:background_display_type=>2)
        channel.pages << page
        current_user.save!
        
        #make backimage
        extension =  File.extname("1_1024_768.png")
        storefilename = "gallary" + extension
        galleryimage = RuntimeSystem.image_gallery_save_dir(page,"1_1024_768.png")
        path = RuntimeSystem.page_save_dir(page)
        FileUtils.mkdir_p(path)
        original = File.open(galleryimage, "rb")
        copy = File.open(path+"#{storefilename}", "wb")
        copy.write(original.read)
  
        page.background = nil
        page.backgroundfile = storefilename
        if page.background_display_type == nil
          page.background_display_type = "0"
        end
        page.save
         
        #make playercopy record
        copy_record = CopyContent.new(:channel_id=>channel.id)
        channel.copy_contents << copy_record
        copy_record.save
        
        #make copy folder
        user_contents_path = RuntimeSystem.channel_save_dir(channel)
        FileUtils.mkdir_p(user_contents_path+"copy_receive")
        FileUtils.mkdir_p(user_contents_path+"zipsave")
        
        redirect_to edit_channel_page_path(channel.id,  page)
      else
        channel = current_user.channels.find_by_channel_no(1)
        if !page = channel.pages.find_by_page_no(1)
          page = Page.new(:name=>"page1", :page_no => 1,:switchtime =>60,:background_display_type=>2)
          channel.pages << page
          current_user.save!
          
          #make backimage
          extension =  File.extname("1_1024_768.png")
          storefilename = "gallary" + extension
          galleryimage = RuntimeSystem.image_gallery_save_dir(page,"1_1024_768.png")
          path = RuntimeSystem.page_save_dir(page)
          FileUtils.mkdir_p(path)
          original = File.open(galleryimage, "rb")
          copy = File.open(path+"#{storefilename}", "wb")
          copy.write(original.read)
    
          page.background = nil
          page.backgroundfile = storefilename
          if page.background_display_type == nil
            page.background_display_type = "0"
          end
          page.save
        end
        
        redirect_to edit_channel_page_path(channel.id,  page)
      end
    rescue AplInfomationException => e
      alert("ERR_0x01010301")
      redirect_to channels_path
      return
    end
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  
  # チャンネル情報更新
  # RequestParameter
  #  - :id               チャンネルID
  #  - channel_propertie
  #    - name            チャンネル名
  #    - background      背景色
  #    - category        カテゴリ
  #    - width           ディスプレイ横幅
  #    - height          ディスプレイ縦幅
  #    - thumbnailfile   サムネイル
  # DisplayVariable
  #    @channel      チャンネルオブジェクト
  #    @channels     チャンネルオブジェクトリスト
  #    @channelstype チャンネルタイプオブジェクトレコード
  # Param::  
  # Return::
  def edit
    aplog.debug("START #{CLASS_NAME}#edit")
    #Through edit
    redirect_to channels_path
    #Through edit
    begin
      @channel = current_user.channels.find(params[:id])
      @channels = @user.channels.find(:all, :include=>:pages, :order => "channel_no")
      @channelstype = @user.channels.find(:all, :conditions =>["channel_no=?",@channel.channel_no])
    rescue ActiveRecord::RecordNotFound
      alert("ERR_0x01010302")
      redirect_to channels_path
    end
    aplog.debug("END   #{CLASS_NAME}#edit")
  end
  
  def new
    aplog.debug("START #{CLASS_NAME}#new")
    begin
      @channels = @user.channels.find(:all, :order => "channel_no")
      if !channel = current_user.channels.find_by_channel_no(params[:channel_no])
        channel = Channel.new(:channel_no => params[:channel_no], :background =>"#123456")
        current_user.channels << channel
        mypage = Mypage.new(:channel_id => channel.id)
        current_user.mypages << mypage
        current_user.save!
      end
      redirect_to edit_channel_path(channel)
      aplog.debug("END   #{CLASS_NAME}#new")
      return
    rescue
      alert("ERR_0x01010301")
      redirect_to channels_path
      aplog.debug("END   #{CLASS_NAME}#new")
      return
    end
    aplog.debug("END   #{CLASS_NAME}#new")
  end

  # チャンネル情報更新
  # RequestParameter
  #  - :id               チャンネルID
  #  - channel_propertie
  #    - name            チャンネル名
  #    - background      背景色
  #    - category        カテゴリ
  #    - width           ディスプレイ横幅
  #    - height          ディスプレイ縦幅
  #    - thumbnailfile   サムネイル
  # DisplayVariable
  #  なし
  # Param::  
  # Return:: @user(個別のユーザー情報)
  def update
    aplog.debug("START #{CLASS_NAME}#update")
    channel = current_user.channels.find(params[:id])
    prmChannel = params["channel_propertie"]
    # uploadfile get
    file_obj = prmChannel["thumbnailfile"]

    begin
      if ! check_length(prmChannel["name"], 40, Compare::LESS_THAN)
        raise "ERR_0x01010304"  
      end
      if ! check_length(prmChannel["category"], 40, Compare::LESS_THAN)
        raise "ERR_0x01010305"  
      end
      if ! check_length(prmChannel["description"], 1024, Compare::LESS_THAN)
        raise "ERR_0x01010306"  
      end
      if ! check_length(prmChannel["link_info"], 256, Compare::LESS_THAN)
        raise "ERR_0x01010307"  
      end
      if ! check_length(prmChannel["other_info"], 256, Compare::LESS_THAN)
        raise "ERR_0x01010308"  
      end
      if is_empty(prmChannel["name"])
        raise "ERR_0x01020401"
      end
      if !is_color_code(prmChannel["background"])
        raise "ERR_0x01025106"
      end
      if is_empty(prmChannel["width"])
        raise "ERR_0x01020402"
      elsif !is_half_num(prmChannel["width"])
        raise "ERR_0x01020403"
      if is_empty(prmChannel["height"])
        raise "ERR_0x01020404"
      elsif !is_half_num(prmChannel["height"])
        raise "ERR_0x01020405"
      elsif !(prmChannel["width"].to_i >= 1 && prmChannel["width"].to_i <= 999999)
        raise "ERR_0x01020406"
      end
      elsif !(prmChannel["height"].to_i >= 1 && prmChannel["height"].to_i <= 999999)
        raise "ERR_0x01020407"
      end
      
      prmChannel.delete("thumbnailfile")
      channel.update_attributes(prmChannel)
      channel.create_type = 1 # 1:original
      if !file_obj.nil? && !file_obj.blank?
        extname = File.extname(file_obj.original_filename)
        RuntimeSystem.get_upload_file(channel, file_obj, "thumbnail"+extname)
        channel.thumbnail_filename = "thumbnail" + extname
      end
      if channel.save!
        notice("MSG_0x00000009")
      end
    rescue => e
      alert(e.message)
      if !flash[:alert]
        alert("ERR_0x01010303")
      end
    end
    page = channel.pages.find(params[:page])
    redirect_to edit_channel_page_path(params[:id],page)
    aplog.debug("END   #{CLASS_NAME}#new")
  end
  
  def destroy
    aplog.debug("START #{CLASS_NAME}#destroy")
    pages = Page.find(params[:id])
    Channel.destroy(pages.channel_id) if current_user.channels.find(:first, pages.channel_id)
    redirect_to channels_path
    aplog.debug("END   #{CLASS_NAME}#destroy")
  end
  
  def download
    aplog.debug("START #{CLASS_NAME}#download")
    channel = @user.channels.find(params[:id])
    p pages = channel.pages.find(:all)
    p pages.length
    fewfew
    channel_no = channel.channel_no.to_s
    send_dir = RuntimeSystem.send_client_channel_save_dir(channel)
    file_dir = RuntimeSystem.channel_save_dir(channel)
    zip_dir = send_dir + "download_ch" + channel_no + ".zip"
    test = ArchiveUtil::ZipUtil.zip_file(zip_dir,file_dir)
#    test.zip_file
    send_file(zip_dir)
    aplog.debug("END   #{CLASS_NAME}#download")
  end

  def upload
    aplog.debug("START #{CLASS_NAME}#upload")
    begin
      channel = @user.channels.find(params[:id])
      file = params["channel_zip_upload"]["zipfile_path"]
      #tmpフォルダのpath
      recieve_channel_path = RuntimeSystem.recieve_client_channel_save_dir(channel)
      #users_contentsフォルダのpath
      user_contents_path = RuntimeSystem.channel_save_dir(channel)
      #直前のuploaded_flagを取得
      channel_uploaded_flg = channel.uploaded_flg
      ActiveRecord::Base.transaction do
        #zipファイルが選択されたかどうか？
        raise "ERR_0x01010304" if file.blank?
        #ファイルアップロードフラグチェック
        raise "ERR_0x01010305" if !channel_uploaded_flg
        #ページ情報が消されているかどうか
        raise "ERR_0x01010305" if !channel.pages.empty?
        #zipファイルかどうかのチェック
        raise "ERR_0x01010306" if !file.content_type == "application/zip"
        channel.uploaded_flg = false
        #tmpにファイルを作成する前にclear
        FileUtils.rm_rf(recieve_channel_path)
      end
      ActiveRecord::Base.transaction do
        #zipファイル保存フォルダ作成
        FileUtils.mkdir_p(recieve_channel_path)
        #tmpフォルダへのzipファイルの書き込み
        File.open(recieve_channel_path + file.original_filename,"wb"){|f|
          f.write(file.read) 
        }
        #zipファイルの展開
        zipfile = ArchiveUtil::ZipUtil.unzip_file(recieve_channel_path + file.original_filename, recieve_channel_path)
        #zipファイルの削除
        FileUtils.rm(recieve_channel_path + file.original_filename)
        
        #解凍後のチェック
        #zipファイルサイズチェック 10M以内
        raise "ERR_0x01010307" if user_contents_dir_size_check(recieve_channel_path) > 10.megabytes
        #解凍後のディレクトリのコピーの準備
        count = 0
        ##2階層目のパス
        paths = []
        ##パスの確認
        Dir.open(recieve_channel_path).each{|dirPath|
          next if dirPath == "." || dirPath == ".."
          #ディレクトリチェック用
          dir_flg = false
          Dir.open(File.join(recieve_channel_path, dirPath)).each{|dirPaths|
          next if dirPaths == "." || dirPaths == ".."
            paths << path = File.join(recieve_channel_path, dirPath, dirPaths)
            if dir_flg = FileTest.directory?(path)
                raise "ERR_0x01010308" if !user_contents_dir_check(path)
                raise "ERR_0x01010309" if !is_half_num(dirPaths)
                raise "ERR_0x01010308" if (dirPaths.to_s > 1.to_s && dirPaths.to_s < 12.to_s)
            end
          }
          
          count += 1
          raise "ERR_0x01010308" if dir_flg && (count >= 2)
        }
        
        #ページテーブルへのデータ追加
        paths.each{|path|
          page_no = File.basename(path)
          page = Page.new(:page_no => page_no)
          channel.pages << page
        }
        #チャンネルのフォルダ作成
        FileUtils.mkdir_p(user_contents_path)
        #解凍したフォルダのコピー    
        FileUtils.cp_r(paths, user_contents_path)
        #tmpzipファイル削除
        FileUtils.rm_rf(recieve_channel_path)
  
        channel.save!
            notice("MSG_0x00000015")
      end
    rescue => e
      FileUtils.rm_rf(recieve_channel_path)
      channel.uploaded_flg = channel_uploaded_flg
      alert(e.message)
    end
    #チェックしたディレクトリ構成を画面に表示
    redirect_to edit_channel_path(channel)
    aplog.debug("END   #{CLASS_NAME}#upload")
  end
  
  def clear
    aplog.debug("START #{CLASS_NAME}#clear")
    begin
      channel = @user.channels.find(params[:id])
      #アップロードフラグが立っているかどうかのチェック
      raise "ERR_0x0101030A" if channel.uploaded_flg
      channel.pages.destroy_all
      channel.uploaded_flg = true
      channel.save!
      notice("MSG_0x00000016")
    rescue => e
      alert(e.message)
    end
    redirect_to edit_channel_path(channel)
    aplog.debug("END   #{CLASS_NAME}#upload")
  end
  
  def taggings
    aplog.debug("START #{CLASS_NAME}#taggings")
    @obj = Channel.find(params[:id])
    aplog.debug("END   #{CLASS_NAME}#taggings")
  end
  
  protected
  def find_users
    @user = User.find(:first, :include=>:channels, :conditions=> ["users.id = ?", current_user.id])
  end
  
  #アップロードファイルのサイズチェック（解凍後）
  def user_contents_dir_size_check(file_path)
    aplog.debug("START #{CLASS_NAME}#user_contents_dir_size_check")
    s = file_path + "/**/*"
    size = 0
    Dir.glob(s).each{|file|
      next if File.directory?(file)
       size += File.size?(file)       
    }
    aplog.debug("END   #{CLASS_NAME}#user_contents_dir_size_check")
    return size
  end
  
  #user_contentsディレクトリチェック
  def user_contents_dir_check(path)
    aplog.debug("START #{CLASS_NAME}#user_contents_dir_check")
    flg = false
    Dir.open(path).each{|dirPath|
    next if dirPath == "." || dirPath == ".."
      dirPath == "preview.html"
      flg = true if dirPath == "preview.html"
    }
    aplog.debug("END   #{CLASS_NAME}#user_contents_dir_check")
    return flg
  end
end
