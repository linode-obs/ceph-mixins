{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'ceph-node-alert.rules',
        rules: std.prune([
          (if $._config.isKubernetesCephDeployment then
          {
            alert: 'CephNodeDown',
            expr: |||
              cluster:ceph_node_down:join_kube == 0
            ||| % $._config,
            'for': $._config.cephNodeDownAlertTime,
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'Storage node {{ $labels.node }} went down',
              description: 'Storage node {{ $labels.node }} went down. Please check the node immediately.',
            },
          }),
        ]),
      },
    ],
  },
}
