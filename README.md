# Documentation
## Installation
To use this script, you need ruby installed and some special Gems. You need ruby 2.x.

Centos/RHEL 7
```
yum install ruby
```

You have to be sure that the following Gems are installed. The best way is to start an irb
``` ruby
require 'optparse'
require 'logger'
require 'erb'
require 'net/smtp'
```
When the answer of the command is "true", then you have the right Gems installed.


## Configuration in Icinga2
To use the script in icinga2 you need the Command Object for host notification
```
object NotificationCommand "mail-host-notification" {
  import "plugin-notification-command"

  command = [ "/opt/scripts/mail-host-notification.rb" ]

  arguments = {
          "-d" = {
                  value = "$icinga.long_date_time$"
                  description = "Longtime Date format: date '+%F %T %z'"
                  required = true
                  order = -8
          }
          "-l" = {
                  value = "$host.name$"
                  description = "Name of the Host"
                  required = true
                  order = -7
          }
          "-n" = {
                  value = "$host.display_name$"
                  description = "Displayname of the Hsot"
                  required = true
                  order = -6
          }
          "-o" = {
                  value = "$host.output$"
                  description = "Output from Healthcheck"
                  required = true
                  order = -5
          }
          "-r" = {
                  value = "$user.email$"
                  description = "E-Mail address from recipient"
                  required = true
                  order = -4
          }
          "-s" = {
                  value = "$host.state$"
                  description = "State of the host up|down|unknown"
                  required = true
                  order = -3
          }
          "-t" = {
                  value = "$notification.type$"
                  description = ""
                  required = true
                  order = -2
          }
          "-T" = {
                  value = "$notification.vars.notification_template$"
                  description = "ERB Template for e-mail content."
                  #required = true
                  order = -1
          }
          "-f" = {
                  value = "$notification.vars.from$"
                  description = "E-Mail address from sender"
          }
          "-4" = {
                  value = "$host.address$"
                  description = "IP address from host"
          }
          "-6" = {
                  value = "$host.address6$"
                  description = "IPv6 address from host"
          }
          "-b" = {
                  value = "$notification.author$"
                  description = "Authorname who sends the notification"
          }
          "-c" = {
                  value = "$notification.comment$"
                  description = "Comment from notification"
          }
          "-i" = {
                  value = "$notification.icingaweb2url$"
                  description = "Icingaweb2 URL"
          }
          "-E" = {
                  value = "$notification.vars.extra$"
                  repeat_key = true
                  description = "Extra informations for notification. As an Array."
          }
          "-v" = {
                  value = "$notification.vars.logging$"
                  description = "Log notifications to /var/log/icinga2_notifications.log"
          }
        }

  env = {
    NOTIFICATIONTYPE = "$notification.type$"
    HOSTALIAS = "$host.display_name$"
    HOSTADDRESS = "$address$"
    HOSTSTATE = "$host.state$"
    LONGDATETIME = "$icinga.long_date_time$"
    HOSTOUTPUT = "$host.output$"
    NOTIFICATIONAUTHORNAME = "$notification.author$"
    NOTIFICATIONCOMMENT = "$notification.comment$"
    HOSTDISPLAYNAME = "$host.display_name$"
    USEREMAIL = "$user.email$"
  }
}
```

To use the script in icinga2 you need the Command Object for service notification
```
object NotificationCommand "mail-service-notification" {
  import "plugin-notification-command"

  command = [ "/opt/scripts/mail-service-notification.rb" ]

  arguments = {
          "-d" = {
                  value = "$icinga.long_date_time$"
                  description = "Longtime Date format: date '+%F %T %z'"
                  required = true
                  order = -8
          }
          "-e" = {
                  value = "$service.name$"
                  description = "Service Name"
                  required = true
          }
          "-l" = {
                  value = "$host.name$"
                  description = "Name of the Host"
                  required = true
                  order = -7
          }
          "-n" = {
                  value = "$host.display_name$"
                  description = "Displayname of the Hsot"
                  required = true
                  order = -6
          }
          "-o" = {
                  value = "$service.output$"
                  description = "Output from service"
                  required = true
                  order = -5
          }
          "-r" = {
                  value = "$user.email$"
                  description = "E-Mail address from recipient"
                  required = true
                  order = -4
          }
          "-s" = {
                  value = "$service.state$"
                  description = "State of the service ok|warning|critical|unknown"
                  required = true
                  order = -3
          }
          "-t" = {
                  value = "$notification.type$"
                  description = "$service.display_name$"
                  required = true
                  order = -2
          "-u" = {
                  value = "$service.display_name$"
                  description = "Service display name"
                  required = true
          }
          "-T" = {
                  value = "$notification.vars.notification_template$"
                  description = "ERB Template for e-mail content."
                  #required = true
                  order = -1
          }
          "-f" = {
                  value = "$notification.vars.from$"
                  description = "E-Mail address from sender"
          }
          "-4" = {
                  value = "$host.address$"
                  description = "IP address from host"
          }
          "-6" = {
                  value = "$host.address6$"
                  description = "IPv6 address from host"
          }
          "-b" = {
                  value = "$notification.author$"
                  description = "Authorname who sends the notification"
          }
          "-c" = {
                  value = "$notification.comment$"
                  description = "Comment from notification"
          }
          "-i" = {
                  value = "$notification.icingaweb2url$"
                  description = "Icingaweb2 URL"
          }
          "-E" = {
                  value = "$notification.vars.extra$"
                  repeat_key = true
                  description = "Extra informations for notification. As an Array."
          }
          "-v" = {
                  value = "$notification.vars.logging$"
                  description = "Log notifications to /var/log/icinga2_notifications.log"
          }
        }

  env = {
    SERVICENAME = "$service.name$"
    HOSTNAME = "$host.name$"
    HOSTDISPLAYNAME = "$host.display_name$"
    NOTIFICATIONTYPE = "$notification.type$"
    SERVICEDESC = "$service.name$"
    HOSTALIAS = "$host.display_name$"
    HOSTADDRESS = "$address$"
    HOSTADDRESS = "$address$"
    SERVICESTATE = "$service.state$"
    LONGDATETIME = "$icinga.long_date_time$"
    SERVICEOUTPUT = "$service.output$"
    NOTIFICATIONAUTHORNAME = "$notification.author$"
    NOTIFICATIONCOMMENT = "$notification.comment$"
    HOSTDISPLAYNAME = "$host.display_name$"
    SERVICEDISPLAYNAME = "$service.display_name$"
    USEREMAIL = "$user.email$"
  }
}
```

## Create own ERB template
To create your ERB template, you need to add the variables to your ERB template.
If you are new in ERB language; here is a short summary [ERB Documentation](http://ruby-doc.org/stdlib-2.0.0/libdoc/erb/rdoc/ERB.html)

This table relate the argument options (which you have defined in the Icinga2 CommandObject) to the ERB variables:

##### service
| Script Argument |              Icinga2 variable             |            ERB Variable           |
|:---------------:|:-----------------------------------------:|:---------------------------------:|
|        -d       |          $icinga.long_date_time$          |          options["date"]          |
|        -e       |               $service.name$              |       options["servicename"]      |
|        -l       |                $host.name$                |        options["hostname"]        |
|        -n       |            $host.display_name$            |     options["hostdisplayname"]    |
|        -o       |              $service.output$             |      options["serviceoutput"]     |
|        -r       |                $user.email$               |        options["usermail"]        |
|        -s       |                $host.state$               |        options["hoststate"]       |
|        -t       |            $notification.type$            |    options["notificationtype"]    |
|        -u       |           $service.display_name$          |   options["servicedisplayname"]   |
|        -T       | $notification.vars.notification_template$ |      options["templatefile"]      |
|        -f       |          $notification.vars.from$         |        options["mailfrom"]        |
|        -4       |               $host.address$              |       options["hostaddress"]      |
|        -6       |              $host.address6$              |      options["hostaddress6"]      |
|        -b       |           $notification.author$           | options["notificationauthorname"] |
|        -c       |           $notification.comment$          |   options["notificationcomment"]  |
|        -i       |        $notification.icingaweb2url$       |      options["icingaweb2url"]     |
|        -E       |         $notification.vars.extra$         |    options["extrainformation"]    |
|        -v       |        $notification.vars.logging$        |           options["log"]          |

##### host
| Script Argument |              Icinga2 variable             |            ERB Variable           |
|:---------------:|:-----------------------------------------:|:---------------------------------:|
|        -d       |          $icinga.long_date_time$          |          options["date"]          |
|        -l       |                $host.name$                |        options["hostname"]        |
|        -n       |            $host.display_name$            |     options["hostdisplayname"]    |
|        -o       |               $host.output$               |       options["hostoutput"]       |
|        -r       |                $user.email$               |        options["usermail"]        |
|        -s       |                $host.state$               |        options["hoststate"]       |
|        -t       |            $notification.type$            |    options["notificationtype"]    |
|        -T       | $notification.vars.notification_template$ |      options["templatefile"]      |
|        -f       |          $notification.vars.from$         |        options["mailfrom"]        |
|        -4       |               $host.address$              |       options["hostaddress"]      |
|        -6       |              $host.address6$              |      options["hostaddress6"]      |
|        -b       |           $notification.author$           | options["notificationauthorname"] |
|        -c       |           $notification.comment$          |   options["notificationcomment"]  |
|        -i       |        $notification.icingaweb2url$       |      options["icingaweb2url"]     |
|        -E       |         $notification.vars.extra$         |    options["extrainformation"]    |
|        -v       |        $notification.vars.logging$        |           options["log"]          |


##### extrainformation
``` ruby
options["extrainformation"]
```
This is an array which include all extra information which are defined as an Array in Icinga2 (you can see an example at the end).
You can use the information in your ERB template:
``` ruby
options["extrainformation"][0]
options["extrainformation"][1]
options["extrainformation"][2]
[...]
```

## Example
Here is an example from the default-mail-host-notification.erb
``` erb
[...]
Subject: [Icinga2] <%= options["notificationtype"] %> Alert <%= options["hostdisplayname"] %> is <%= options["hoststate"] %>
[...]
```
In this example I added the Notification Type and the Host Display Name to the subject from notification mail.