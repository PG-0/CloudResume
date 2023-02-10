terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# Variables
variable "bucket-name" {
  type = string
  nullable = false
  # Delete default this after testing
  default = "sdfsfadf-234123412143242"
  description = "Enter unique name for the bucket and can consist only of lowercase letters, numbers, dots "
}

variable "DDB-name" {
  type = string
  nullable = false
  # Delete default this after testing
  default = "CR-DDB-Default"
  description = "Enter a name for the DDB table"
}

### S3 ###

# S3 - Create
resource "aws_s3_bucket" "CR-bucket" {
  bucket = var.bucket-name

  tags = {
    Name = "CR-Bucket"
    Environment = "Prod"
  }

}

# S3 - Website Config
resource "aws_s3_bucket_website_configuration" "CR-bucket-web-config" {
  bucket = aws_s3_bucket.CR-bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# S3 - Block Public access
resource "aws_s3_account_public_access_block" "CR-Block-Public-Access" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 - Bucket Policy
resource "aws_s3_bucket_policy" "allow_access_from_CF" {
  bucket = aws_s3_bucket.CR-bucket.id
  policy = <<EOF
  {
      "Version": "2008-10-17",
      "Statement": [
          {
              "Sid": "AllowCloudFrontServicePrincipal",
              "Effect": "Allow",
              "Principal": {
                "Service": "cloudfront.amazonaws.com"
              },
              "Action": "s3:GetObject",
              "Resource": "arn:aws:s3:::${var.bucket-name}/*",
              "Condition": {
                  "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::892969532270:distribution/E133R371KW057D"
                }
              }
          }
      ]
  }
  EOF
}

## S3 TODO - Upload Files ##

### DDB ###

# DDB - Create
resource "aws_dynamodb_table" "CR-DDB-table" {
  name           = var.DDB-name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "visitorID"
  table_class    = "STANDARD"

  attribute {
    name = "visitorID"
    type = "S"
  }

  tags = {
    Name        = "CR-DDB-Table"
    Environment = "production"
  }
}

# DDB - Add Item for Counter
resource "aws_dynamodb_table_item" "CR-DDB-Add-Items" {
  table_name = aws_dynamodb_table.CR-DDB-table.id
  hash_key   = aws_dynamodb_table.CR-DDB-table.hash_key

  item = <<ITEM
    {
      "visitorID": {"S": "visitor-x"},
      "visit_count": {"N": "25"}
    }
  ITEM
}

### API GW ###

# API GW - Create
resource "aws_apigatewayv2_api" "CR-API-GW" {
  name            = "CR-HTTP-API-GW"
  protocol_type   = "HTTP"
  description     = "API GW created from Terraform."
  target          = aws_lambda_function.CR-Lambda-DDB-GetItem.arn
  # target          = "HTTP Proxy" #!! Problem Area
  # route_key       = "GET /update" 
  cors_configuration {
    allow_methods = ["GET"]
    allow_origins = [ "*" ]
  }
}

# API GW - Create Route 1 for Get Item

resource "aws_apigatewayv2_integration" "CR-API-GW-Route1" {
  api_id             = aws_apigatewayv2_api.CR-API-GW.id

  integration_uri    = aws_lambda_function.CR-Lambda-DDB-GetItem.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "CR-API-GW-Route-Get-Count" {
  api_id = aws_apigatewayv2_api.CR-API-GW.id

  route_key = "GET /getCount"
  target    = "integrations/${aws_apigatewayv2_integration.CR-API-GW-Route1.id}"

}


resource "aws_lambda_permission" "api_gw1" {
  statement_id  = "AllowExecutionFromAPIGatewayForGetItem"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.CR-Lambda-DDB-GetItem.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.CR-API-GW.execution_arn}/*/*"
}



# API GW - Create Route 2 for Update Item
resource "aws_apigatewayv2_integration" "CR-API-GW-Route2" {
  api_id             = aws_apigatewayv2_api.CR-API-GW.id

  integration_uri    = aws_lambda_function.CR-Lambda-DDB-UpdateItem.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

# Assign Route 
resource "aws_apigatewayv2_route" "CR-API-GW-Route-Update-Count" {
  api_id = aws_apigatewayv2_api.CR-API-GW.id

  route_key = "GET /update"
  target    = "integrations/${aws_apigatewayv2_integration.CR-API-GW-Route2.id}"

}

# Assign Lambda Permission
resource "aws_lambda_permission" "api_gw2" {
  statement_id  = "AllowExecutionFromAPIGatewayforUpdateItem"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.CR-Lambda-DDB-UpdateItem.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.CR-API-GW.execution_arn}/*/*"
}


### CloudFront ###



### Lambda ####

# Lambda (GetItem) - Zip Python Script for "DDB-GetItem.py"

data "archive_file" "Lambda-Zip1" {
  type = "zip"

  source_dir  = "${path.module}/DDB_GetItem_script"
  output_path = "${path.module}/DDB_GetItem_script.zip"
}

# Lambda (GetItem) - Upload Zip File to S3 

resource "aws_s3_object" "Lambda-Script-S3-Upload1" {
  bucket = aws_s3_bucket.CR-bucket.id

  key    = "DDB_GetItem_script.zip"
  source = data.archive_file.Lambda-Zip1.output_path

  etag = filemd5(data.archive_file.Lambda-Zip1.output_path)
}

# Lambda (GetItem) - Create CR DDB-GetItem Script

resource "aws_lambda_function" "CR-Lambda-DDB-GetItem" {
  function_name = "DDB-GetItem-Count"
  description   = "Created via Terraform. Function to retrieve count" 

  s3_bucket = aws_s3_bucket.CR-bucket.id
  s3_key    = aws_s3_object.Lambda-Script-S3-Upload1.key

  runtime = "python3.9"
  handler = "DDB-GetItem.lambda_handler"

  source_code_hash = data.archive_file.Lambda-Zip1.output_base64sha256

  role = aws_iam_role.Lambda-Role-DDB-Read-GetItem.arn

  environment {
    variables = {
      DDB_table = "${aws_dynamodb_table.CR-DDB-table.name}"
    }
  }
}

# Lambda (GetItem) - CW Logs

resource "aws_cloudwatch_log_group" "CR-Lambda-DDB-GetItem-CW-Logs" {
  name = "/aws/lambda/${aws_lambda_function.CR-Lambda-DDB-GetItem.function_name}"

  retention_in_days = 30
}

# Lambda (GetItem) - Create IAM Role & Inline Policy 

resource "aws_iam_role" "Lambda-Role-DDB-Read-GetItem" {
  name = "Lambda-Role-DDB-Read-GetItem"

  inline_policy {
      name = "Lambda-Inline-Role-DDB-Read-GetItem"

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = "dynamodb:GetItem"
            Effect   = "Allow"
            Resource = "${aws_dynamodb_table.CR-DDB-table.arn}"
          },
        ]
      })
    }

  assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        # SID    = "VisualEditor0"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        }
      ]
    })
  }

resource "aws_iam_role_policy_attachment" "lambda_policy1" {
  role       = aws_iam_role.Lambda-Role-DDB-Read-GetItem.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


### Lambda Cont. ### 


# Lambda (UpdateItem) - Zip Python Script for "DDB-UpdateItem.py"

data "archive_file" "Lambda-Zip2" {
  type = "zip"

  source_dir  = "${path.module}/DDB_UpdateItem_Increment_script"
  output_path = "${path.module}/DDB_UpdateItem_Increment_script.zip"
}

# Lambda (UpdateItem) - Upload Zip File to S3 

resource "aws_s3_object" "Lambda-Script-S3-Upload2" {
  bucket = aws_s3_bucket.CR-bucket.id

  key    = "DDB_UpdateItem_Increment_script.zip"
  source = data.archive_file.Lambda-Zip2.output_path

  etag = filemd5(data.archive_file.Lambda-Zip2.output_path)
}

# Lambda (UpdateItem) - Create CR DDB-UpdateItem Script

resource "aws_lambda_function" "CR-Lambda-DDB-UpdateItem" {
  function_name = "DDB-UpdateItem-Increment"
  description   = "Created via Terraform. Function to Update Count" 

  s3_bucket = aws_s3_bucket.CR-bucket.id
  s3_key    = aws_s3_object.Lambda-Script-S3-Upload2.key

  runtime = "python3.9"
  handler = "DDB-UpdateItem-Increment.lambda_handler"

  source_code_hash = data.archive_file.Lambda-Zip2.output_base64sha256

  role = aws_iam_role.Lambda-Role-DDB-Write-UpdateItem.arn

  environment {
    variables = {
      DDB_table = "${aws_dynamodb_table.CR-DDB-table.name}"
    }
  }

}

# Lambda (UpdateItem) - CW Logs

resource "aws_cloudwatch_log_group" "CR-Lambda-DDB-UpdateItem-CW-Logs" {
  name = "/aws/lambda/${aws_lambda_function.CR-Lambda-DDB-UpdateItem.function_name}"

  retention_in_days = 30
}

# Lambda (UpdateItem) - Create IAM Role & Inline Policy 

resource "aws_iam_role" "Lambda-Role-DDB-Write-UpdateItem" {
  name = "Lambda-Inline-Role-DDB-Write-UpdateItem"

  inline_policy {
      name = "Lambda-Inline-Role-DDB-Write-UpdateItem"

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = "dynamodb:UpdateItem"
            Effect   = "Allow"
            Resource = "${aws_dynamodb_table.CR-DDB-table.arn}"
          },
        ]
      })
    }

  assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        # SID    = "VisualEditor0"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        }
      ]
    })
  }

resource "aws_iam_role_policy_attachment" "lambda_policy2" {
  role       = aws_iam_role.Lambda-Role-DDB-Write-UpdateItem.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


### Outputs ### 

output "Name_of_Bucket" {
  value = var.bucket-name
}

output "Name_of_DDB_Table" {
  value = var.DDB-name
}

output "DDB_Table_Hash_Key" {
  value = aws_dynamodb_table.CR-DDB-table.hash_key
}

output "Lambda_GetItem" {
  value = aws_lambda_function.CR-Lambda-DDB-GetItem.id
}

output "Lambda_UpdateItem" {
  value = aws_lambda_function.CR-Lambda-DDB-UpdateItem.id
}


### TO DOs ###

# Update Python Script to include DDB Table Name. Going to hardcode this.
#   Was going to hardcode. But remembered about env variables in Lambda. got it to work ;)

# CloudFront Setup 