class EricWeixin::TemplateMessageLog < ActiveRecord::Base
  self.table_name = "weixin_template_message_logs"
  class << self
    #发送模板消息
    #参数说明：
    #    openid： 收取消息用户的openid， 必填
    #    template_id: 模板id， 必填
    #    data: 根据模板不同，给出不同的hash参数
    #    url: 点击模板要去的链接，可以为空
    #    topcolor: 颜色设置, 默认为 #FF0000
    #    app_id: 微信appid
    # EricWeixin::TemplateMessageLog.send_template_message openid: "osyUtswoeJ9d7p16RdpC5grOeukQ",
    #                                                      template_id: "WdYZPTwhAMc59aKGs5SUCxRw9xqOM-eOkvGJlZpQahk",
    #                                                      data: {
    #                                                          first: {value: 'xx'},
    #                                                          keyword1: {value: '王小明'},
    #                                                          keyword2: {value: '001-002-001'},
    #                                                          keyword3: {value: '陈小朋'},
    #                                                          keyword4: {value: '小明同学今天上课表现很别棒，很认真。手工都自己做的，依恋家长比较严重。'},
    #                                                          keyword5: {value: '总体来讲还很不错，心理上缺乏安全感，需要家长多陪同。'},
    #                                                          remark: {value: ''}
    #                                                      },
    #                                                      app_id: "wx4564afc37fac0ebf"
    def send_template_message options
      BusinessException.raise '没有接收对象' if options[:openid].blank?
      BusinessException.raise '模板未指定' if options[:template_id].blank?
      BusinessException.raise '数据未指定' if options[:data].blank?
      options[:topcolor] = '#FF0000' if options[:topcolor].blank?
      message_json = {
          :touser => options[:openid],
          :template_id => options[:template_id],
          :url => options[:url],
          :topcolor => options[:topcolor],
          :data => options[:data]
      }.to_json
      token = EricWeixin::AccessToken.get_valid_access_token(:weixin_secret_key => EricWeixin::PublicAccount.get_secret(options[:app_id]))
      response = RestClient.post "https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=#{token}", message_json
      response = JSON.parse response.body
      log = EricWeixin::TemplateMessageLog.new openid: options[:openid],
                                               url: options[:url],
                                               template_id: options[:template_id],
                                               topcolor: options[:topcolor],
                                               data: options[:data].to_json,
                                               message_id: response["msgid"],
                                               error_code: response["errcode"],
                                               app_id: options[:app_id]
      log.save!
    end

    def update_template_message_status openid, message_id, status
      log= EricWeixin::TemplateMessageLog.where openid: openid,
                                                message_id: message_id
      return if log.blank?
      log.status = status
      log.save!
    end
  end
end


