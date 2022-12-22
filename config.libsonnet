{
  _config+:: {
    // Selectors are inserted between {} in Prometheus queries.
    // cephExporterSelector: 'job="rook-ceph-mgr"',
    cephExporterSelector: 'job="ceph_exporter",component="objectstorage",environment="production"',

    // Adds additional rules specific to Kubernetes
    isKubernetesCephDeployment: true,

    // Some alerts depend on metrics not present in all Ceph versions
    cephMajorVersion: 15,

    // Labels to use by default when aggregating across ceph metrics
    cephAggregationLabels: 'namespace',

    // When aggregating information per ceph cluster, how should they be grouped?
    // If you're running multiple clusters where ceph_daemon may overlap, you should add
    // additional distinguishing labels separated by commas.
    cephDaemonAggregationLabels: 'ceph_daemon',

    // Single label storing the value of the host that actually houses a specific disk
    // (see ceph_disk_occuptation metric)
    diskOccuptationSourceInstanceLabel: 'exported_instance',

    // Expected number of Ceph Managers which are reporting metrics
    cephMgrCount: 1,
    // Expected number of Ceph Mds which are reporting metrics
    cephMdsCount: 2,

    // Duration to raise various Alerts
    cephNodeDownAlertTime: '30s',
    clusterStateAlertTime: '10m',
    clusterWarningStateAlertTime: '15m',
    clusterVersionAlertTime: '10m',
    clusterUtilizationAlertTime: '5s',
    clusterReadOnlyAlertTime: '0s',
    poolQuotaUtilizationAlertTime: '1m',
    poolNearFullAlertTime: '15m',
    monQuorumAlertTime: '15m',
    monQuorumLostTime: '5m',
    monQuorumLeaderChangesAlertTime: '5m',
    osdDataRebalanceAlertTime: '15s',
    osdDataRecoveryAlertTime: '2h',
    osdDataRecoveryInProgressAlertTime: '30s',
    osdDiskNotRespondingTime: '15m',
    osdDiskUnavailableTime: '1m',
    osdDiskAlertTime: '1m',
    osdDownAlertTime: '5m',
    osdFlapAlertTime: '0s',
    osdSlowOpsTime: '30s',
    osdUtilizationAlertTime: '40s',
    PGRepairAlertTime: '1h',
    PGInactiveAlertTime: '15m',
    pvcUtilizationAlertTime: '5s',
    mgrMissingReplicasAlertTime: '5m',
    mgrIsAbsentAlertTime: '5m',
    mdsMissingReplicasAlertTime: '5m',

    // Configurable thresholds for alerts
    osdFlapAlertThreshold: 10,
    PGInactiveThreshold: 0.01,
    PoolNearFullThreshold: 0.9,

    // Configurable filters for alerts
    PGInactiveFilter: 'name=~".+"',
    PoolNearFullFilter: 'name=~".+"',

    // Constants
    storageType: 'ceph',

    // For links between grafana dashboards, you need to tell us if your grafana
    // servers under some non-root path.
    grafanaPrefix: '',

    // We build alerts for the presence of all these jobs.
    jobs: {
      CephExporter: $._config.cephExporterSelector,
    },
  },
}
