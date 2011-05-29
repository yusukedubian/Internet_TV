require 'rubygems'
require 'fileutils'


module RuntimeSystem
  class StoreYamlAsJson
    def execute(content, current_user)
      @content = content
      @current_user = current_user
      return if !@config = content.runtime_config_mail
     
      begin
        mail = @current_user.runtime_data_mails.find(:last, :conditions => {:subject => @config.subject}, :order => "send_date")
        FileUtils.mkdir_p(RuntimeSystem.content_save_dir(@content))
        File.open(FileUtils.mkdir_p(RuntimeSystem.content_save_dir(@content))+ "/"+ @content.id.to_s  + ".json", "w") do |file|
          file.write(YAML.load(mail.body).to_json)
        end
      rescue
      end
    end
  end
end
