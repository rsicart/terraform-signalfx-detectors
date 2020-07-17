resource "signalfx_detector" "heartbeat" {
  name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure App Service heartbeat"

  program_text = <<-EOF
		from signalfx.detectors.not_reporting import not_reporting
		base_filter = filter('resource_type', 'Microsoft.Web/sites') and filter('is_Azure_Function', 'false') and filter('primary_aggregation_type', 'true') and (not filter('azure_power_state', 'PowerState/stopping', 'PowerState/stoppped', 'PowerState/deallocating', 'PowerState/deallocated'))
		signal = data('CpuTime', filter=base_filter and ${module.filter-tags.filter_custom}).publish('signal')
		not_reporting.detector(stream=signal, resource_identifier=['azure_resource_name', 'azure_resource_group_name', 'azure_region'], duration='${var.heartbeat_timeframe}').publish('CRIT')
  EOF

  rule {
    description           = "has not reported in ${var.heartbeat_timeframe}"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.heartbeat_disabled, var.detectors_disabled)
    notifications         = coalescelist(var.heartbeat_notifications, var.notifications)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} on {{{dimensions}}}"
  }
}

resource "signalfx_detector" "response_time" {
  name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure App Service response time"

  program_text = <<-EOF
		from signalfx.detectors.aperiodic import conditions
		base_filter = filter('resource_type', 'Microsoft.Web/sites') and filter('is_Azure_Function', 'false') and filter('primary_aggregation_type', 'true')
		signal = data('HttpResponseTime', filter=base_filter and ${module.filter-tags.filter_custom})${var.response_time_aggregation_function}.${var.response_time_transformation_function}(over='${var.response_time_transformation_window}').publish('signal')
		ON_Condition_CRIT = conditions.generic_condition(signal, ${var.response_time_threshold_critical}, ${var.response_time_threshold_critical}, 'above', lasting('${var.response_time_aperiodic_duration}', ${var.response_time_aperiodic_percentage}), 'observed')
		ON_Condition_WARN = conditions.generic_condition(signal, ${var.response_time_threshold_warning}, ${var.response_time_threshold_critical}, 'within_range', lasting('${var.response_time_aperiodic_duration}', ${var.response_time_aperiodic_percentage}), 'observed', strict_2=False)
		detect(ON_Condition_CRIT, off=when(signal is None, '${var.response_time_clear_duration}') or not ON_Condition_CRIT, mode='split').publish('CRIT')
		detect(ON_Condition_WARN, off=when(signal is None, '${var.response_time_clear_duration}') or not ON_Condition_WARN, mode='split').publish('WARN')
  EOF

  rule {
    description           = "is too high > ${var.response_time_threshold_critical}s"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.response_time_disabled_critical, var.response_time_disabled, var.detectors_disabled)
    notifications         = coalescelist(var.response_time_notifications_critical, var.response_time_notifications, var.notifications)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }

  rule {
    description           = "is too high > ${var.response_time_threshold_warning}s"
    severity              = "Warning"
    detect_label          = "WARN"
    disabled              = coalesce(var.response_time_disabled_warning, var.response_time_disabled, var.detectors_disabled)
    notifications         = coalescelist(var.response_time_notifications_warning, var.response_time_notifications, var.notifications)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }
}

resource "signalfx_detector" "memory_usage_count" {
  name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure App Service memory usage"

  program_text = <<-EOF
		base_filter = filter('resource_type', 'Microsoft.Web/sites') and filter('is_Azure_Function', 'false') and filter('primary_aggregation_type', 'true')
		signal = data('MemoryWorkingSet', filter=base_filter and ${module.filter-tags.filter_custom})${var.memory_usage_count_aggregation_function}.${var.memory_usage_count_transformation_function}(over='${var.memory_usage_count_transformation_window}').publish('signal')
		detect(when(signal > ${var.memory_usage_count_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.memory_usage_count_threshold_warning}) and when(signal <= ${var.memory_usage_count_threshold_critical})).publish('WARN')
  EOF

  rule {
    description           = "is too high > ${ceil(var.memory_usage_count_threshold_critical / 1024 / 1024)}Mb"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.memory_usage_count_disabled_critical, var.memory_usage_count_disabled, var.detectors_disabled)
    notifications         = coalescelist(var.memory_usage_count_notifications_critical, var.memory_usage_count_notifications, var.notifications)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }

  rule {
    description           = "is too high > ${ceil(var.memory_usage_count_threshold_warning / 1024 / 1024)}Mb"
    severity              = "Warning"
    detect_label          = "WARN"
    disabled              = coalesce(var.memory_usage_count_disabled_warning, var.memory_usage_count_disabled, var.detectors_disabled)
    notifications         = coalescelist(var.memory_usage_count_notifications_warning, var.memory_usage_count_notifications, var.notifications)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }
}

resource "signalfx_detector" "http_5xx_errors_count" {
  name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure App Service 5xx error rate"

  program_text = <<-EOF
		from signalfx.detectors.aperiodic import conditions
		base_filter = filter('resource_type', 'Microsoft.Web/sites') and filter('is_Azure_Function', 'false') and filter('primary_aggregation_type', 'true')
		A = data('Http5xx', filter=base_filter and ${module.filter-tags.filter_custom})${var.http_5xx_errors_count_aggregation_function}
		B = data('Requests', filter=base_filter and ${module.filter-tags.filter_custom})${var.http_5xx_errors_count_aggregation_function}
		signal = ((A/B)*100).${var.http_5xx_errors_count_transformation_function}(over='${var.http_5xx_errors_count_transformation_window}').publish('signal')
		ON_Condition_CRIT = conditions.generic_condition(signal, ${var.http_5xx_errors_count_threshold_critical}, ${var.http_5xx_errors_count_threshold_critical}, 'above', lasting('${var.http_5xx_errors_count_aperiodic_duration}', ${var.http_5xx_errors_count_aperiodic_percentage}), 'observed')
		ON_Condition_WARN = conditions.generic_condition(signal, ${var.http_5xx_errors_count_threshold_warning}, ${var.http_5xx_errors_count_threshold_critical}, 'within_range', lasting('${var.http_5xx_errors_count_aperiodic_duration}', ${var.http_5xx_errors_count_aperiodic_percentage}), 'observed', strict_2=False)
		detect(ON_Condition_CRIT, off=when(signal is None, '${var.http_5xx_errors_count_clear_duration}') or not ON_Condition_CRIT, mode='split').publish('CRIT')
		detect(ON_Condition_WARN, off=when(signal is None, '${var.http_5xx_errors_count_clear_duration}') or not ON_Condition_WARN, mode='split').publish('WARN')
  EOF

  rule {
    description           = "is too high > ${var.http_5xx_errors_count_threshold_critical}%"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.http_5xx_errors_count_disabled_critical, var.http_5xx_errors_count_disabled, var.detectors_disabled)
    notifications         = coalescelist(var.http_5xx_errors_count_notifications_critical, var.http_5xx_errors_count_notifications, var.notifications)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }

  rule {
    description           = "is too high > ${var.http_5xx_errors_count_threshold_warning}%"
    severity              = "Warning"
    detect_label          = "WARN"
    disabled              = coalesce(var.http_5xx_errors_count_disabled_warning, var.http_5xx_errors_count_disabled, var.detectors_disabled)
    notifications         = coalescelist(var.http_5xx_errors_count_notifications_warning, var.http_5xx_errors_count_notifications, var.notifications)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }
}

resource "signalfx_detector" "http_4xx_errors_count" {
  name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure App Service 4xx error rate"

  program_text = <<-EOF
		from signalfx.detectors.aperiodic import conditions
		base_filter = filter('resource_type', 'Microsoft.Web/sites') and filter('is_Azure_Function', 'false') and filter('primary_aggregation_type', 'true')
		A = data('Http4xx', filter=base_filter and ${module.filter-tags.filter_custom})${var.http_4xx_errors_count_aggregation_function}
		B = data('Requests', filter=base_filter and ${module.filter-tags.filter_custom})${var.http_4xx_errors_count_aggregation_function}
		signal = ((A/B)*100).${var.http_4xx_errors_count_transformation_function}(over='${var.http_4xx_errors_count_transformation_window}').publish('signal')
		ON_Condition_CRIT = conditions.generic_condition(signal, ${var.http_4xx_errors_count_threshold_critical}, ${var.http_4xx_errors_count_threshold_critical}, 'above', lasting('${var.http_4xx_errors_count_aperiodic_duration}', ${var.http_4xx_errors_count_aperiodic_percentage}), 'observed')
		ON_Condition_WARN = conditions.generic_condition(signal, ${var.http_4xx_errors_count_threshold_warning}, ${var.http_4xx_errors_count_threshold_critical}, 'within_range', lasting('${var.http_4xx_errors_count_aperiodic_duration}', ${var.http_4xx_errors_count_aperiodic_percentage}), 'observed', strict_2=False)
		detect(ON_Condition_CRIT, off=when(signal is None, '${var.http_4xx_errors_count_clear_duration}') or not ON_Condition_CRIT, mode='split').publish('CRIT')
		detect(ON_Condition_WARN, off=when(signal is None, '${var.http_4xx_errors_count_clear_duration}') or not ON_Condition_WARN, mode='split').publish('WARN')
  EOF

  rule {
    description           = "is too high > ${var.http_4xx_errors_count_threshold_critical}%"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.http_4xx_errors_count_disabled_critical, var.http_4xx_errors_count_disabled, var.detectors_disabled)
    notifications         = coalescelist(var.http_4xx_errors_count_notifications_critical, var.http_4xx_errors_count_notifications, var.notifications)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }

  rule {
    description           = "is too high > ${var.http_4xx_errors_count_threshold_warning}%"
    severity              = "Warning"
    detect_label          = "WARN"
    disabled              = coalesce(var.http_4xx_errors_count_disabled_warning, var.http_4xx_errors_count_disabled, var.detectors_disabled)
    notifications         = coalescelist(var.http_4xx_errors_count_notifications_warning, var.http_4xx_errors_count_notifications, var.notifications)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }
}

resource "signalfx_detector" "http_success_status_rate" {
  name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure App Service successful response rate"

  program_text = <<-EOF
		from signalfx.detectors.aperiodic import conditions
		base_filter = filter('resource_type', 'Microsoft.Web/sites') and filter('is_Azure_Function', 'false') and filter('primary_aggregation_type', 'true')
		A = data('Http2xx', filter=base_filter and ${module.filter-tags.filter_custom})${var.http_success_status_rate_aggregation_function}
		B = data('Http3xx', filter=base_filter and ${module.filter-tags.filter_custom})${var.http_success_status_rate_aggregation_function}
		C = data('Requests', filter=base_filter and ${module.filter-tags.filter_custom})${var.http_success_status_rate_aggregation_function}
		signal = (((A+B)/C)*100).${var.http_success_status_rate_transformation_function}(over='${var.http_success_status_rate_transformation_window}').publish('signal')
		ON_Condition_CRIT = conditions.generic_condition(signal, ${var.http_success_status_rate_threshold_critical}, ${var.http_success_status_rate_threshold_critical}, 'below', lasting('${var.http_success_status_rate_aperiodic_duration}', ${var.http_success_status_rate_aperiodic_percentage}), 'observed')
		ON_Condition_WARN = conditions.generic_condition(signal, ${var.http_success_status_rate_threshold_warning}, ${var.http_success_status_rate_threshold_critical}, 'within_range', lasting('${var.http_success_status_rate_aperiodic_duration}', ${var.http_success_status_rate_aperiodic_percentage}), 'observed', strict_2=False)
		detect(ON_Condition_CRIT, off=when(signal is None, '${var.http_success_status_rate_clear_duration}') or not ON_Condition_CRIT, mode='split').publish('CRIT')
		detect(ON_Condition_WARN, off=when(signal is None, '${var.http_success_status_rate_clear_duration}') or not ON_Condition_WARN, mode='split').publish('WARN')
  EOF

  rule {
    description           = "is too low < ${var.http_success_status_rate_threshold_critical}%"
    severity              = "Critical"
    detect_label          = "CRIT"
    disabled              = coalesce(var.http_success_status_rate_disabled_critical, var.http_success_status_rate_disabled, var.detectors_disabled)
    notifications         = coalescelist(var.http_success_status_rate_notifications_critical, var.http_success_status_rate_notifications, var.notifications)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }

  rule {
    description           = "is too low < ${var.http_success_status_rate_threshold_warning}%"
    severity              = "Warning"
    detect_label          = "WARN"
    disabled              = coalesce(var.http_success_status_rate_disabled_warning, var.http_success_status_rate_disabled, var.detectors_disabled)
    notifications         = coalescelist(var.http_success_status_rate_notifications_warning, var.http_success_status_rate_notifications, var.notifications)
    parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
  }
}
