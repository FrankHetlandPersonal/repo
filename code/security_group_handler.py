import boto3
import json
import os

def lambda_handler(event, context):
    # Extract the security group ID from the event
    security_group_id = event["detail"]["requestParameters"]["groupId"]
    # Create a client object for the Amazon EC2 service
    ec2_client = boto3.client("ec2")
    # Retrieve the ingress rules for the security group
    response = ec2_client.describe_security_groups(GroupIds=[security_group_id])
    ingress_rules = response["SecurityGroups"][0]["IpPermissions"]

    # Identify ingress rules that allow all traffic
    insecure_ingress_rules = []
    for rule in ingress_rules:
        for ip_range in rule["IpRanges"]:
            if ip_range["CidrIp"] == "0.0.0.0/0":
                insecure_ingress_rules.append(rule)
    
    # Remove insecure ingress rules
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
