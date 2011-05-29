class YamlDbForm < ActiveRecord::Base
  belongs_to :user
  cattr_accessor :aplog
  @@aplog ||= SystemSettings::APL_LOGGER
  CLASS_NAME = self.name
  
  def self.make_sample_form(user, name, desc, file_path, yaml_db_form_id=nil)
    aplog.debug("START #{CLASS_NAME}#make_sample_form")
    if(yaml_db_form_id.nil?)
      yaml_form = YamlDbForm.new
    else
      yaml_form = YamlDbForm.new do |y|
        y.id = yaml_db_form_id
      end
    end
    yaml_form[:user_id] = user.id
    file_name = File::basename(file_path)
    path = RuntimeSystem::yaml_db_form_sample_file_name(user, file_name)
    yaml_form[:file_path] = path
    yaml_form[:form_name] = name
    yaml_form[:form_desc] = desc
    yaml_form.save!
    FileUtils.copy_file(file_path, path)
    aplog.debug("END   #{CLASS_NAME}#make_sample_form")
  end

end
