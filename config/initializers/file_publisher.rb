module FilePublisher
  Config = {
    :root => File.join(RAILS_ROOT, 'users_contents'),
    :index_file => %w(index.html index.htm),
    :nondisclosure_name => /\A(\.ht.*|.*\.cgi|.*\.fcgi|\.svn|CVS)\z/i
  }.with_indifferent_access

  class <<self
    def load_config(hash)
      hash = hash.with_indifferent_access
      hash[:root] = File.expand_path(hash[:root], RAILS_ROOT)
      if hash[:nondisclosure_name]
        hash[:nondisclosure_name] = Regexp.union(config[:nondisclosure_name], hash[:nondisclosure_name])
      end
      Config.update(hash)
    end

    def config
      Config
    end
  end
end
