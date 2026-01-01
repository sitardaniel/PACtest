package terraform.security_groups

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_security_group"
    rule := resource.change.after.ingress[_]
    rule.cidr_blocks[_] == "0.0.0.0/0"
    rule.to_port == 22

    msg := sprintf("Security group %s allows SSH from 0.0.0.0/0 on port 22", [resource.address])
}
