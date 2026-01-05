package terraform.rds

import future.keywords.if

# Test: RDS instance WITH encryption should pass
test_rds_with_encryption if {
	result := deny with input as {"resource_changes": [{
		"address": "aws_db_instance.encrypted_db",
		"type": "aws_db_instance",
		"change": {"after": {
			"storage_encrypted": true,
			"engine": "mysql",
		}},
	}]}
	count(result) == 0
}

# Test: RDS instance WITHOUT encryption should fail
test_rds_without_encryption if {
	result := deny with input as {"resource_changes": [{
		"address": "aws_db_instance.unencrypted_db",
		"type": "aws_db_instance",
		"change": {"after": {
			"storage_encrypted": false,
			"engine": "mysql",
		}},
	}]}
	count(result) > 0
}

# Test: RDS instance with encryption explicitly set to false should fail
test_rds_encryption_explicitly_false if {
	result := deny with input as {"resource_changes": [{
		"address": "aws_db_instance.test_db",
		"type": "aws_db_instance",
		"change": {"after": {
			"storage_encrypted": false,
			"engine": "postgres",
		}},
	}]}
	count(result) > 0
}

# Test: Multiple RDS instances - one encrypted, one not
test_rds_mixed_encryption if {
	result := deny with input as {
		"resource_changes": [
			{
				"address": "aws_db_instance.encrypted_db",
				"type": "aws_db_instance",
				"change": {"after": {"storage_encrypted": true}},
			},
			{
				"address": "aws_db_instance.unencrypted_db",
				"type": "aws_db_instance",
				"change": {"after": {"storage_encrypted": false}},
			},
		],
	}
	count(result) == 1 # Only unencrypted DB should be denied
}

# Test: Verify deny message format
test_rds_deny_message_format if {
	result := deny with input as {"resource_changes": [{
		"address": "aws_db_instance.test",
		"type": "aws_db_instance",
		"change": {"after": {"storage_encrypted": false}},
	}]}
	count(result) > 0
	msg := result[_]
	contains(msg, "RDS instance must have encryption enabled")
	contains(msg, "aws_db_instance.test")
}
