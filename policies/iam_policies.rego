package terraform.iam

deny contains msg if {
    resource := input.resource_changes[_]
    resource.type == "aws_iam_policy"
    policy := json.unmarshal(resource.change.after.policy)
    statement := policy.Statement[_]
    statement.Effect == "Allow"
    statement.Action[_] == "*"
    statement.Resource == "*"

    msg := sprintf("IAM policy %s grants overly permissive access (*:*)", [resource.address])
}
