module ArchiveUtil
  class ZipUtil
    require 'rubygems'
    require 'zip/zipfilesystem'
    require 'find'
    require 'nkf'
    require 'fileutils'
    require 'zip/zip'

    def self.zip_file(zipFileName, folderPath)
      FileUtils.rm_rf File.dirname(zipFileName) if File.exist?(File.dirname(zipFileName))
      FileUtils.mkdir_p(File.dirname(zipFileName))
      Find.find(folderPath){|path|
        Zip::ZipFile.open(zipFileName, Zip::ZipFile::CREATE) {|zf|
        if File.basename(folderPath) != File.basename(path)
          zf.add(File.basename(folderPath) + "/" + path.sub(folderPath.gsub(/\\/,'/'),""), path)
        end     
        }
      }
    end
    
  # Import
    def self.unzip_file(zipFileName, folderPath)
      Zip::ZipFile.open(zipFileName) { |zip_file|
       zip_file.each { |f|
         f_path=File.join(folderPath, f.name)
#         FileUtils.rm_rf f_path if File.exist?(f_path)
         FileUtils.mkdir_p(File.dirname(f_path))
         zip_file.extract(f, f_path)
       }
      }
    end
  end
end
