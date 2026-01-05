package terraform.iam

import future.keywords.if

# Test: IAM policy with least privilege (specific actions) should pass
test_iam_least_privilege if {
	count(deny) == 0 with input as {"resource_changes": [{
		"address": "aws_iam_policy.least_privilege",
		"type": "aws_iam_policy",
		"change": {"after": {"policy": json.marshal({
			"Version": "2012-10-17",
			"Statement": [{
				"Effect": "Allow",
				"Action": ["s3:GetObject", "s3:PutObject"],
				"Resource": "arn:aws:s3:::specific-bucket/*",
			}],
		})}},
	}]}
}

# Test: IAM policy with wildcard permissions (*:*) should fail
test_iam_wildcard_permissions if {
	count(deny) > 0 with input as {"resource_changes": [{
		"address": "aws_iam_policy.admin",
		"type": "aws_iam_policy",
		"change": {"after": {"policy": json.marshal({
			"Version": "2012-10-17",
			"Statement": [{
				"Effect": "Allow",
				"Action": ["*"], # Array format
				"Resource": "*",
			}],
		})}},
	}]}
}

# Test: IAM policy with specific action but wildcard resource should pass
test_iam_specific_action_wildcard_resource if {
	count(deny) == 0 with input as {"resource_changes": [{
		"address": "aws_iam_policy.ec2_describe",
		"type": "aws_iam_policy",
		"change": {"after": {"policy": json.marshal({
			"Version": "2012-10-17",
			"Statement": [{
				"Effect": "Allow",
				"Action": "ec2:DescribeInstances",
				"Resource": "*", # OK - action is specific
			}],
		})}},
	}]}
}

# Test: IAM policy with wildcard action but specific resource should pass
# (Policy only denies when BOTH Action and Resource are wildcards)
test_iam_wildcard_action_specific_resource if {
	count(deny) == 0 with input as {"resource_changes": [{
		"address": "aws_iam_policy.wildcard_action",
		"type": "aws_iam_policy",
		"change": {"after": {"policy": json.marshal({
			"Version": "2012-10-17",
			"Statement": [{
				"Effect": "Allow",
				"Action": ["*"], # Wildcard action
				"Resource": "arn:aws:s3:::specific-bucket/*", # Specific resource - OK
			}],
		})}},
	}]}
}

# Test: IAM policy with multiple statements, one with wildcard
test_iam_mixed_statements if {
	deny_messages := deny with input as {"resource_changes": [{
		"address": "aws_iam_policy.mixed",
		"type": "aws_iam_policy",
		"change": {"after": {"policy": json.marshal({
			"Version": "2012-10-17",
			"Statement": [
				{
					"Effect": "Allow",
					"Action": ["s3:GetObject"],
					"Resource": "arn:aws:s3:::bucket/*",
				},
				{
					"Effect": "Allow",
					"Action": ["*"], # Array format
					"Resource": "*", # Wildcard violation
				},
			],
		})}},
	}]}
	count(deny_messages) > 0
}

# Test: Verify deny message format
test_iam_deny_message_format if {
	deny_messages := deny with input as {"resource_changes": [{
		"address": "aws_iam_policy.test",
		"type": "aws_iam_policy",
		"change": {"after": {"policy": json.marshal({
			"Version": "2012-10-17",
			"Statement": [{
				"Effect": "Allow",
				"Action": ["*"], # Array format
				"Resource": "*",
			}],
		})}},
	}]}
	some msg in deny_messages
	contains(msg, "IAM policy")
	contains(msg, "overly permissive")
	contains(msg, "aws_iam_policy.test")
}
