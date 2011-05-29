class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :user_id
      t.integer :role_id

      t.timestamps
    end
     Role.create(:name => 'administrator')
    #Then, add default admin user
    #Be sure change the password later or in this migration file
    user = User.new
    user.login = "admin"
    user.email = "--ADMIN_NAME--@gmail.com"
    user.user_name = "admin"
    user.password = "admin"
    user.password_confirmation = "admin"
#    user.enabled = true
    user.save(false)
    user.send(:activate)
    role = Role.find_by_name('administrator')
    user = User.find_by_login('admin')
    permission = Permission.new
    permission.role = role
    permission.user = user
    
    role1 = Role.create(:name => 'user1')
    permission.save(false)

  end

  def self.down
    drop_table :permissions
    Role.find_by_rolename('administrator').destroy   
    User.find_by_login('admin').destroy   

  end
end
