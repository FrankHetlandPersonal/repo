import boto3
import json
import os

def lambda_handler(event, context):
    # Extract the security group ID from the event
    security_group_id = event["detail"]["requestParameters"]["groupId"]
    
    # Check if the security group is attached to any EC2 instances
    ec2_client = boto3.client("ec2")
    response = ec2_client.describe_instances(
        Filters=[
            {
                "Name": "instance.group-id",
                "Values": [
                    security_group_id,
                ],
            },
            {
                "Name": "instance.public-ip",
                "Values": [
                    "*",
                ],
            },
            {
                "Name": "network-interface.subnet-id",
                "Values": [
                    "*",
                ],
            },
        ]
    )
    
    instances = response["Reservations"]
    if instances:
        # The security group is attached to at least one EC2 instance in a public subnet with a public IP
        # Remove the insecure ingress rules from the security group
        ingress_rules = response["SecurityGroups"][0]["IpPermissions"]
        insecure_ingress_rules = []
        for rule in ingress_rules:
            for ip_range in rule["IpRanges"]:
                if ip_range["CidrIp"] == "0.0.0.0/0":
                    insecure_ingress_rules.append(rule)

        if insecure_ingress_rules:
            ec2_client.revoke_security_group_ingress(
                GroupId=security_group_id,
                IpPermissions=insecure_ingress_rules
            )

            # Publish a message to the SNS topic for reporting
            sns_client = boto3.client("sns")
            sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
            message = f"Insecure ingress rules were removed from security group {security_group_id}"
            sns_client.publish(TopicArn=sns_topic_arn, Message=message)
    else:
        # The security group is not attached to any EC2 instance in a public subnet with a public IP
        # Do nothing
        pass
