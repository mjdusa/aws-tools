import re
import sys
import boto3


def main(show_details = False):
    ec2 = boto3.client("ec2", region_name="us-west-2")

    all_regions = [r["RegionName"] for r in ec2.describe_regions(AllRegions=False)["Regions"]]

    if not sys.argv[1:]:
        regions = all_regions
    else:
        regions = sys.argv[1].split(",")

    sts = boto3.client("sts", region_name="us-west-2")

    resp = sts.get_caller_identity()

    print("")

    if show_details:
        user_id = resp["UserId"]
        print(f"User ID: {user_id}")

    account_id = resp["Account"]
    print(f"Account ID: {account_id}")

    if show_details:
        arn = resp["Arn"]
        print(f"Arn: {arn}")

    print("")

    if show_details:
        print(f"Scanning Regions: {regions}")

        print("")

    for region in regions:
        print(f"Region: {region}")

        results = search_region_for_sc_parent_stacks(region, show_details)

        if not results:
            print("- No stacks found")
            print("")

            continue

        product_stack_width = len("Product Stack")
        parent_stack_width = len("Parent Stack")

        for product_stack, parent_stack in results:
            product_stack_width = max(product_stack_width, len(product_stack or ""))
            parent_stack_width = max(parent_stack_width, len(parent_stack or ""))

        fmt = "{{0:<{product_stack_width}}} | {{1:<{parent_stack_width}}}".format(
            product_stack_width=product_stack_width,
            parent_stack_width=parent_stack_width
        )

        print(fmt.format("Product Stack", "Parent Stack"))

        for product_stack, parent_stack in results:
            print(fmt.format(product_stack, parent_stack or "(none)"))

        print("")
        print("")


def search_region_for_sc_parent_stacks(region, show_details = False):
    cloudformation = boto3.client("cloudformation", region_name=region)

    stacks = []

    paginator = cloudformation.get_paginator("list_stacks")
    pages = paginator.paginate()

    for page in pages:
        for stack in page["StackSummaries"]:
            if stack["StackStatus"] not in ["DELETE_COMPLETE"]:
                stacks.append(stack)

    sc_stacks = [s["StackName"] for s in stacks if s["StackName"].startswith("SC-")]
    non_sc_stacks = [s["StackName"] for s in stacks if not s["StackName"].startswith("SC-")]

    pp_id_parent_stack_mapping = {}

    if show_details:
        print("- non SC Stacks:")

    for stack in non_sc_stacks:
        if show_details:
            print(f"-- stack: {stack}")

        paginator = cloudformation.get_paginator("list_stack_resources")
        pages = paginator.paginate(StackName=stack)

        for page in pages:
            if show_details:
                print(f"--- page: {page}")

            for resource in page["StackResourceSummaries"]:
                if show_details:
                    print(f"---- resource: {resource}")

                ogical_resource_id = resource.get("LogicalResourceId")
                physical_resource_id = resource.get("PhysicalResourceId")
                resource_type = resource.get("ResourceType")
                last_updated_timestamp =resource.get("LastUpdatedTimestamp")

                if resource_type == "AWS::ServiceCatalog::CloudFormationProvisionedProduct":
                    pp_id_parent_stack_mapping[physical_resource_id] = stack

    product_stack_pp_id_mapping = {}

    expr = re.compile(r'SC-\w+-(pp-\w+).*')

    if show_details:
        print("- SC Stacks:")

    for stack in sc_stacks:
        if show_details:
            print(f"-- stack: {stack}")

        match = expr.match(stack)

        if not match:
            continue

        pp_id = match.group(1)

        product_stack_pp_id_mapping[stack] = pp_id

    results = []

    for product_stack in sc_stacks:
        pp_id = product_stack_pp_id_mapping.get(product_stack)
        parent_stack = pp_id_parent_stack_mapping.get(pp_id)

        results.append((product_stack, parent_stack))

    return results


if __name__ == "__main__":
    main(True)
