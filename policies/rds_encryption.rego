package terraform.rds

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_db_instance"
    not resource.change.after.storage_encrypted

    msg := sprintf("RDS instance must have encryption enabled: %s", [resource.address])
}
