class InsertAdminToYamlDbForms < ActiveRecord::Migration
  include SystemSettings
  
  def self.up
    # YAML  DBフォームのサンプル作成
    user = User.find_by_login("admin")
    YamlDbForm.make_sample_form(user, _("サンプル"),_("サンプルです。"), "#{YAML_DB_FORM_ROOT}/sample_form_01.yml", "100001")
    YamlDbForm.make_sample_form(user, _("業務報告"),_("業務報告用の入力フォームです。"), "#{YAML_DB_FORM_ROOT}/sample_form_03.yml", "100002")
    YamlDbForm.make_sample_form(user, _("TODOリスト"),_("TODOリスト用の入力フォームです。"), "#{YAML_DB_FORM_ROOT}/sample_form_04.yml", "100003")
    YamlDbForm.make_sample_form(user, _("TVアンケート"),_("VASDAQ.TVアンケート用の入力フォームです。"), "#{YAML_DB_FORM_ROOT}/sample_form_05.yml", "100004")
    YamlDbForm.make_sample_form(user, _("お問い合わせ"),_("お問い合わせ用の入力フォームです。"), "#{YAML_DB_FORM_ROOT}/sample_form_06.yml", "100005")
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
