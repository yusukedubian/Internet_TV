require 'rubygems'
require 'fileutils'


module RuntimeSystem
  class StoreGraphYamlAsJson
    def execute(content, current_user)
      @content = content
      @current_user = current_user
      return if !@config = content.runtime_config_mail
     
      begin
        mail = @current_user.runtime_data_mails.find(:last, :conditions => {:subject => @config.subject}, :order => "send_date")
        FileUtils.mkdir_p(RuntimeSystem.content_save_dir(@content))
        File.open(FileUtils.mkdir_p(RuntimeSystem.content_save_dir(@content))+ "/"+ @content.id.to_s  + ".json", "w") do |file|
          file.write(construct_graph_data( YAML.load(mail.body).with_indifferent_access ).to_json)
        end
      rescue
      end
    end

    private

    def construct_graph_data(data)
      @content_properties = @content.contents_propertiess.inject({}) do |result, property|
        result.store property[:property_key], property[:property_value].to_s.delete("\n")
        result
      end.with_indifferent_access
      
      case @content_properties[:renderer]
      when "bar"
        construct_bar_data(data)
      when "pie"
        construct_pie_data(data)
      when "line"
        construct_line_data(data)
      end
    end

    def construct_pie_data(data)
      {
        :data => [extract_entries_with_label(data[:entries])],
        :options_code => extract_common_format(data[:format])
      }
    end

    def construct_bar_data(data)
      axes = {
        "seriesDefaults" => {
          "rendererOptions" => { "barPadding" => 8, "barMargin" => 20}
        },
        "axes" => {
          "xaxis" => extract_ticks_str(data[:format][:ticks]),
          "yaxis" => { "min" => 0 }
        }
      }
      {
        :data => extract_entries(data[:entries]),
        :options_code => axes.merge(extract_series(data)).merge(extract_common_format(data[:format]))
      }
    end

    def construct_line_data(data)
      {
        :data => extract_entries(data[:entries]),
        :options_code => extract_series(data).merge(extract_common_format(data[:format]))
      }
    end

    def extract_common_format(format)
      title_setting = {"title" => @content_properties[:title] }
      format.inject(title_setting) do |result, ent|
        key, val = ent
        case key
        when "legend"
          result["legend"] = { "show" => true, "location" => val }
        end
        result
      end
    end

    def extract_series(data)
      labels = data[:entries].inject([]) do |result, ent|
        result << { "label" => ent[:label] }
      end
      {"series" => labels }
    end
    
    def extract_entries_with_label(entries, first_entry_only=true)
      entries.inject([]) do |result, ent|
        if first_entry_only
          result << [ent[:label], [ent[:data].first]].flatten
        else
          result << [ent[:label], ent[:data]]
        end
      end
    end

    def extract_entries(entries)
      entries.inject([]) do |result, ent|
        result << ent[:data]
      end
    end

    def extract_ticks_str(ticks)
      { "ticks" => ticks }
    end
  end
end
