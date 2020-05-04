resource "signalfx_detector" "sending_operations" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Pub/Sub Topic sending messages operations"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		signal = data('topic/send_message_operation_count', filter=filter('monitored_resource', 'pubsub_topic') and ${module.filter-tags.filter_custom})${var.sending_operations_aggregation_function}.${var.sending_operations_transformation_function}(over='${var.sending_operations_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.sending_operations_threshold_critical}, 'below', lasting('${var.sending_operations_aperiodic_duration}', ${var.sending_operations_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector_with_clear(signal, ${var.sending_operations_threshold_warning}, ${var.sending_operations_threshold_critical}, 'within_range', lasting('${var.sending_operations_aperiodic_duration}', ${var.sending_operations_aperiodic_percentage}), upper_strict=${var.sending_operations_aperiodic_upper_strict}).publish('WARN')
	EOF

	rule {
		description           = "are too low <= ${var.sending_operations_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.sending_operations_disabled_critical, var.sending_operations_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.sending_operations_notifications_critical, var.sending_operations_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "are too low <= ${var.sending_operations_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.sending_operations_disabled_warning, var.sending_operations_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.sending_operations_notifications_warning, var.sending_operations_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "unavailable_sending_operations" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Pub/Sub Topic sending unavailable messages"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		signal = data('topic/send_message_operation_count', filter=filter('monitored_resource', 'pubsub_topic') and filter('response_code', 'unavailable') and ${module.filter-tags.filter_custom})${var.unavailable_sending_operations_aggregation_function}.${var.unavailable_sending_operations_transformation_function}(over='${var.unavailable_sending_operations_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.unavailable_sending_operations_threshold_critical}, 'above', lasting('${var.unavailable_sending_operations_aperiodic_duration}', ${var.unavailable_sending_operations_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector_with_clear(signal, ${var.unavailable_sending_operations_threshold_warning}, ${var.unavailable_sending_operations_threshold_critical}, 'within_range', lasting('${var.unavailable_sending_operations_aperiodic_duration}', ${var.unavailable_sending_operations_aperiodic_percentage}), upper_strict=${var.unavailable_sending_operations_aperiodic_upper_strict}).publish('WARN')
	EOF

	rule {
		description           = "are too high > ${var.unavailable_sending_operations_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.unavailable_sending_operations_disabled_critical, var.unavailable_sending_operations_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.unavailable_sending_operations_notifications_critical, var.unavailable_sending_operations_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "are too high > ${var.unavailable_sending_operations_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.unavailable_sending_operations_disabled_warning, var.unavailable_sending_operations_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.unavailable_sending_operations_notifications_warning, var.unavailable_sending_operations_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}

resource "signalfx_detector" "unavailable_sending_operations_ratio" {
	name = "${join("", formatlist("[%s]", var.prefixes))}[${var.environment}] GCP Pub/Sub Topic sending unavailable messages ratio"

	program_text = <<-EOF
		from signalfx.detectors.aperiodic import aperiodic
		A = data('topic/send_message_operation_count', filter=filter('monitored_resource', 'pubsub_topic') and filter('response_code', 'unavailable') and ${module.filter-tags.filter_custom})${var.unavailable_sending_operations_ratio_aggregation_function}
		B = data('topic/send_message_operation_count', filter=filter('monitored_resource', 'pubsub_topic') and ${module.filter-tags.filter_custom})${var.unavailable_sending_operations_ratio_aggregation_function}
		signal = ((100*A)/B).${var.unavailable_sending_operations_ratio_transformation_function}(over='${var.unavailable_sending_operations_ratio_transformation_window}').publish('signal')
		aperiodic.above_or_below_detector(signal, ${var.unavailable_sending_operations_ratio_threshold_critical}, 'above', lasting('${var.unavailable_sending_operations_ratio_aperiodic_duration}', ${var.unavailable_sending_operations_ratio_aperiodic_percentage})).publish('CRIT')
		aperiodic.range_detector_with_clear(signal, ${var.unavailable_sending_operations_ratio_threshold_warning}, ${var.unavailable_sending_operations_ratio_threshold_critical}, 'within_range', lasting('${var.unavailable_sending_operations_ratio_aperiodic_duration}', ${var.unavailable_sending_operations_ratio_aperiodic_percentage}), upper_strict=${var.unavailable_sending_operations_ratio_aperiodic_upper_strict}).publish('WARN')
	EOF

	rule {
		description           = "is too high >= ${var.unavailable_sending_operations_ratio_threshold_critical}"
		severity              = "Critical"
		detect_label          = "CRIT"
		disabled              = coalesce(var.unavailable_sending_operations_ratio_disabled_critical, var.unavailable_sending_operations_ratio_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.unavailable_sending_operations_ratio_notifications_critical, var.unavailable_sending_operations_ratio_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

	rule {
		description           = "is too high >= ${var.unavailable_sending_operations_ratio_threshold_warning}"
		severity              = "Warning"
		detect_label          = "WARN"
		disabled              = coalesce(var.unavailable_sending_operations_ratio_disabled_warning, var.unavailable_sending_operations_ratio_disabled, var.detectors_disabled)
		notifications         = coalescelist(var.unavailable_sending_operations_ratio_notifications_warning, var.unavailable_sending_operations_ratio_notifications, var.notifications)
		parameterized_subject = "[{{ruleSeverity}}]{{{detectorName}}} {{{readableRule}}} ({{inputs.signal.value}}) on {{{dimensions}}}"
	}

}
