# Terraform-Project
## Objectives of the project
1.	Using Terraform, design and set up a Virtual Private Cloud (VPC) with both public and private subnets. Implement routing, security groups, and network access control lists           (NACLs) to ensure proper communication and security within the VPC and a Ubuntu EC2 instance in each subnet. Work in the AWS us-east-1 region
2.	Write a script to install Nginx on your EC2 instance in the public subnet on deployment
3.	Write a script to install MySQL on your EC2 instance in the public subnet on deployment
4.	Clean up resources on completion using Terraform destroy

### Essential requirements
Create the following files -providers.tf,  main.tf, variables.tf, outputs.tf. Create scripts directory to contain 2 files - install-nginx.sh and install-mysql.sh
Use official Terraform aws provider documentation to create your codes

## Set Up the Terraform Configuration Files
### Create main.tf (Core Infrastructure Setup):
This file will contain the main configuration for your infrastructure, such as creating the VPC, subnets, route tables, security groups, and EC2 instances.

### Create variables.tf (Variable Management):
This file will manage the variables for your Terraform configuration, such as region, instance types, AMIs, etc

![Variable1](https://github.com/user-attachments/assets/53d458e4-4367-47a4-9f65-4b3f7b6005ca)
![Variable2](https://github.com/user-attachments/assets/fead4b01-9937-43b0-a618-145845b89c31)

### Create outputs.tf (Outputs):
This file will output useful information after Terraform has completed, such as instance public IPs or VPC IDs.

![Output](https://github.com/user-attachments/assets/e5ca265c-8754-4456-9c80-46e3ba92d486)


# Configuration procedures

## Create a VPC:
o	Name: MTVPC
o	IPv4 CIDR block: 10.0.0.0/16
VPC resource with cidr_block = "10.0.0.0/16" and tags = { Name = "MTVPC" }. This allocates a large IP range and names the VPC.

![VPC](https://github.com/user-attachments/assets/3584ca91-cade-406e-a7e3-5d676c22bd53)

## Create Subnets:

###	Public Subnet:
§  Name: PublicSubnet
§  IPv4 CIDR block: 10.0.1.0/24
§  Availability Zone: us-east-1a
A subnet resource with cidr_block = "10.0.1.0/24", availability_zone = "us-east-1a", and tags = { Name = "Public-Subnet" }. This configures a subnet in a specified zone with a specific IP range

### Private Subnet:
§  Name: PrivateSubnet
§  IPv4 CIDR block: 10.0.2.0/24
§  Availability Zone: us-east-1a
A subnet resource with cidr_block = "10.0.2.0/24", availability_zone = "us-east-1a", and tags = { Name = "Private-Subnet" }. This sets up a subnet in the specified availability zone with the designated IP range.

![Subnets](https://github.com/user-attachments/assets/a1e195a4-3b58-4f5e-b9ff-07f042432095)

## Configure an Internet Gateway (IGW):
o	Create and attach an IGW to MTVPC.
an IGW using aws_internet_gateway, set vpc_id to VPC (MTVPC), and attach it. This allows resources in the VPC to access the internet. Use tags to name the IGW for easier management.

![IGW](https://github.com/user-attachments/assets/27932263-b265-4bed-b6b8-662283322d25)

## Configure Route Tables:

### Public Route Table:
§  Name: PublicRouteTable
§  Associate PublicSubnet with this route table.
§  Add a route to the IGW (0.0.0.0/0 -> IGW).

a route table using aws_route_table, name it PublicRouteTable, and associate it with the PublicSubnet. Add a route that directs traffic (0.0.0.0/0) to the Internet Gateway (IGW). This configuration enables internet access for the public subnet.

![Public RT](https://github.com/user-attachments/assets/9f6ccc31-ad3a-494b-8379-33830607a735)

### Private Route Table:
§  Name: PrivateRouteTable
§  Associate PrivateSubnet with this route table.
§  Ensure no direct route to the internet.
 A route table with aws_route_table, name it PrivateRouteTable, and associate it with PrivateSubnet. Ensure there are no routes directing traffic to the internet. This setup restricts the private subnet from accessing the internet directly.
 
![Private RT](https://github.com/user-attachments/assets/a0ce83e9-c4cf-4d19-8e05-2cff03013741)

## Configure NAT Gateway
## Create a NAT Gateway in the PublicSubnet.
o	Allocate an Elastic IP for the NAT Gateway.
o	Update the PrivateRouteTable to route internet traffic (0.0.0.0/0) to the NAT Gateway.
Allocate an Elastic IP and associate it with the NAT Gateway in the PublicSubnet. Update the PrivateRouteTable to route internet traffic (0.0.0.0/0) through the NAT Gateway. This setup enables private subnets to access the internet indirectly.

![NAT Gateway](https://github.com/user-attachments/assets/f2d03894-dc0d-47bb-9371-b299ba69e105)


## Set Up Security Groups:
### Create a Security Group for public instances (e.g., web servers):
§  Allow inbound HTTP (port 80) and HTTPS (port 443) traffic from anywhere (0.0.0.0/0).
§  Allow inbound SSH (port 22) traffic from a specific IP (e.g., your local IP). (https://www.whatismyip.com/)
§  Allow all outbound traffic.

A security group allowing inbound HTTP (port 80) and HTTPS (port 443) from anywhere, inbound SSH (port 22) from a specific IP, and permit all outbound traffic. This setup ensures public web access and secure SSH connectivity while enabling unrestricted outbound traffic.

![Public_Security_Group](https://github.com/user-attachments/assets/2593bd1b-d427-4c4a-bcb0-5432f62e9efc)
![Public_SG2](https://github.com/user-attachments/assets/f6269b67-fde2-4472-8686-ec607b59d360)

### Create a Security Group for private instances (e.g., database servers):
§  Allow inbound traffic from the PublicSubnet on required ports (e.g., mySQL port) and allow SSH port 22
§  Allow all outbound traffic.

A security group allowing inbound traffic from the PublicSubnet on specific ports (e.g., MySQL port) and SSH (port 22). Permit all outbound traffic. This configuration secures database servers while enabling necessary connections and unrestricted outbound access.

![Private_Security_Group](https://github.com/user-attachments/assets/06a8b9ba-cf07-46e0-9037-d47528d130b6)
![Private_SG2](https://github.com/user-attachments/assets/d7ca5aeb-9b85-4abc-8752-8b6dc51bbb82)

## Network ACLs:
Configure NACLs for additional security on both subnets.

### Public Subnet NACL: Allow inbound HTTP, HTTPS, and SSH traffic. Allow outbound traffic.

The set rules to allow inbound HTTP (port 80), HTTPS (port 443), and SSH (port 22) traffic. Permit all outbound traffic. This setup ensures public accessibility for web services and allows unrestricted outbound communication.

![Public-NACL](https://github.com/user-attachments/assets/910a03a8-8a8c-4d0e-963f-2f0ba6c548a8)
![Public-NACL2](https://github.com/user-attachments/assets/7bb8be89-dcba-406e-b54f-f8802eb59f29)


### Private Subnet NACL: Allow inbound traffic from the public subnet. Allow outbound traffic to the public subnet and internet.

Allow inbound traffic from the public subnet and outbound traffic to both the public subnet and the internet. This setup permits internal communication and outbound access while ensuring controlled interaction with other network segments and the internet.

![Private-NACL](https://github.com/user-attachments/assets/ca90a484-6ac9-4769-a349-e61b68bdc4b5)

## Create scripts for nginx and mysql
Use Terraform's user_data functionality to pass a script that installs and configures Nginx when the instance boots up.
Similar to the Nginx installation, use Terraform's user_data functionality to pass a script that installs and configures MySQL when the instance boots up.

![nginx](https://github.com/user-attachments/assets/18a269da-86e3-4d10-97af-aa11760eaca7)

![Mysql](https://github.com/user-attachments/assets/fa35ca36-76fd-435f-974c-935791f9f454)

## Deploy Instances:
## Launch an EC2 instance in the PublicSubnet:
## Use the public security group.

![webserver](https://github.com/user-attachments/assets/e05488c4-1357-41a4-8991-dc5626394415)

## Verify that the instance can be accessed via the internet.

##Launch an EC2 instance in the PrivateSubnet:
### Use the private security group.

![db-server](https://github.com/user-attachments/assets/2b50fdf5-1c6a-4313-8e52-53ffdfde0580)

## Verify that the instance can access the internet through the NAT Gateway and can communicate with the public instance.



## Deploying Terraform Project
Open a terminal in VSCode by going to Terminal -> New Terminal.
### Terraform init
Run the Terraform init command to initialize the working directory. This will download the provider plugins and prepare the backend for Terraform

![Terraform-init](https://github.com/user-attachments/assets/ff3a5013-ba02-4518-9203-8a3a4c7e6e9c)

### Terraform fmt
Purpose: Formats your Terraform configuration files.
Details: This command automatically formats .tf files according to the canonical Terraform style, ensuring consistent formatting the codebase. It makes code easier to read and maintain.

![Terraform-fmt](https://github.com/user-attachments/assets/eb62e51e-3a88-4eff-939e-58d1f03b6277)

### Terraform validate
Purpose: Validates your Terraform configuration files.
Details: This command checks Terraform configuration for syntax and logical errors without reaching out to the provider’s API (e.g., AWS). It ensures that your configuration is structurally sound before running any real operations.

![Terraform-validate](https://github.com/user-attachments/assets/f319c734-7228-43a4-8f33-4862c85c5ba9)

### Terraform plan -out=tfplan.txt
Purpose: Creates an execution plan and saves it to a file.
Details: This command generates a plan showing the changes Terraform will make to your infrastructure. By using the -out flag, you save the plan to a file (tfplan.txt). This allows you to review and apply the plan later, ensuring that you apply exactly what was planned.

![Terraform plan -out tfplan](https://github.com/user-attachments/assets/99c69a90-865d-40d8-a4fb-a7560e80fdd6)
![Terraform plan -out tfplan2](https://github.com/user-attachments/assets/04c2e826-2ccd-4ce6-b075-95e23925823f)
![Terraform plan -out tfplan3](https://github.com/user-attachments/assets/7dcc2e08-fe1e-4cbf-89c7-d615bb76c0e4)

### Terraform apply tfplan.txt
Purpose: Applies the changes specified in the saved execution plan.
Details: This command uses the execution plan file (tfplan.txt) generated by the plan command to make changes to our infrastructure. By applying the saved plan, you ensure that only the changes defined in that plan are executed, avoiding potential discrepancies if the plan is regenerated.

![Terraform apply tfplan txt](https://github.com/user-attachments/assets/8a2edf1f-0e9d-4c0c-be2e-a2bad4c8490b)

##Final output on the AWS

![Screenshot (149)](https://github.com/user-attachments/assets/b7f61110-2336-42f7-9dff-a694ea011f0b)

![Screenshot (150)](https://github.com/user-attachments/assets/55ff2b23-150c-4686-aef5-30da43629bbb)

![Screenshot (157)](https://github.com/user-attachments/assets/d6bd4469-fde4-492a-ba12-e0b7e4374ec8)

![Screenshot (158)](https://github.com/user-attachments/assets/f49949a5-bbd9-4062-bcd0-a8fdf575ec51)

![Screenshot (151)](https://github.com/user-attachments/assets/51ef2e97-3e5e-4894-be60-8d7e7ec8b4e4)

![Screenshot (152)](https://github.com/user-attachments/assets/a3ed1a71-9489-46b5-ab9e-c290321f8f24)

![Screenshot (153)](https://github.com/user-attachments/assets/f1833d19-460c-4a7b-abba-5ffcd6105f0d)

![Screenshot (154)](https://github.com/user-attachments/assets/0c6799c5-7419-439a-ab9f-ab4901bc9d04)

![Screenshot (155)](https://github.com/user-attachments/assets/ae74cd07-75d2-4fe1-aa5c-916e1a3f733c)

![Screenshot (156)](https://github.com/user-attachments/assets/f3ab6f09-b449-4170-acda-490a2edbd8a2)


## To Clean up resources on completion
### terraform destroy

![Screenshot (159)](https://github.com/user-attachments/assets/9ce596fd-bd5f-41b8-8772-0cd2f9415d12)
![Screenshot (160)](https://github.com/user-attachments/assets/bee262d5-049e-4fb8-b132-4d9b97e1cfd0)
![Screenshot (161)](https://github.com/user-attachments/assets/8c571858-5f47-42c2-aa25-2c5b17e6cae0)
![Screenshot (162)](https://github.com/user-attachments/assets/f15f5288-6fc9-400f-b1af-606543cb0d11)






