package terraform.security_groups

import future.keywords.if

# Test: Security group with SSH restricted to internal network should pass
test_security_group_restricted_ssh if {
	result := deny with input as {"resource_changes": [{
		"address": "aws_security_group.restricted_sg",
		"type": "aws_security_group",
		"change": {"after": {"ingress": [{
			"from_port": 22,
			"to_port": 22,
			"protocol": "tcp",
			"cidr_blocks": ["10.0.0.0/8"], # Restricted to internal network
		}]}},
	}]}
	count(result) == 0
}

# Test: Security group with SSH open to world (0.0.0.0/0) should fail
test_security_group_ssh_open_to_world if {
	result := deny with input as {"resource_changes": [{
		"address": "aws_security_group.open_sg",
		"type": "aws_security_group",
		"change": {"after": {"ingress": [{
			"from_port": 22,
			"to_port": 22,
			"protocol": "tcp",
			"cidr_blocks": ["0.0.0.0/0"], # Open to the world - VIOLATION
		}]}},
	}]}
	count(result) > 0
}

# Test: Security group with HTTPS (port 443) open to world should pass
test_security_group_https_open_to_world if {
	result := deny with input as {"resource_changes": [{
		"address": "aws_security_group.web_sg",
		"type": "aws_security_group",
		"change": {"after": {"ingress": [{
			"from_port": 443,
			"to_port": 443,
			"protocol": "tcp",
			"cidr_blocks": ["0.0.0.0/0"], # HTTPS open is OK
		}]}},
	}]}
	count(result) == 0
}

# Test: Security group with multiple rules, one SSH violation
test_security_group_mixed_rules if {
	result := deny with input as {"resource_changes": [{
		"address": "aws_security_group.mixed_sg",
		"type": "aws_security_group",
		"change": {"after": {"ingress": [
			{
				"from_port": 443,
				"to_port": 443,
				"protocol": "tcp",
				"cidr_blocks": ["0.0.0.0/0"],
			},
			{
				"from_port": 22,
				"to_port": 22,
				"protocol": "tcp",
				"cidr_blocks": ["0.0.0.0/0"], # SSH violation
			},
		]}},
	}]}
	count(result) == 1 # Only SSH rule should be denied
}

# Test: Verify deny message format
test_security_group_deny_message_format if {
	result := deny with input as {"resource_changes": [{
		"address": "aws_security_group.test",
		"type": "aws_security_group",
		"change": {"after": {"ingress": [{
			"from_port": 22,
			"to_port": 22,
			"protocol": "tcp",
			"cidr_blocks": ["0.0.0.0/0"],
		}]}},
	}]}
	count(result) > 0
	msg := result[_]
	contains(msg, "Security group")
	contains(msg, "allows SSH from 0.0.0.0/0")
	contains(msg, "port 22")
}
