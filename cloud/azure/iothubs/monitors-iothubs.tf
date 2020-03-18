resource "signalfx_detector" "heartbeat" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs heartbeat"

	program_text = <<-EOF
		from signalfx.detectors.not_reporting import not_reporting
		signal = data('EventGridDeliveries', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})
		not_reporting.detector(stream=signal, resource_identifier=['host'], duration='${var.heartbeat_timeframe}').publish('CRIT')
	EOF

	rule {
		description           = "has not reported in ${var.heartbeat_timeframe}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.heartbeat_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.heartbeat_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} on {{{dimensions}}}"
	}
}

resource "signalfx_detector" "jobs_failed" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs jobs failed"

	program_text = <<-EOF
		A = data('jobs.failed', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.jobs_failed_aggregation_function}
		B = data('jobs.completed', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.jobs_failed_aggregation_function}
		signal = ((A/(A+B))*100).${var.jobs_failed_transformation_function}(over='${var.jobs_failed_transformation_window}')
		detect(when(signal > ${var.jobs_failed_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.jobs_failed_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.jobs_failed_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.jobs_failed_disabled_critical, var.jobs_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.jobs_failed_notifications_critical, var.jobs_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.jobs_failed_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.jobs_failed_disabled_warning, var.jobs_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.jobs_failed_notifications_warning, var.jobs_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}
}

resource "signalfx_detector" "list_jobs_failed" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs list jobs failure"

	program_text = <<-EOF
		A = data('jobs.listJobs.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.list_jobs_failed_aggregation_function}
		B = data('jobs.listJobs.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.list_jobs_failed_aggregation_function}
		signal = ((A/(A+B))*100).${var.list_jobs_failed_transformation_function}(over='${var.list_jobs_failed_transformation_window}')
		detect(when(signal > ${var.list_jobs_failed_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.list_jobs_failed_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.list_jobs_failed_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.list_jobs_failed_disabled_critical, var.list_jobs_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.list_jobs_failed_notifications_critical, var.list_jobs_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.list_jobs_failed_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.list_jobs_failed_disabled_warning, var.list_jobs_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.list_jobs_failed_notifications_warning, var.list_jobs_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}
}

resource "signalfx_detector" "query_jobs_failed" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs query jobs failed"

	program_text = <<-EOF
		A = data('jobs.queryJobs.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.query_jobs_failed_aggregation_function}
		B = data('jobs.queryJobs.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.query_jobs_failed_aggregation_function}
		signal = ((A/(A+B))*100).${var.query_jobs_failed_transformation_function}(over='${var.query_jobs_failed_transformation_window}')
		detect(when(signal > ${var.query_jobs_failed_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.query_jobs_failed_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.query_jobs_failed_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.query_jobs_failed_disabled_critical, var.query_jobs_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.query_jobs_failed_notifications_critical, var.query_jobs_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.query_jobs_failed_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.query_jobs_failed_disabled_warning, var.query_jobs_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.query_jobs_failed_notifications_warning, var.query_jobs_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "total_devices" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs total devices"

	program_text = <<-EOF
		signal = data('totalDeviceCount', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.total_devices_aggregation_function}.${var.total_devices_transformation_function}(over='${var.total_devices_transformation_window}')
		detect(when(signal == ${var.total_devices_threshold_critical})).publish('CRIT')
	EOF

	rule {
		description           = "is == ${var.total_devices_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.total_devices_disabled_critical, var.total_devices_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.total_devices_notifications_critical, var.total_devices_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "c2d_methods_failed" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs c2d methods failure"

	program_text = <<-EOF
		A = data('c2d.methods.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.c2d_methods_failed_aggregation_function}
		B = data('c2d.methods.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.c2d_methods_failed_aggregation_function}
		signal = ((A/(A+B))*100).${var.c2d_methods_failed_transformation_function}(over='${var.c2d_methods_failed_transformation_window}')
		detect(when(signal > ${var.c2d_methods_failed_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.c2d_methods_failed_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.c2d_methods_failed_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.c2d_methods_failed_disabled_critical, var.c2d_methods_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.c2d_methods_failed_notifications_critical, var.c2d_methods_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.c2d_methods_failed_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.c2d_methods_failed_disabled_warning, var.c2d_methods_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.c2d_methods_failed_notifications_warning, var.c2d_methods_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}
}

resource "signalfx_detector" "c2d_twin_read_failed" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs c2d twin read failure"

	program_text = <<-EOF
		A = data('c2d.twin.read.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.c2d_twin_read_failed_aggregation_function}
		B = data('c2d.twin.read.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.c2d_twin_read_failed_aggregation_function}
		signal = ((A/(A+B))*100).${var.c2d_twin_read_failed_transformation_function}(over='${var.c2d_twin_read_failed_transformation_window}')
		detect(when(signal > ${var.c2d_twin_read_failed_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.c2d_twin_read_failed_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.c2d_twin_read_failed_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.c2d_twin_read_failed_disabled_critical, var.c2d_twin_read_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.c2d_twin_read_failed_notifications_critical, var.c2d_twin_read_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.c2d_twin_read_failed_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.c2d_twin_read_failed_disabled_warning, var.c2d_twin_read_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.c2d_twin_read_failed_notifications_warning, var.c2d_twin_read_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}
}

resource "signalfx_detector" "c2d_twin_update_failed" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs c2d twin update failure"

	program_text = <<-EOF
		A = data('c2d.twin.update.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.c2d_twin_update_failed_aggregation_function}
		B = data('c2d.twin.update.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.c2d_twin_update_failed_aggregation_function}
		signal = ((A/(A+B))*100).${var.c2d_twin_update_failed_transformation_function}(over='${var.c2d_twin_update_failed_transformation_window}')
		detect(when(signal > ${var.c2d_twin_update_failed_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.c2d_twin_update_failed_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.c2d_twin_update_failed_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.c2d_twin_update_failed_disabled_critical, var.c2d_twin_update_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.c2d_twin_update_failed_notifications_critical, var.c2d_twin_update_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.c2d_twin_update_failed_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.c2d_twin_update_failed_disabled_warning, var.c2d_twin_update_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.c2d_twin_update_failed_notifications_warning, var.c2d_twin_update_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}
}

resource "signalfx_detector" "d2c_twin_read_failed" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs d2c twin read failure"

	program_text = <<-EOF
		A = data('d2c.twin.read.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_twin_read_failed_aggregation_function}
		B = data('d2c.twin.read.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_twin_read_failed_aggregation_function}
		signal = ((A/(A+B))*100).${var.d2c_twin_read_failed_transformation_function}(over='${var.d2c_twin_read_failed_transformation_window}')
		detect(when(signal > ${var.d2c_twin_read_failed_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.d2c_twin_read_failed_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.d2c_twin_read_failed_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.d2c_twin_read_failed_disabled_critical, var.d2c_twin_read_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_twin_read_failed_notifications_critical, var.d2c_twin_read_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.d2c_twin_read_failed_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.d2c_twin_read_failed_disabled_warning, var.d2c_twin_read_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_twin_read_failed_notifications_warning, var.d2c_twin_read_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}
}

resource "signalfx_detector" "d2c_twin_update_failed" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs d2c twin update failure"

	program_text = <<-EOF
		A = data('d2c.twin.update.failure', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_twin_update_failed_aggregation_function}
		B = data('d2c.twin.update.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_twin_update_failed_aggregation_function}
		signal = ((A/(A+B))*100).${var.d2c_twin_update_failed_transformation_function}(over='${var.d2c_twin_update_failed_transformation_window}')
		detect(when(signal > ${var.d2c_twin_update_failed_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.d2c_twin_update_failed_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.d2c_twin_update_failed_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.d2c_twin_update_failed_disabled_critical, var.d2c_twin_update_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_twin_update_failed_notifications_critical, var.d2c_twin_update_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.d2c_twin_update_failed_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.d2c_twin_update_failed_disabled_warning, var.d2c_twin_update_failed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_twin_update_failed_notifications_warning, var.d2c_twin_update_failed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}
}

resource "signalfx_detector" "d2c_telemetry_egress_dropped" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs d2c telemetry egress dropped"

	program_text = <<-EOF
		A = data('d2c.telemetry.egress.dropped', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_dropped_aggregation_function}
		B = data('d2c.telemetry.egress.orphaned', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_dropped_aggregation_function}
		C = data('d2c.telemetry.egress.invalid', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_dropped_aggregation_function}
		D = data('d2c.telemetry.egress.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_dropped_aggregation_function}
		signal = ((A/(A+B+C+D))*100).${var.d2c_telemetry_egress_dropped_transformation_function}(over='${var.d2c_telemetry_egress_dropped_transformation_window}')
		detect(when(signal > ${var.d2c_telemetry_egress_dropped_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.d2c_telemetry_egress_dropped_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.d2c_telemetry_egress_dropped_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.d2c_telemetry_egress_dropped_disabled_critical, var.d2c_telemetry_egress_dropped_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_telemetry_egress_dropped_notifications_critical, var.d2c_telemetry_egress_dropped_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.d2c_telemetry_egress_dropped_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.d2c_telemetry_egress_dropped_disabled_warning, var.d2c_telemetry_egress_dropped_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_telemetry_egress_dropped_notifications_warning, var.d2c_telemetry_egress_dropped_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}
}

resource "signalfx_detector" "d2c_telemetry_egress_orphaned" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs d2c telemetry egress orphaned"

	program_text = <<-EOF
		A = data('d2c.telemetry.egress.orphaned', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_orphaned_aggregation_function}
		B = data('d2c.telemetry.egress.dropped', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_orphaned_aggregation_function}
		C = data('d2c.telemetry.egress.invalid', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_orphaned_aggregation_function}
		D = data('d2c.telemetry.egress.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_orphaned_aggregation_function}
		signal = ((A/(A+B+C+D))*100).${var.d2c_telemetry_egress_orphaned_transformation_function}(over='${var.d2c_telemetry_egress_orphaned_transformation_window}')
		detect(when(signal > ${var.d2c_telemetry_egress_orphaned_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.d2c_telemetry_egress_orphaned_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.d2c_telemetry_egress_orphaned_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.d2c_telemetry_egress_orphaned_disabled_critical, var.d2c_telemetry_egress_orphaned_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_telemetry_egress_orphaned_notifications_critical, var.d2c_telemetry_egress_orphaned_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.d2c_telemetry_egress_orphaned_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.d2c_telemetry_egress_orphaned_disabled_warning, var.d2c_telemetry_egress_orphaned_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_telemetry_egress_orphaned_notifications_warning, var.d2c_telemetry_egress_orphaned_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}
}

resource "signalfx_detector" "d2c_telemetry_egress_invalid" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] Azure Iothubs d2c telemetry egress invalid"

	program_text = <<-EOF
		A = data('d2c.telemetry.egress.invalid', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_invalid_aggregation_function}
		B = data('d2c.telemetry.egress.dropped', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_invalid_aggregation_function}
		C = data('d2c.telemetry.egress.orphaned', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_invalid_aggregation_function}
		D = data('d2c.telemetry.egress.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_egress_invalid_aggregation_function}
		signal = ((A/(A+B+C+D))*100).${var.d2c_telemetry_egress_invalid_transformation_function}(over='${var.d2c_telemetry_egress_invalid_transformation_window}')
		detect(when(signal > ${var.d2c_telemetry_egress_invalid_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.d2c_telemetry_egress_invalid_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.d2c_telemetry_egress_invalid_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.d2c_telemetry_egress_invalid_disabled_critical, var.d2c_telemetry_egress_invalid_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_telemetry_egress_invalid_notifications_critical, var.d2c_telemetry_egress_invalid_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.d2c_telemetry_egress_invalid_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.d2c_telemetry_egress_invalid_disabled_warning, var.d2c_telemetry_egress_invalid_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_telemetry_egress_invalid_notifications_warning, var.d2c_telemetry_egress_invalid_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}
}

resource "signalfx_detector" "d2c_telemetry_ingress_nosent" {
	name = "IOT Hub Too many d2c telemetry ingress not sent"

	program_text = <<-EOF
		A = data('d2c.telemetry.ingress.success', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_ingress_nosent_aggregation_function}
		B = data('d2c.telemetry.ingress.allProtocol', filter=filter('resource_type', 'Microsoft.Devices/IotHubs') and ${module.filter-tags.filter_custom})${var.d2c_telemetry_ingress_nosent_aggregation_function}
		signal = ((100-(A/B))*100).${var.d2c_telemetry_ingress_nosent_transformation_function}(over='${var.d2c_telemetry_ingress_nosent_transformation_window}')
		detect(when(signal > ${var.d2c_telemetry_ingress_nosent_threshold_critical})).publish('CRIT')
		detect(when(signal > ${var.d2c_telemetry_ingress_nosent_threshold_warning})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.d2c_telemetry_ingress_nosent_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.d2c_telemetry_ingress_nosent_disabled_critical, var.d2c_telemetry_ingress_nosent_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_telemetry_ingress_nosent_notifications_critical, var.d2c_telemetry_ingress_nosent_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.d2c_telemetry_ingress_nosent_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.d2c_telemetry_ingress_nosent_disabled_warning, var.d2c_telemetry_ingress_nosent_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.d2c_telemetry_ingress_nosent_notifications_warning, var.d2c_telemetry_ingress_nosent_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{ruleName}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}
}
