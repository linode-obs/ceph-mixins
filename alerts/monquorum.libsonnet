{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'quorum-alert.rules',
        rules: std.prune([
          {
            alert: 'CephMonQuorumAtRisk',
            expr: |||
              count(ceph_mon_quorum_status{%(cephExporterSelector)s} == 1) by (%(cephAggregationLabels)s) 
              <= (floor(count(ceph_mon_metadata{%(cephExporterSelector)s}) by (%(cephAggregationLabels)s) / 2) + 1)
            ||| % $._config,
            'for': $._config.monQuorumAlertTime,
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'Storage quorum at risk',
              description: 'Storage cluster quorum is low.',
            },
          },
          (if $._config.isKubernetesCephDeployment then
             {
               alert: 'CephMonQuorumLost',
               expr: |||
                 count(kube_pod_status_phase{pod=~"rook-ceph-mon-.*", phase=~"Running|running"} == 1) by (%(cephAggregationLabels)s) < 2
               ||| % $._config,
               'for': $._config.monQuorumLostTime,
               labels: {
                 severity: 'critical',
               },
               annotations: {
                 summary: 'Storage quorum is lost',
                 description: 'Storage cluster quorum is lost.',
               },
             }),
          {
            alert: 'CephMonHighNumberOfLeaderChanges',
            expr: |||
              (ceph_mon_metadata{%(cephExporterSelector)s} * on (ceph_daemon)
              group_left() (rate(ceph_mon_num_elections{%(cephExporterSelector)s}[5m]) * 60)) > 0.95
            ||| % $._config,
            'for': $._config.monQuorumLeaderChangesAlertTime,
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'Storage Cluster has seen many leader changes recently.',
              description: 'Ceph Monitor {{ $labels.ceph_daemon }} on host {{ $labels.hostname }} has seen {{ $value | printf "%.2f" }} leader changes per minute recently.',
            },
          },
        ]),
      },
    ],
  },
}
