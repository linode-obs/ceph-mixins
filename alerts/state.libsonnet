{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'cluster-state-alert.rules',
        rules: [
          {
            alert: 'CephClusterErrorState',
            expr: |||
              ceph_health_status{%(cephExporterSelector)s} > 1
            ||| % $._config,
            'for': $._config.clusterStateAlertTime,
            labels: {
              severity: 'critical',
            },
            annotations: {
              message: 'Storage cluster is in error state',
              description: 'Storage cluster is in error state for more than %s.' % $._config.clusterStateAlertTime,
            },
          },
          {
            alert: 'CephClusterWarningState',
            expr: |||
              ceph_health_status{%(cephExporterSelector)s} == 1
            ||| % $._config,
            'for': $._config.clusterWarningStateAlertTime,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'Storage cluster is in degraded state',
              description: 'Storage cluster is in warning state for more than %s.' % $._config.clusterStateAlertTime,
            },
          },
          {
            alert: 'CephOSDVersionMismatch',
            expr: |||
              count(count(ceph_osd_metadata{%(cephExporterSelector)s}) by (ceph_version, %(cephAggregationLabels)s)) by (%(cephAggregationLabels)s) > 1
            ||| % $._config,
            'for': $._config.clusterVersionAlertTime,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'There are multiple versions of storage services running.',
              description: 'There are {{ $value }} different versions of Ceph OSD components running.',
            },
          },
          {
            alert: 'CephMonVersionMismatch',
            expr: |||
              count(count(ceph_mon_metadata{%(cephExporterSelector)s, ceph_version != ""}) by (ceph_version, %(cephAggregationLabels)s)) by (%(cephAggregationLabels)s) > 1
            ||| % $._config,
            'for': $._config.clusterVersionAlertTime,
            labels: {
              severity: 'warning',
            },
            annotations: {
              message: 'There are multiple versions of storage services running.',
              description: 'There are {{ $value }} different versions of Ceph Mon components running.',
            },
          },
        ],
      },
    ],
  },
}
