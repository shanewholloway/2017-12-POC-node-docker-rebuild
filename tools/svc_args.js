const {dkrenv} = require('../package.json')

const devenv_map = {
  secrets: 'secret',
  networks: 'network', ports: 'publish', dns: 'dns', 'dns-option': 'dns-option', 'dns-search': 'dns-search',
  mount: 'mount', 'read-only': 'read-only',
  env: 'env', user: 'user', group: 'group',
  tty: 'tty', mode: 'mode', 'endpoint-mode': 'endpoint-mode',
  replicas: 'replicas', constraints: 'constraint', 

  'stop-signal': 'stop-signal', 'stop-grace-period': 'stop-grace-period',
  'limit-cpu': 'limit-cpu', 'reserve-cpu': 'reserve-cpu', 'limit-memory': 'limit-memory', 'reserve-memory': 'reserve-memory',
  'health-cmd': 'health-cmd', 'health-interval': 'health-interval', 'health-retries': 'health-retries', 'health-start-period': 'health-start-period', 'health-timeout': 'health-timeout',

  'restart-condition': 'restart-condition', 'restart-delay': 'restart-delay', 'restart-window': 'restart-window', 'restart-max-attempts': 'restart-max-attempts',
  'rollback-delay': 'rollback-delay', 'rollback-monitor': 'rollback-monitor', 'rollback-order': 'rollback-order', 'rollback-parallelism': 'rollback-parallelism', 'rollback-failure-action': 'rollback-failure-action', 'rollback-max-failure-ratio': 'rollback-max-failure-ratio',
  'update-delay': 'update-delay', 'update-monitor': 'update-monitor', 'update-order': 'update-order', 'update-parallelism': 'update-parallelism', 'update-failure-action': 'update-failure-action', 'update-max-failure-ratio': 'update-max-failure-ratio',
}

function svc_args(service, join_str='\n') {
  const svc_args = [].concat(service._args_ || [])
  for ( const [k,arg] of Object.entries(devenv_map) ) {
    let lst = service[k]
    if (null == lst) continue

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
