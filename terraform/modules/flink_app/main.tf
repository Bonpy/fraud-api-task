data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["kinesisanalytics.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.application_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "policy" {
  name = "${var.application_name}-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords"
        ],
        Resource = var.kinesis_stream_arn
      },
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:PutObject"],
        Resource = [
          "${var.checkpoint_s3_uri}/*",
          "${var.sink_s3_uri}/*",
          var.code_s3_uri
        ]
      },
      {
        Effect   = "Allow",
        Action   = ["dynamodb:BatchWriteItem"],
        Resource = var.dynamodb_table_arn
      },
      {
        Effect   = "Allow",
        Action   = ["sagemaker:InvokeEndpoint"],
        Resource = "arn:aws:sagemaker:*:*:endpoint/${var.sagemaker_endpoint_name}"
      }
    ]
  })
}

resource "aws_kinesisanalyticsv2_application" "this" {
  name                   = var.application_name
  runtime_environment    = var.runtime_env
  service_execution_role = aws_iam_role.this.arn

  application_configuration {
    application_code_configuration {
      code_content {
        s3_content_location {
          bucket_arn = "arn:aws:s3:::${regex("s3://([^/]+)/.*", var.code_s3_uri)[0]}"
          file_key   = regex("s3://[^/]+/(.*)", var.code_s3_uri)[0]
        }
      }
      code_content_type = "ZIPFILE"
    }

    flink_application_configuration {
      checkpoint_configuration {
        configuration_type    = "CUSTOM"
        checkpointing_enabled = true
        checkpoint_interval   = 60000
      }
      monitoring_configuration {
        configuration_type = "DEFAULT"
        metrics_level      = "TASK"
      }
    }

    application_snapshot_configuration {
      snapshots_enabled = true
    }
  }

  tags = var.tags
}
