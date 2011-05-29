class TemplatePagesController < ApplicationController
  before_filter :find_pages
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    aplog.debug("END   #{CLASS_NAME}#index")
  end
  require 'fileutils'
  def show
    aplog.debug("START #{CLASS_NAME}#show")
    @cont = @page.contents.find(:all,:conditions=>["page_id=?",@page.id])
    @cont.each do |control|
      @contpro = @page.contents.find(control.id).contents_propertiess.find(:all)
      @contpro.each do |contpro|
        contpro.destroy  
      end
      control.destroy
    end  
    @tcontent = TemplateContent.find(:all,:conditions=>["template_page_id=?",params[:id]])      
    @tcontent.each do |tcontrol|
      content = Content.new
      content.player_id = tcontrol.player_id
      content.page_id = @page.id
      content.width = tcontrol.width
      content.height = tcontrol.height
      content.x_pos = tcontrol.x_pos
      content.y_pos = tcontrol.y_pos
      content.save

      @tcontpro = TemplateContentProperty.find(:all,:conditions=>["template_content_id=?",tcontrol.id])
      @tcontpro.each do |tcontpro|
        contpro = ContentsProperties.new
        contpro.content_id = content.id
        contpro.property_key = tcontpro.property_key
        contpro.property_value = tcontpro.property_value
        contpro.save
      end
    end
    tcon = @page.contents.find(:all,:conditions=>["page_id=?",@page.id],:order=>"id DESC")

    if params[:id] == "1" || params[:id] == "2" || params[:id] == "4" || params[:id] == "6"
      i = 3
    end
    if params[:id] == "3" || params[:id] == "5" 
      i = 4
    end
    if params[:id] == "7" 
      i = 5
    end
    tcon.each{|t|
      FileUtils.mkdir_p(RuntimeSystem.content_save_dir(t))
       tt =TemplateContent.find(:all,:conditions=>["template_page_id=?",params[:id]])
       #p RuntimeSystem.template_content_save_dir(tt[0+i])
       path = RuntimeSystem.template_content_save_dir(tt[0+i])+'*'
       FileUtils.cp(Dir.glob(path),RuntimeSystem.content_save_dir(t))
       i=i-1
     }
     
    @page.background = nil
    @page.backgroundfile = "background.gif"
    @page.background_display_type = 0
    @page.save
    
    FileUtils.cp("users_contents/template/"+params[:id]+"/background.gif",RuntimeSystem.page_save_dir(@page))
     
    # プレビュー画面を作ります
    @channel = current_user.channels.find_by_id(params[:channel_id])
    PagesController.make_page(@channel,@page)
    redirect_to edit_channel_page_path(params[:channel_id],params[:page_id] )
    aplog.debug("END   #{CLASS_NAME}#show")
  end
  
  private
  def find_pages
    aplog.debug("START #{CLASS_NAME}#find_pages")
    @page = current_user.channels.find_by_id(params[:channel_id]).pages.find_by_id(params[:page_id])
    aplog.debug("END   #{CLASS_NAME}#find_pages")
  end
end
