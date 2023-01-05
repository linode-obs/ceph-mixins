{
  prometheusAlerts+:: {
    groups+: if $._config.cephMajorVersion <= 15 then [
      {
        name: 'pool.rules',
        rules: [
          {
            // Based on https://github.com/ceph/ceph/blob/8a82819d84cf884bd39c17e3236e0632ac146dc4/monitoring/prometheus/alerts/ceph_default_alerts.yml#L248-L257
            alert: 'CephPoolNearFull',
            expr: |||
              ceph_pool_stored{%(cephExporterSelector)s}
              / 
              (
                ceph_pool_stored{%(cephExporterSelector)s}
                + 
                ceph_pool_max_avail{%(cephExporterSelector)s}
              )
              * on(pool_id) group_right
              ceph_pool_metadata{%(PoolNearFullFilter)s} > %(PoolNearFullThreshold)s
            ||| % $._config,
            'for': $._config.poolNearFullAlertTime,
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'Storage pool {{ $labels.name }} is nearly full.',
              description: 'Storage pool {{ $labels.name }} usage is currently {{ $value | humanizePercentage }}.',
            },
          },
        ],
      },
    ] else [],
  },
}
