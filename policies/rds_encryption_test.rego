package terraform.rds

import future.keywords.if

# Test: RDS instance WITH encryption should pass
test_rds_with_encryption if {
	count(deny) == 0 with input as {"resource_changes": [{
		"address": "aws_db_instance.encrypted_db",
		"type": "aws_db_instance",
		"change": {"after": {
			"storage_encrypted": true,
			"engine": "mysql",
		}},
	}]}
}

# Test: RDS instance WITHOUT encryption should fail
test_rds_without_encryption if {
	count(deny) > 0 with input as {"resource_changes": [{
		"address": "aws_db_instance.unencrypted_db",
		"type": "aws_db_instance",
		"change": {"after": {
			"storage_encrypted": false,
			"engine": "mysql",
		}},
	}]}
}

# Test: RDS instance with encryption explicitly set to false should fail
test_rds_encryption_explicitly_false if {
	deny_messages := deny with input as {"resource_changes": [{
		"address": "aws_db_instance.test_db",
		"type": "aws_db_instance",
		"change": {"after": {
			"storage_encrypted": false,
			"engine": "postgres",
		}},
	}]}
	count(deny_messages) > 0
}

# Test: Multiple RDS instances - one encrypted, one not
test_rds_mixed_encryption if {
	deny_messages := deny with input as {
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
	count(deny_messages) == 1 # Only unencrypted DB should be denied
}

# Test: Verify deny message format
test_rds_deny_message_format if {
	deny_messages := deny with input as {"resource_changes": [{
		"address": "aws_db_instance.test",
		"type": "aws_db_instance",
		"change": {"after": {"storage_encrypted": false}},
	}]}
	some msg in deny_messages
	contains(msg, "RDS instance must have encryption enabled")
	contains(msg, "aws_db_instance.test")
}
