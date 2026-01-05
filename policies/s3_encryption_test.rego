package terraform.s3

import future.keywords.if

# Test: S3 bucket WITH encryption should pass (no denials)
test_s3_with_encryption if {
	result := deny with input as {
		"resource_changes": [
			{
				"address": "aws_s3_bucket.test_bucket",
				"type": "aws_s3_bucket",
				"change": {"after": {"bucket": "test-bucket"}},
			},
			{
				"address": "aws_s3_bucket_server_side_encryption_configuration.test_bucket_encryption",
				"type": "aws_s3_bucket_server_side_encryption_configuration",
				"change": {"after": {"bucket": "test-bucket"}},
			},
		],
	}
	count(result) == 0
}

# Test: S3 bucket WITHOUT encryption should fail (has denials)
test_s3_without_encryption if {
	result := deny with input as {"resource_changes": [{
		"address": "aws_s3_bucket.unencrypted_bucket",
		"type": "aws_s3_bucket",
		"change": {"after": {"bucket": "unencrypted-bucket"}},
	}]}
	count(result) > 0
}

# Test: Multiple S3 buckets - one encrypted, one not
test_s3_mixed_encryption if {
	result := deny with input as {
		"resource_changes": [
			{
				"address": "aws_s3_bucket.encrypted_bucket",
				"type": "aws_s3_bucket",
				"change": {"after": {"bucket": "encrypted-bucket"}},
			},
			{
				"address": "aws_s3_bucket_server_side_encryption_configuration.encrypted_bucket_encryption",
				"type": "aws_s3_bucket_server_side_encryption_configuration",
				"change": {"after": {"bucket": "encrypted-bucket"}},
			},
			{
				"address": "aws_s3_bucket.unencrypted_bucket",
				"type": "aws_s3_bucket",
				"change": {"after": {"bucket": "unencrypted-bucket"}},
			},
		],
	}
	count(result) == 1 # Only the unencrypted bucket should be denied
}

# Test: Verify deny message format
test_s3_deny_message_format if {
	result := deny with input as {"resource_changes": [{
		"address": "aws_s3_bucket.test",
		"type": "aws_s3_bucket",
		"change": {"after": {"bucket": "test"}},
	}]}
	count(result) > 0
	msg := result[_]
	contains(msg, "S3 buckets must have encryption enabled")
	contains(msg, "aws_s3_bucket.test")
}
