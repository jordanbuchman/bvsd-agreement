#!/home/jason/.rvm/rubies/ruby-2.1.2/bin/ruby
require 'rubygems'
require 'mechanize'

begin
  Mechanize.new.get('http://example.com') do |page|
    if page.uri.to_s != "http://example.com/" # Check if redirected to the BVSD agreement
      login_form = page.form_with(name: "frmLogin")

      login_form.checkbox_with(id: "agree").check # Check checkbox to accept agreement
      button = login_form.button_with(value: "Continue")

      ### JavaScript on acceptance page: ###
      # function getQueryVariable(variable) {
      #   var query = window.location.search.substring(1);
      #   var vars = query.split("?");
      #   for (var i=0;i<vars.length;i++) {
      #     var pair = vars[i].split("=");
      #     if (pair[0] == variable) {
      #         if (pair[0] == "Qv") {
      #             return vars[i].substr(3, vars[i].length);
      #         }
      #         return pair[1];
      #     }
      #   }
      # }

      query_string = page.uri.query.split("&")
      hs_server = query_string[0][10..-1]
      qv = query_string[1][3..-1]

      login_form.field_with(id: "f_hs_server").value = hs_server
      login_form.field_with(id: "f_Qv").value = qv
      login_form.action = "http://#{hs_server}:880/cgi-bin/hslogin.cgi"

      logged_in_page = login_form.submit(button)

      puts "-- Agreement accepted! --"
    else
      puts "-- Already accepted! --"
    end
  end
rescue SocketError
  puts "-- Network unreachable, please connect to a network. --"
end
