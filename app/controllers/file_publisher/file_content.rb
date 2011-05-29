class FilePublisher::FileContent
  def initialize(path)
    @path = path
    @stat = File.stat(path)
  end

  def etag
    return "%x-%x-%x" % [@stat.ino, @stat.size, @stat.mtime.to_i]
  end

  def last_modified
    return @stat.mtime
  end

  def content_type
    ext = File.extname(@path)
    return Mime::Type.lookup_by_extension(ext.delete(".")) || 'application/octet-stream'
  end

  def data
    #return File.read(@path)
    return File.open(@path, "rb").read()
  end
end
