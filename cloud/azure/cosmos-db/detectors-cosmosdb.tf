resource "signalfx_detector" "heartbeat" {
  name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Cosmos DB heartbeat"

  program_text = <<-EOF
        from signalfx.detectors.not_reporting import not_reporting
        base_filter = filter('resource_type', 'Microsoft.DocumentDB/databaseAccounts') and filter('primary_aggregation_type', 'true')
        signal = data('AvailableStorage', filter=base_filter and ${module.filter-tags.filter_custom})${var.heartbeat_aggregation_function}.publish('signal')
        not_reporting.detector(stream=signal, resource_identifier=None, duration='${var.heartbeat_timeframe}').publish('CRIT')
    EOF

  rule {
    description           = "has not reported in ${var.heartbeat_timeframe}"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.heartbeat_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.heartbeat_notifications, "critical", []), var.notifications.critical)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} on {{{dimensions}}}"
  }
}

resource "signalfx_detector" "db_4xx_requests" {
  name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Cosmos DB 4xx request rate"

  program_text = <<-EOF
        from signalfx.detectors.aperiodic import aperiodic
        base_filter = filter('resource_type', 'Microsoft.DocumentDB/databaseAccounts') and filter('primary_aggregation_type', 'true')
        A = data('TotalRequests', extrapolation='zero', filter=base_filter and filter('statuscode', '4*') and ${module.filter-tags.filter_custom})${var.db_4xx_requests_aggregation_function}
        B = data('TotalRequests', extrapolation='zero', filter=base_filter and ${module.filter-tags.filter_custom})${var.db_4xx_requests_aggregation_function}
        signal = (A/B).scale(100).fill(0).publish('signal')
        detect(when(signal > threshold(${var.db_4xx_requests_threshold_critical}), lasting="${var.db_4xx_requests_timer}")).publish('CRIT')
        detect(when(signal > threshold(${var.db_4xx_requests_threshold_major}), lasting="${var.db_4xx_requests_timer}") and when(signal <= ${var.db_4xx_requests_threshold_critical})).publish('MAJOR')
    EOF

  rule {
    description           = "is too high > ${var.db_4xx_requests_threshold_critical}%"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.db_4xx_requests_disabled_critical, var.db_4xx_requests_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.db_4xx_requests_notifications, "critical", []), var.notifications.critical)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }

  rule {
    description           = "is too high > ${var.db_4xx_requests_threshold_major}%"
    severity              = "Major"
    detect_label          = "MAJOR"
    disabled              = coalesce(var.db_4xx_requests_disabled_major, var.db_4xx_requests_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.db_4xx_requests_notifications, "major", []), var.notifications.major)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }
}

resource "signalfx_detector" "db_5xx_requests" {
  name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Cosmos DB 5xx error rate"

  program_text = <<-EOF
        from signalfx.detectors.aperiodic import aperiodic
        base_filter = filter('resource_type', 'Microsoft.DocumentDB/databaseAccounts') and filter('primary_aggregation_type', 'true')
        A = data('TotalRequests', extrapolation='zero', filter=base_filter and filter('statuscode', '5*') and ${module.filter-tags.filter_custom})${var.db_5xx_requests_aggregation_function}
        B = data('TotalRequests', extrapolation='zero', filter=base_filter and ${module.filter-tags.filter_custom})${var.db_5xx_requests_aggregation_function}
        signal = (A/B).scale(100).fill(0).publish('signal')
        detect(when(signal > threshold(${var.db_5xx_requests_threshold_critical}), lasting="${var.db_5xx_requests_timer}")).publish('CRIT')
        detect(when(signal > threshold(${var.db_5xx_requests_threshold_major}), lasting="${var.db_5xx_requests_timer}") and when(signal <= ${var.db_5xx_requests_threshold_critical})).publish('MAJOR')
    EOF

  rule {
    description           = "is too high > ${var.db_5xx_requests_threshold_critical}%"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.db_5xx_requests_disabled_critical, var.db_5xx_requests_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.db_5xx_requests_notifications, "critical", []), var.notifications.critical)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }

  rule {
    description           = "is too high > ${var.db_5xx_requests_threshold_major}%"
    severity              = "Major"
    detect_label          = "MAJOR"
    disabled              = coalesce(var.db_5xx_requests_disabled_major, var.db_5xx_requests_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.db_5xx_requests_notifications, "major", []), var.notifications.major)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }
}

resource "signalfx_detector" "scaling" {
  name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Cosmos DB scaling errors rate"

  program_text = <<-EOF
        from signalfx.detectors.aperiodic import aperiodic
        base_filter = filter('resource_type', 'Microsoft.DocumentDB/databaseAccounts') and filter('primary_aggregation_type', 'true')
        A = data('TotalRequests', extrapolation='zero', filter=base_filter and filter('statuscode', '429') and ${module.filter-tags.filter_custom})${var.scaling_aggregation_function}
        B = data('TotalRequests', extrapolation='zero', filter=base_filter and ${module.filter-tags.filter_custom})${var.scaling_aggregation_function}
        signal = (A/B).scale(100).fill(0).publish('signal')
        detect(when(signal > threshold(${var.scaling_threshold_critical}), lasting="${var.scaling_timer}")).publish('CRIT')
        detect(when(signal > threshold(${var.scaling_threshold_major}), lasting="${var.scaling_timer}") and when(signal <= ${var.scaling_threshold_critical})).publish('MAJOR')
    EOF

  rule {
    description           = "is too high > ${var.scaling_threshold_critical}%"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.scaling_disabled_critical, var.scaling_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.scaling_notifications, "critical", []), var.notifications.critical)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }

  rule {
    description           = "is too high > ${var.scaling_threshold_major}%"
    severity              = "Major"
    detect_label          = "MAJOR"
    disabled              = coalesce(var.scaling_disabled_major, var.scaling_disabled, var.detectors_disabled)
    notifications         = coalescelist(lookup(var.scaling_notifications, "major", []), var.notifications.major)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }
}
