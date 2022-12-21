{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'ceph-mgr-status',
        rules: std.prune([
          {
            alert: 'CephMgrIsAbsent',
            local mgrAbsentQueryBase = "(up{%(cephExporterSelector)s} == 0 or absent(up{%(cephExporterSelector)s}))" % $._config,
            local mgrAbsentQuery = if $._config.isKubernetesCephDeployment then 'label_replace(%(mgrAbsentQueryBase)s, "namespace", "openshift-storage", "", "")' % mgrAbsentQueryBase else mgrAbsentQueryBase,
            expr: |||
              %(mgrAbsentQuery)s
            ||| % mgrAbsentQuery,
            'for': $._config.mgrIsAbsentAlertTime,
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'Storage metrics collector service not available anymore.',
              description: 'Ceph Manager has disappeared from Prometheus target discovery.',
            },
          },
          (if $._config.isKubernetesCephDeployment then
          {
            alert: 'CephMgrIsMissingReplicas',
            expr: |||
              sum(kube_deployment_spec_replicas{deployment=~"rook-ceph-mgr-.*"}) by (%(cephAggregationLabels)s) < %(cephMgrCount)d
            ||| % $._config,
            'for': $._config.mgrMissingReplicasAlertTime,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: "Storage metrics collector service doesn't have required no of replicas.",
              description: 'Ceph Manager is missing replicas.',
            },
          }),
        ]),
      },
      {
        name: 'ceph-mds-status',
        rules: [
          {
            alert: 'CephMdsMissingReplicas',
            expr: |||
              sum(ceph_mds_metadata{%(cephExporterSelector)s} == 1) by (%(cephAggregationLabels)s) < %(cephMdsCount)d
            ||| % $._config,
            'for': $._config.mdsMissingReplicasAlertTime,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'Insufficient replicas for storage metadata service.',
              description: 'Minimum required replicas for storage metadata service not available. Might affect the working of storage cluster.',
            },
          },
        ],
      },
    ],
  },
}
