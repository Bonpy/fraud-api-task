output "kinesis_stream_name" { value = module.stream.stream_name }
output "dynamodb_table_name" { value = module.dynamodb.table_name }
output "sagemaker_endpoint_name" { value = module.sagemaker.endpoint_name }
output "flink_application_name" { value = module.flink.application_name }
