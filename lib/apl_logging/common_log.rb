module CommonLog
  
  def request_log
    aplog.info "Processing #{self.class.name}\##{action_name} (for #{request_origin}) [#{request.method.to_s.upcase}]"
    aplog.info "Session ID: #{@_session.session_id}" if @_session and @_session.respond_to?(:session_id)
    aplog.info "Parameters: #{respond_to?(:filter_parameters) ? filter_parameters(params).inspect : params.inspect}"
  end
  
  
  def redirect_log(options = {}, response_status = {})
    aplog.info("Redirected to #{options}") if aplog && aplog.info?
  end
  
  
  def render_log(options = nil, extra_options = {}, &block)
    template_path = ""
    if options.nil?
      template_path = default_template_name
      status = ""
    elsif options[:template]
      template_path = options[:template]
      status = options[:status]
    elsif options[:file]
      template_path = options[:file]
      status = options[:status]
    else
      template_path = default_template_name
      status = ""
    end
    aplog.info("Rendering #{template_path}" + (status ? " (#{status})" : '')) if aplog
  end
  
  
  
  def error_log(exception)
    
    borderline = "\n--------------------------------------------------------------------\n\n"
    
    detail = "\n\n"+exception.class.name + "(" + exception.message + ")\n    "+ 
                 exception.backtrace.join("\n    ")
    
    if exception.kind_of?(NoMemoryError)
      
      detail << borderline
      aplog.fatal("NoMemoryErrorを検出しました")
      aplerr.fatal(detail)
      
    elsif exception.kind_of?(ActionController::RoutingError)
      
      aplog.warn("無効なURLへアクセスされました。")
      
    elsif exception.kind_of?(BaseSystemException)
      
      if !exception.cause.nil?
        detail << "\n\n原因詳細 :\n"+ 
                      exception.cause.message + "\n" +
                      exception.cause.backtrace.join("\n    ")
      end
      detail << borderline
      aplog.error(exception.message)
      aplerr.error(detail)
      
    else
      detail << borderline
      aplog.error(exception.message)
      aplerr.error(detail)
    end
    
  end
  
end
