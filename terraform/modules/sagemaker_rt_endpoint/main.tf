data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.model_name}-sm-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

resource "aws_sagemaker_model" "this" {
  name               = var.model_name
  execution_role_arn = aws_iam_role.this.arn

  primary_container {
    image          = var.image_uri
    model_data_url = var.model_artifact_s3
  }

  tags = var.tags
}

resource "aws_sagemaker_endpoint_configuration" "this" {
  name = "${var.model_name}-cfg"

  production_variants {
    variant_name           = "AllTraffic"
    model_name             = aws_sagemaker_model.this.name
    initial_instance_count = var.initial_instance_count
    instance_type          = var.instance_type
  }

  tags = var.tags
}

resource "aws_sagemaker_endpoint" "this" {
  name                 = var.model_name
  endpoint_config_name = aws_sagemaker_endpoint_configuration.this.name
  tags                 = var.tags
}
