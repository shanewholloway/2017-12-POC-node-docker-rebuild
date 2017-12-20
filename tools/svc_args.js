const {dkrenv} = require('../package.json')
const devenv_remap = { secrets: 'secret', networks: 'network', ports: 'publish' }

function svc_args(service, join_str='\n') {
  const svc_args = [].concat(service._args_ || [])
  for ( let [arg,lst] of Object.entries(service) ) {
    if (null == lst) continue

    arg = devenv_remap[arg] || arg
    if ('_' === arg[0]) continue

    if ('string' === typeof lst)
      lst = lst.split(/\w\+/)
    else if (!Array.isArray(lst))
      lst = [lst]

    for (const v of lst)
      if (false === v) continue
      else if (true === v)
        svc_args.push(`--${arg}`)
      else
        svc_args.push(`--${arg} ${v}`)
  }

  return null != join_str
    ? svc_args.join(join_str)
    : svc_args
}

process.stdout.write(svc_args(dkrenv.service || {}))
