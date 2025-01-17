{
  prometheusAlerts+:: {
    groups+: std.prune([
      {
        name: 'ceph-mgr-status',
        rules: std.prune([
          {
            alert: 'CephMgrIsAbsent',
            local mgrAbsentQueryBase = '(absent(ceph_mgr_status{%(cephExporterSelector)s} == 1))' % $._config,
            local mgrAbsentQuery = if $._config.isKubernetesCephDeployment then 'label_replace(%(mgrAbsentQueryBase)s, "namespace", "openshift-storage", "", "")' % mgrAbsentQueryBase else mgrAbsentQueryBase,
            expr: |||
              %(mgrAbsentQuery)s
            ||| % mgrAbsentQuery,
            'for': $._config.mgrIsAbsentAlertTime,
            labels: {
              severity: 'critical',
            },
            annotations: {
              description: 'No Ceph managers active',
              summary: 'No status 1 Ceph Manager matching "{%(cephExporterSelector)s}"' % $._config,
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
                 summary: "Storage metrics collector service doesn't have required no of replicas.",
                 description: 'Ceph Manager is missing replicas.',
               },
             }),
        ]),
      },
      (if $._config.cephMdsCount > 0 then
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
                 summary: 'Insufficient replicas for storage metadata service.',
                 description: 'Minimum required replicas for storage metadata service not available. Might affect the working of storage cluster.',
               },
             },
           ],
         }),
    ]),
  },
}
