locals {
  tags = {
    project = "fraud-api"
    env     = var.env
  }
}

module "stream" {
  source      = "./modules/kinesis_stream_ref"
  stream_name = var.kinesis_stream_name
}

module "dynamodb" {
  source        = "./modules/dynamodb_table"
  table_name    = var.demographics_table_name
  partition_key = "user_id"
  tags          = local.tags
}

module "sagemaker" {
  source                 = "./modules/sagemaker_rt_endpoint"
  model_name             = var.model_name
  image_uri              = var.image_uri
  model_artifact_s3      = var.model_artifact_s3
  instance_type          = var.instance_type
  initial_instance_count = var.initial_instance_count
  tags                   = local.tags
}

module "flink" {
  source                  = "./modules/flink_app"
  application_name        = var.flink_application_name
  runtime_env             = var.flink_runtime_env
  code_s3_uri             = var.flink_code_s3_uri
  kinesis_stream_arn      = module.stream.stream_arn
  checkpoint_s3_uri       = var.flink_checkpoint_s3_uri
  sink_s3_uri             = var.flink_sink_s3_uri
  dynamodb_table_arn      = module.dynamodb.table_arn
  sagemaker_endpoint_name = module.sagemaker.endpoint_name
  tags                    = local.tags
}
