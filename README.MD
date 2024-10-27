# aws-privatelink-protocol-tester
- [Overview](#overview)
  - [Goals](#goals)
  - [Key Features](#key-features)
  - [Project Structure](#project-structure)
  - [Important Notes](#important-notes)
  - [Considerations](#considerations)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage)
  - [TO DO](#to-do)
  - [Contributing](#contributing)
  - [Disclaimer](#disclaimer)
  - [License](#license)

![aws-privatelink-protocol-tester](img/aws-privatelink-protocol-tester-highlevel.png)

# Overview 

This repository contains Terraform configuration files and various scripts for setting up a test environment to test AWS Privatelink Service Providers and Consumers.

# Goals

- Test UDP Behind privatelink :no_entry_sign:
  - UDP Does not work; 
    ```
    Error: creating EC2 VPC Endpoint Service: operation error EC2: CreateVpcEndpointServiceConfiguration, https response error StatusCode: 400, RequestID: 8fae1f50-a53d-465b-974d-6ae00ced277e, api error InvalidParameter: Network load balancer with arn "arn:aws:elasticloadbalancing:us-east-1:<ACCOUNT>:loadbalancer/net/udp-nlb/0cbd4b49473868f3" has UDP listeners. Privatelink does not support UDP.
    ```
    > https://docs.aws.amazon.com/vpc/latest/privatelink/concepts.html#concepts-service-consumers
    > - Interface - Create an interface endpoint to send ***TCP*** traffic to an endpoint service.
- Collect flow logs and analyze.
- Test TCP FO through privatelink. 
- Test http headers through privatelink.
- Try non-http protocols through privatelink. :white_check_mark:
- Create diagram based on logs
- Provide cost estimate breakdown

## Key Features
- Builds consumer/producer vpc endpoints and privatelink services as well as the supporting infrastructure to test. 

## Project Structure
```
aws-privatelink-protocol-tester/
├── img/
├── scripts/
│   ├── consumer_ec2.sh    # Consumer startup script
│   ├── producer_ec2.sh    # Producer startup script
├── ec2.tf                 # Terraform configuration file for defining EC2 instances and related resources.
├── iam.tf                 # Terraform configuration file for defining IAM roles, policies, and profiles.
├── nlb.tf                 # Terraform configuration file for defining NLB, listeners and target groups.
├── privatelink.tf         # Terraform configuration file for defining AWS PrivateLink endpoints and related resources.
├── README.md              # Markdown file for documenting the project, including descriptions of files and usage.
├── sg.tf                  # Terraform configuration file for defining security groups and their rules.
├── variables.tf           # Terraform configuration file for defining variable declarations.
├── vpc.tf                 # Terraform configuration file for defining VPC, subnets, and related networking resources.
```

## Important Notes


## Considerations
- **DO NOT RUN THIS IN A PRODUCTION ENVIRONMENT**
- Take these results with a grain of salt and do your own thorough testing with your own test cases.
- More tests are needed, such as working scenarios of cross-account access and commands that succeed fully.
- This is as far as I am in my learning journey, hopefully this helps yours and I appreciate any feedback.

## Prerequisites

1. An AWS account an api keys with access
2. Github account with Github Actions
3. Git installed
4. An ssh/scp client (to login/export results)


## Usage

 - After resources are created, ssh into the consumer ec2 instance via the provided output for the elastic IP. 
 - Once you are logged in, you can run the VPC Privatelink Tester script using: 

```bash
python aws_privatelink_protocol_tester.py [OPTIONS]
```

For available options, run:

```bash
python aws_privatelink_protocol_tester.py --help
    Usage: aws_privatelink_protocol_tester.py [OPTIONS]

    Options:
    --log          Generate a full log file with $day/hour/minute-log.txt.
    --report       Generate a CSV report with $day/hour/minute-report.csv.
    --both         Generate both log and report files.
    --shell        Output only to the shell without writing any files.
    
    Examples:
    python aws_privatelink_protocol_tester.py --log
    python aws_privatelink_protocol_tester.py --report
    python aws_privatelink_protocol_tester.py --both
    python aws_privatelink_protocol_tester.py --shell
```

## TO DO:
 - Automated flow log and report creation in script
    - consumer script runs and ends with sleep 15(or whatever time it takes for flow logs to populate?)
    - after sleep pulls flow logs into csv along with report and saves to file. 
 - Billing monitoring
    - Automatically pull billing activity during testing to be saved with repo for review later. 


## Contributing

Feel free to submit issues, create pull requests, or fork the repository to help improve the project.

## Disclaimer

This project is for testing and educational purposes only. The author is not responsible for any misuse or damage caused by this tool. Use at your own risk and always test in a safe, non-production environment.

## License

[MIT License](LICENSE)