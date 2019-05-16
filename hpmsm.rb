class Hpmsm < Oxidized::Model
  prompt /^CLI[>#] +$/

  comment '! '

  # replace next line control sequence with a new line
  expect /(\e\[1M\e\[\??\d+(;\d+)*[A-Za-z]\e\[1L)|(\eE)/ do |data, re|
    data.gsub re, "\n"
  end

  # replace all used vt100 control sequences
  expect /\e\[\??\d+(;\d+)*[A-Za-z]/ do |data, re|
    data.gsub re, ''
  end

  cmd :all do |cfg|
    cfg = cfg.cut_both
    cfg = cfg.gsub /^\r/, ''
    cfg
  end

  cmd :secret do |cfg|
    cfg.gsub! /^(snmp-server community) \S+(.*)/, '\\1 <secret hidden> \\2'
    cfg.gsub! /^(snmp-server host \S+) \S+(.*)/, '\\1 <secret hidden> \\2'
    cfg.gsub! /^(radius-server host \S+ key) \S+(.*)/, '\\1 <secret hidden> \\2'
    cfg.gsub! /^(radius-server key).*/, '\\1 <configuration removed>'
    cfg.gsub! /^(tacacs-server host \S+ key) \S+(.*)/, '\\1 <secret hidden> \\2'
    cfg.gsub! /^(tacacs-server key).*/, '\\1 <secret hidden>'
    cfg
  end

  cmd 'show system info' do |cfg|
    sysinfo = ''
    ram = cfg.match(/Total RAM:\s+(\S+)/)[1].to_i()/1024/1024
    sysinfo << "Memory: #{ram}M\n"

    serial = cfg.match(/Serial Number:\s+(\S+)/)[1]
    sysinfo << "Serial Number: #{serial}\n"

    firmware = cfg.match(/Firmware Version:\s+(\S+)/)[1]
    sysinfo << "Firmware: #{firmware}\n"

    comment sysinfo
  end

  cmd 'show ip' do |cfg|
    comment cfg
  end

  cmd 'show ip route' do |cfg|
    comment cfg
  end

  cmd 'show certificate' do |cfg|
    comment cfg
  end

  cmd 'show certificate binding' do |cfg|
    comment cfg
  end

  cmd 'show satellites' do |cfg|
    comment cfg
  end

  cmd 'show web content' do |cfg|
    comment cfg
  end

  # not supported on all models
  cmd 'show system information' do |cfg|
    cfg = cfg.each_line.reject { |line| line.match /(.*CPU.*)|(.*Up Time.*)|(.*Total.*)|(.*Free.*)|(.*Lowest.*)|(.*Missed.*)/ }
    cfg = cfg.join
    comment cfg
  end

  cmd 'show all config' do |cfg|
    cfg = cfg.each_line.reject { |line| line.match /(^running configuration:)|(^#\s+Who:)|(^#\s+When:)|(^[ \t]*igmp proxy (upstream|downstream).*)/ }
    cfg = cfg.join
    cfg
  end

  cfg :telnet do
    username /Username:/
    password /Password:/
  end

  cfg :telnet, :ssh do
    post_login "enable"
    pre_logout "quit"
  end

  cfg :ssh do
    pty_options(chars_wide: 1000)
  end
end
