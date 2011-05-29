class RolesController < ApplicationController
  CLASS_NAME = self.name
  before_filter :check_administrator_role
  # GET /roles
  # GET /roles.xml
  def index
    aplog.debug("START #{CLASS_NAME}#index")
    @roles = Role.find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @roles }
    end
    aplog.debug("END   #{CLASS_NAME}#index")
  end

  # GET /roles/1
  # GET /roles/1.xml
  def show
    aplog.debug("START #{CLASS_NAME}#show")
    @role = Role.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
    aplog.debug("END   #{CLASS_NAME}#show")
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    aplog.debug("START #{CLASS_NAME}#new")
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
    aplog.debug("END   #{CLASS_NAME}#new")
  end

  # GET /roles/1/edit
  def edit
    aplog.debug("START #{CLASS_NAME}#edit")
    @role = Role.find(params[:id])
    aplog.debug("END   #{CLASS_NAME}#edit")
  end

  # POST /roles
  # POST /roles.xml
  def create
    aplog.debug("START #{CLASS_NAME}#create")
    @role = Role.new(params[:role])

    respond_to do |format|
      if @role.save
        notice("MSG_0x0000000D")
        format.html { redirect_to(@role) }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
    aplog.debug("END   #{CLASS_NAME}#create")
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    aplog.debug("START #{CLASS_NAME}#update")
    @role = Role.find(params[:id])
    respond_to do |format|
      if @role.update_attributes(params[:role])
        notice("MSG_0x0000000E")
        format.html { redirect_to(@role) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
    aplog.debug("END   #{CLASS_NAME}#update")
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    aplog.debug("START #{CLASS_NAME}#destroy")
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
    aplog.debug("END   #{CLASS_NAME}#destroy")
  end
end
