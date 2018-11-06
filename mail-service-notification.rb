#!/usr/bin/env ruby

=begin
**********************************************************************
* Author            : Lasse Wackers
*
* Date created      : 20180927
*
* Purpose           : This script sends service-notifications via E-Mail to the specified users.
*                     This script use Environment variables with information about the service which are filled by icinga2.
*                     You have to use erb files to change the content of your mails.
*
* License           : GPL
*
**********************************************************************
=end

require 'optparse'
require 'logger'
require 'erb'
require 'net/smtp'

begin
  # Logger Options
  ## Loading logging API
  LOG_PATH = "/var/log/icinga2_notifications.log"
  @logger = Logger.new(LOG_PATH)
  @logger.level = Logger::DEBUG

  # Mailing Options
  mailserver = "localhost"

  # @param mailserver String
  # @param smtp SMTP Object
  # @param from String
  # @param to String or Array of Strings
  # @param cc String or Array of Strings or NilClass
  # @param mail_message String
  # @return NilClass
  def send_mail(mailserver, smtp, from, to, cc=nil, mail_message)
    @from = from
    @to = to
    @cc = cc
    @mail_message = mail_message

    smtp.start mailserver
    smtp.mailfrom @from

    @to = [@to] if @to.class == String
    @cc = [] if !defined?(@cc) or @cc.class == NilClass
    @cc = [@cc] if @cc.class == String
    (@to+@cc).map do |addr|
      smtp.rcptto addr
    end

    smtp.data @mail_message
    smtp.finish
  end

  ## Get all options from Environment Variables
  options = Hash.new
  options["date"] = ENV["LONGDATETIME"]
  options["hostname"] = ENV["HOSTNAME"]
  options["hostdisplayname"] = ENV["HOSTDISPLAYNAME"]
  options["hostoutput"] = ENV["HOSTOUTPUT"]
  options["usermail"] = ENV["USEREMAIL"]
  options["hoststate"] = ENV["HOSTSTATE"]
  options["notificationtype"] = ENV["NOTIFICATIONTYPE"]

  options["hostaddress"] = ENV["HOSTADDRESS"]
  options["hostaddress6"] = ENV["HOSTADDRESS6"]
  options["notificationauthorname"] = ENV["NOTIFICATIONAUTHORNAME"]
  options["notificationcomment"] = ENV["NOTIFICATIONCOMMENT"]
  options["icingaweb2url"] = ENV["ICINGAWEB2URL"]
  options["mailfrom"] = ENV["MAILFROM"]
  options["extrainformation"] = Array.new

  @logger.debug(ARGV)

  ## Overwrite options with argument options
  optparser = OptionParser.new do |option|
    option.banner = "Usage: #{__FILE__}"
    option.separator 'Required parameters:
    -d LONGDATETIME (\$icinga.long_date_time\$)
    -e SERVICENAME (\$service.name\$)
    -l HOSTNAME (\$host.name\$)
    -n HOSTDISPLAYNAME (\$host.display_name\$)
    -o SERVICEOUTPUT (\$service.output\$)
    -r USEREMAIL (\$user.email\$)
    -s SERVICESTATE (\$service.state\$)
    -t NOTIFICATIONTYPE (\$notification.type\$)
    -u SERVICEDISPLAYNAME (\$service.display_name\$)
    -T Template File

  Optional parameters:
    -4 HOSTADDRESS (\$address\$)
    -6 HOSTADDRESS6 (\$address6\$)
    -b NOTIFICATIONAUTHORNAME (\$notification.author\$)
    -c NOTIFICATIONCOMMENT (\$notification.comment\$)
    -i ICINGAWEB2URL (\$notification_icingaweb2url\$, Default: unset)
    -f MAILFROM (\$notification_mailfrom\$, requires GNU mailutils (Debian/Ubuntu) or mailx (RHEL/SUSE))
    -E Extra Information
    -v (\$notification_sendtosyslog\$, Default: false)'
    option.on('-d', '--date=DATE') do |date|
      options["date"] = date
    end
    option.on('-e', '--servicename=SERVICENAME') do |servicename|
      options["servicename"] = servicename
    end
    option.on('-l', '--hostname=HOSTNAME') do |hostname|
      options["hostname"] = hostname
    end
    option.on('-n', '--hostdisplayname=HOSTDISPLAYNAME') do |hostdisplayname|
      options["hostdisplayname"] = hostdisplayname
    end
    option.on('-o', '--serviceoutput=SERVICEOUTPUT') do |serviceoutput|
      options["serviceoutput"] = serviceoutput
    end
    option.on('-r', '--usermail=USEREMAIL') do |usermail|
      options["usermail"] = usermail
    end
    option.on('-s', '--servicestate=SERVICESTATE') do |servicestate|
      options["servicestate"] = servicestate
    end
    option.on('-t', '--notificationtype=NOTIFICATIONTYPE') do |notificationtype|
      options["notificationtype"] = notificationtype
    end
    option.on('-u', '--servicedisplayname=SERVICEDISPLAYNAME') do |servicedisplayname|
      options["servicedisplayname"] = servicedisplayname
    end
    option.on('-f', '--mailfrom=MAILFROM') do |mailfrom|
      options["mailfrom"] = mailfrom
    end
    option.on('-4', '--address=ADDRESS') do |address|
      options["address"] = address
    end
    option.on('-6', '--address6=ADDRESS') do |address6|
      options["address6"] = address6
    end
    option.on('-b', '--author=AUTHOR') do |author|
      options["author"] = author
    end
    option.on('-c', '--comment=COMMENT') do |comment|
      options["comment"] = comment
    end
    option.on('-i', '--icingaweb2url=ICINGAWEB2URL') do |icingaweb2url|
      options["icingaweb2url"] = icingaweb2url
    end
    option.on('-E', '--extrainformation=EXTRAINFORMATION') do |extrainformation|
      options["extrainformation"] << extrainformation.strip.chomp
    end
    option.on('-v', '--log=LOG') do |log|
      options["log"] = log
    end
    option.on('-T', '--templatefile=TEMPLATEFILE') do |templatefile|
      options["templatefile"] = templatefile
      unless File.exist?(templatefile)
        msg = "Templatefile #{templatefile} does not exist"
        @logger.fatal(msg) unless defined?(options["log"])
        abort(msg)
      end
    end
  end.parse!

  @logger.debug(options)

  ## Check required options
  required_options = ["date","servicename","hostname","hostdisplayname","serviceoutput","usermail","servicestate","notificationtype","servicedisplayname","templatefile"]
  required_options.each do |option|
    if options[option].class == NilClass
      msg = "Require option #{option}"
      @logger.fatal(msg) unless defined?(options["log"])
      abort(msg)
    end
  end

  ## Create summary for logging
  summary = Array.new
  options.each_pair do |key,value|
    summary << "#{key}: #{value}"
  end

  ## Create mail informations
  to = options["usermail"]
  from = options["mailfrom"]

  ## Load Template File
  template = ERB.new(File.read(options["templatefile"]), safe_eval=nil, trim_mode=nil, outvar='_erbout')
  ## Render Template
  mail_message = template.result( binding )

  ## Sending E-Mail
  smtp = Net::SMTP.new mailserver, 25
  send_mail(mailserver, smtp, from, to, cc=nil, mail_message)
  @logger.info("Mail sent: #{summary.join(";")}")

rescue => err
  @logger.debug(err)
  @logger.fatal("Error in script. The variables or options were: #{summary.join(";")}")
end
