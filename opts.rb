def parse_opts(opts)
  ARGV.each do |e|
    opt = e.split('=')
    opts[opt[0].to_sym] = opt[1] 
  end
  opts
end