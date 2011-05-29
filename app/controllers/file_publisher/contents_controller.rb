class FilePublisher::ContentsController < ApplicationController
#  before_filter :login_required
  before_filter :check_contents_root
  before_filter :check_path_name
  before_filter :check_disclosure
  before_filter :auth_check
  def index
    if File.file?(@full_path)
      if /\/\z/ =~ request.path
        send_not_found
      else
        send_file_content(@full_path)
      end
    elsif File.directory?(@full_path)
      if /\/\z/ =~ request.path
        send_directory_index
      else
        path = (root_path == "/" ? "" : root_path) + request.path
        redirect_to(File.expand_path(path) + "/")
      end
    else
      send_not_found
    end
  end

  private

  def root_path
    url_for :controller => '/', :only_path => true
  end

  # filters
  def check_contents_root
    unless File.directory?(contents_root)
      logger.fatal("Fatal error: #{contents_root} must exist.")
      send_not_found
    end
  end

  def check_path_name
    path = params[:path].join("/")
    @full_path = File.expand_path(contents_root + "/" +path)
    unless /\A#{contents_root}(?:\/|\z)/ =~ @full_path
      send_not_found
    end
  end

  def check_disclosure
    if params[:path].any? {|name| name =~ config[:nondisclosure_name] }
      send_not_found
    end
  end

  # utilities to make response
  def contents_root
    config[:root]
  end
    
  def send_not_found
    render_optional_error_file(404)
  end

  def send_directory_index
    indices = config[:index_file]
    indices.each do |index|
      index_path = File.join(@full_path, index)
      if File.file?(index_path)
        send_file_content(index_path)
        return
      end
    end
    send_not_found
  end

  def send_file_content(path)
    send_content(FilePublisher::FileContent.new(path))
  end

  def send_content(content)
    unless content_is_modified?(content)
      send_data "",
        :status=>"304 Not Modified",
        :type=>content.content_type,
        :disposition=>"inline"
      return
    end
    headers["Last-Modified"] = content.last_modified.httpdate
    headers["Etag"] = content.etag
    send_data content.data, :type=>content.content_type, :disposition=>"inline"
  end

  def content_is_modified?(content)
    tag = request.env["HTTP_IF_NONE_MATCH"]
    ims = request.env["HTTP_IF_MODIFIED_SINCE"]
    if tag && tag == content.etag
      return false
    elsif ims && Time.parse(ims) >= content.last_modified
      return false
    end
    return true
  end

  def config
    FilePublisher.config
  end
  
  def auth_check
    if !(User.find(params[:path][1]) && User.find(params[:path][1]).channels.find_by_channel_no(params[:path][2]))
      send_not_found
      return
    end
    send_not_found if !((User.find(params[:path][1]).channels.find_by_channel_no(params[:path][2]).public_flag == 1) || (params[:path][1] == current_user.id.to_s))
  end
end
