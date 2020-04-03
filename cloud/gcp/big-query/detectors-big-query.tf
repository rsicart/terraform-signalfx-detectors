resource "signalfx_detector" "heartbeat" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Bigquery heartbeat"

	program_text = <<-EOF
		from signalfx.detectors.not_reporting import not_reporting
		signal = data('slots/allocated_for_project_and_job_type' and ${module.filter-tags.filter_custom}).publish('signal')
		not_reporting.detector(stream=signal, resource_identifier=['dataset_id'], duration='${var.heartbeat_timeframe}').publish('CRIT')
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

resource "signalfx_detector" "concurrent_queries" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Bigquery concurrent queries"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		signal = data('query/count' and ${module.filter-tags.filter_custom})${var.concurrent_queries_aggregation_function}.${var.concurrent_queries_transformation_function}(over='${var.concurrent_queries_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.concurrent_queries_threshold_critical}, 'above', lasting('${var.concurrent_queries_aperiodic_duration}', ${var.concurrent_queries_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector(signal, ${var.concurrent_queries_threshold_warning}, ${var.concurrent_queries_threshold_critical}, 'within_range', lasting('${var.concurrent_queries_aperiodic_duration}', ${var.concurrent_queries_aperiodic_percentage})).publish('WARN')
	EOF

	rule {
		description           = "are too high > ${var.concurrent_queries_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.concurrent_queries_disabled_critical, var.concurrent_queries_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.concurrent_queries_notifications_critical, var.concurrent_queries_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "are too high > ${var.concurrent_queries_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.concurrent_queries_disabled_warning, var.concurrent_queries_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.concurrent_queries_notifications_warning, var.concurrent_queries_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "execution_time" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Bigquery execution time"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		signal = data('query/execution_times' and ${module.filter-tags.filter_custom})${var.execution_time_aggregation_function}.${var.execution_time_transformation_function}(over='${var.execution_time_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.execution_time_threshold_critical}, 'above', lasting('${var.execution_time_aperiodic_duration}', ${var.execution_time_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector(signal, ${var.execution_time_threshold_warning}, ${var.execution_time_threshold_critical}, 'within_range', lasting('${var.execution_time_aperiodic_duration}', ${var.execution_time_aperiodic_percentage})).publish('WARN')
	EOF

	rule {
		description           = "are too high > ${var.execution_time_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.execution_time_disabled_critical, var.execution_time_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.execution_time_notifications_critical, var.execution_time_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "are too high > ${var.execution_time_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.execution_time_disabled_warning, var.execution_time_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.execution_time_notifications_warning, var.execution_time_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "scanned_bytes" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Biquery scanned bytes"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		signal = data('query/scanned_bytes' and ${module.filter-tags.filter_custom})${var.scanned_bytes_aggregation_function}.${var.scanned_bytes_transformation_function}(over='${var.scanned_bytes_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.scanned_bytes_threshold_critical}, 'above', lasting('${var.scanned_bytes_aperiodic_duration}', ${var.scanned_bytes_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector(signal, ${var.scanned_bytes_threshold_warning}, ${var.scanned_bytes_threshold_critical}, 'within_range', lasting('${var.scanned_bytes_aperiodic_duration}', ${var.scanned_bytes_aperiodic_percentage})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.scanned_bytes_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.scanned_bytes_disabled_critical, var.scanned_bytes_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.scanned_bytes_notifications_critical, var.scanned_bytes_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.scanned_bytes_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.scanned_bytes_disabled_warning, var.scanned_bytes_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.scanned_bytes_notifications_warning, var.scanned_bytes_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "scanned_bytes_billed" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Biquery scanned bytes billed"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		signal = data('query/scanned_bytes_billed' and ${module.filter-tags.filter_custom})${var.scanned_bytes_billed_aggregation_function}.${var.scanned_bytes_billed_transformation_function}(over='${var.scanned_bytes_billed_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.scanned_bytes_billed_threshold_critical}, 'above', lasting('${var.scanned_bytes_billed_aperiodic_duration}', ${var.scanned_bytes_billed_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector(signal, ${var.scanned_bytes_billed_threshold_warning}, ${var.scanned_bytes_billed_threshold_critical}, 'within_range', lasting('${var.scanned_bytes_billed_aperiodic_duration}', ${var.scanned_bytes_billed_aperiodic_percentage})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.scanned_bytes_billed_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.scanned_bytes_billed_disabled_critical, var.scanned_bytes_billed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.scanned_bytes_billed_notifications_critical, var.scanned_bytes_billed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.scanned_bytes_billed_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.scanned_bytes_billed_disabled_warning, var.scanned_bytes_billed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.scanned_bytes_billed_notifications_warning, var.scanned_bytes_billed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "available_slots" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Biquery available slots"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		signal = data('slots/total_available' and ${module.filter-tags.filter_custom})${var.available_slots_aggregation_function}.${var.available_slots_transformation_function}(over='${var.available_slots_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.available_slots_threshold_critical}, 'below', lasting('${var.available_slots_aperiodic_duration}', ${var.available_slots_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector(signal, ${var.available_slots_threshold_warning}, ${var.available_slots_threshold_critical}, 'within_range', lasting('${var.available_slots_aperiodic_duration}', ${var.available_slots_aperiodic_percentage})).publish('WARN')
	EOF

	rule {
		description           = "is too low < ${var.available_slots_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.available_slots_disabled_critical, var.available_slots_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.available_slots_notifications_critical, var.available_slots_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too low < ${var.available_slots_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.available_slots_disabled_warning, var.available_slots_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.available_slots_notifications_warning, var.available_slots_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "stored_bytes" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Bigquery stored bytes"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		signal = data('storage/stored_bytes' and ${module.filter-tags.filter_custom})${var.stored_bytes_aggregation_function}.${var.stored_bytes_transformation_function}(over='${var.stored_bytes_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.stored_bytes_threshold_critical}, 'above', lasting('${var.stored_bytes_aperiodic_duration}', ${var.stored_bytes_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector(signal, ${var.stored_bytes_threshold_warning}, ${var.stored_bytes_threshold_critical}, 'within_range', lasting('${var.stored_bytes_aperiodic_duration}', ${var.stored_bytes_aperiodic_percentage})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.stored_bytes_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.stored_bytes_disabled_critical, var.stored_bytes_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.stored_bytes_notifications_critical, var.stored_bytes_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.stored_bytes_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.stored_bytes_disabled_warning, var.stored_bytes_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.stored_bytes_notifications_warning, var.stored_bytes_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "table_count" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Bigquery table count"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		signal = data('storage/table_count' and ${module.filter-tags.filter_custom})${var.table_count_aggregation_function}.${var.table_count_transformation_function}(over='${var.table_count_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.table_count_threshold_critical}, 'above', lasting('${var.table_count_aperiodic_duration}', ${var.table_count_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector(signal, ${var.table_count_threshold_warning}, ${var.table_count_threshold_critical}, 'within_range', lasting('${var.table_count_aperiodic_duration}', ${var.table_count_aperiodic_percentage})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.table_count_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.table_count_disabled_critical, var.table_count_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.table_count_notifications_critical, var.table_count_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.table_count_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.table_count_disabled_warning, var.table_count_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.table_count_notifications_warning, var.table_count_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "uploaded_bytes" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Bigquery uploaded bytes"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		signal = data('storage/uploaded_bytes' and ${module.filter-tags.filter_custom})${var.uploaded_bytes_aggregation_function}.${var.uploaded_bytes_transformation_function}(over='${var.uploaded_bytes_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.uploaded_bytes_threshold_critical}, 'above', lasting('${var.uploaded_bytes_aperiodic_duration}', ${var.uploaded_bytes_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector(signal, ${var.uploaded_bytes_threshold_warning}, ${var.uploaded_bytes_threshold_critical}, 'within_range', lasting('${var.uploaded_bytes_aperiodic_duration}', ${var.uploaded_bytes_aperiodic_percentage})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.uploaded_bytes_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.uploaded_bytes_disabled_critical, var.uploaded_bytes_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.uploaded_bytes_notifications_critical, var.uploaded_bytes_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.uploaded_bytes_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.uploaded_bytes_disabled_warning, var.uploaded_bytes_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.uploaded_bytes_notifications_warning, var.uploaded_bytes_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "uploaded_bytes_billed" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Bigquery uploaded bytes billed"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		signal = data('storage/uploaded_bytes_billed' and ${module.filter-tags.filter_custom})${var.uploaded_bytes_billed_aggregation_function}.${var.uploaded_bytes_billed_transformation_function}(over='${var.uploaded_bytes_billed_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.uploaded_bytes_billed_threshold_critical}, 'above', lasting('${var.uploaded_bytes_billed_aperiodic_duration}', ${var.uploaded_bytes_billed_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector(signal, ${var.uploaded_bytes_billed_threshold_warning}, ${var.uploaded_bytes_billed_threshold_critical}, 'within_range', lasting('${var.uploaded_bytes_billed_aperiodic_duration}', ${var.uploaded_bytes_billed_aperiodic_percentage})).publish('WARN')
	EOF

	rule {
		description           = "is too high > ${var.uploaded_bytes_billed_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.uploaded_bytes_billed_disabled_critical, var.uploaded_bytes_billed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.uploaded_bytes_billed_notifications_critical, var.uploaded_bytes_billed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high > ${var.uploaded_bytes_billed_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.uploaded_bytes_billed_disabled_warning, var.uploaded_bytes_billed_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.uploaded_bytes_billed_notifications_warning, var.uploaded_bytes_billed_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}
