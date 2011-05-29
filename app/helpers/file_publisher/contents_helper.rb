module FilePublisher::ContentsHelper
  def filepub_url_for(path, options={})
    url_for({
      :controller => 'file_publisher/contents',
      :action => 'index',
      :path => path.split('/').reject{|entry| entry.empty? }
    }.merge(options))
  end

  def filepub_link_to(name, path, html_options={})
    link_to(name, filepub_url_for(path), html_options)
  end

  def filepub_image_tag(path, html_options={})
    image_tag(filepub_url_for(path, :skip_relative_url_root => true), html_options)
  end

  def filepub_include_file(path)
    filepub_root = FilePublisher.config[:root]
    File.open(File.expand_path(path, filepub_root), 'rb', &:read)
  end
end
