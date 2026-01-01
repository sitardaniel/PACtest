package terraform.s3

import future.keywords.in
import future.keywords.if

# Get all S3 buckets being created/updated
s3_buckets[name] = bucket if {
    bucket := input.resource_changes[_]
    bucket.type == "aws_s3_bucket"
    name := bucket.address
}

# Get all encryption configurations being created/updated
s3_encryptions contains bucket_name if {
    config := input.resource_changes[_]
    config.type == "aws_s3_bucket_server_side_encryption_configuration"
    # Extract bucket name from the resource (e.g., aws_s3_bucket_server_side_encryption_configuration.demo_bucket_encryption)
    # The bucket it refers to would be in config.change.after.bucket or the resource name pattern
    bucket_resource_name := split(config.address, ".")[1]
    # Remove "_encryption" suffix if present to match bucket name
    bucket_name := trim_suffix(bucket_resource_name, "_encryption")
}

s3_encryptions contains bucket_name if {
    config := input.resource_changes[_]
    config.type == "aws_s3_bucket_server_side_encryption_configuration"
    # Also match based on the name pattern
    parts := split(config.address, ".")
    count(parts) > 1
    resource_name := parts[1]
    # Handle different naming patterns
    contains(resource_name, "_bucket")
    bucket_name := resource_name
}

# Deny S3 buckets without encryption
deny contains msg if {
    bucket_name := s3_buckets[name]
    # Extract just the resource name from address like "aws_s3_bucket.demo_bucket"
    parts := split(name, ".")
    count(parts) > 1
    resource_name := parts[1]

    # Check if there's an encryption config for this bucket
    not has_encryption(resource_name)

    msg := sprintf("S3 buckets must have encryption enabled: %s", [name])
}

# Helper to check if bucket has encryption
has_encryption(bucket_name) if {
    s3_encryptions[bucket_name]
}

has_encryption(bucket_name) if {
    # Also check with _encryption suffix
    encryption_name := concat("", [bucket_name, "_encryption"])
    s3_encryptions[encryption_name]
}
