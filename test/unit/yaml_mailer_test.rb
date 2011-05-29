require 'test_helper'

class YamlMailerTest < ActionMailer::TestCase
  tests YamlMailer
  def test_send
    @expected.subject = 'YamlMailer#send'
    @expected.body    = read_fixture('send')
    @expected.date    = Time.now

    assert_equal @expected.encoded, YamlMailer.create_send(@expected.date).encoded
  end

end
