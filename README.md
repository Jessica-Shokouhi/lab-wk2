---

# lab-wk3

Our team successfully created a VPC, public subnet, security group, S3 bucket, and an EC2 instance. We also imported an SSH key and connected to the EC2 instance.  

## Team Members
- Jessica
- Cole
- Kyle

---

## Scripts and Outputs

### 1. import-key.sh
Imports an SSH public key into AWS so we can connect to EC2 instances.

```bash
#!/usr/bin/env bash
set -eu

err() {
  error_messsage="$@"
  echo -e "\033[1;31m ERROR:\033[0m ${error_messsage}" >&2
  exit 1
}

public_key_file=""

if [[ $# -ne 1 ]]; then
  err "script requires the path to the public key file you would like to import"
fi

if [[ ! -f $1 ]]; then
  err "path to public key for import is incorrect, file does not exist"
else
  public_key_file="$1"
fi

aws ec2 import-key-pair --key-name "bcitkey" --public-key-material fileb://${public_key_file} > key_data
````

**Output (`key_data`):**

```json
{
  "KeyFingerprint": "yztEio3gkbQi4DvFSLsJ5uIhjnnMf1RRHR4gZKsNs+8=",
  "KeyName": "bcitkey",
  "KeyPairId": "key-09bb99f3ab8f006a7"
}
```

**Documentation:** [import-key-pair](https://docs.aws.amazon.com/cli/latest/reference/ec2/import-key-pair.html)

---

### 2. create-bucket.sh

Creates an S3 bucket in **us-west-2** if it doesn’t already exist.

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bucket_name>"
    exit 1
fi

bucket_name=$1

if aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
    echo "Bucket $bucket_name already exists."
else
  aws s3api create-bucket \
    --bucket "$bucket_name" \
    --region us-west-2 \
    --create-bucket-configuration LocationConstraint=us-west-2 \
    > bucket_data

  echo "Bucket $bucket_name created."
fi
```

**Output (`bucket_data`):**

```json
{ 
  "Location": "http://jessica-bucket-3420.s3.amazonaws.com/", 
  "BucketArn": "arn:aws:s3:::jessica-bucket-3420"
}
```

**Documentation:** [create-bucket](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html)

---

### 3. create-vpc.sh

Creates a VPC with a public subnet, internet gateway, and route table. Writes IDs to `infrastructure_data`.

```bash
#!/usr/bin/env bash
set -euo pipefail

region="us-west-2"
vpc_cidr="10.0.0.0/16"
subnet_cidr="10.0.1.0/24"

vpc_id=$(aws ec2 create-vpc --cidr-block $vpc_cidr --query 'Vpc.VpcId' --output text --region $region)
aws ec2 create-tags --resources $vpc_id --tags Key=Name,Value=MyVPC --region $region
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-hostnames Value=true

subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id \
  --cidr-block $subnet_cidr \
  --availability-zone ${region}a \
  --query 'Subnet.SubnetId' \
  --output text --region $region)
aws ec2 create-tags --resources $subnet_id --tags Key=Name,Value=PublicSubnet --region $region

igw_id=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' \
  --output text --region $region)
aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $igw_id --region $region

route_table_id=$(aws ec2 create-route-table --vpc-id $vpc_id \
  --query 'RouteTable.RouteTableId' \
  --region $region \
  --output text)
aws ec2 associate-route-table --subnet-id $subnet_id --route-table-id $route_table_id --region $region
aws ec2 create-route --route-table-id $route_table_id \
  --destination-cidr-block 0.0.0.0/0 --gateway-id $igw_id --region $region

echo "vpc_id=${vpc_id}" > infrastructure_data
echo "subnet_id=${subnet_id}" >> infrastructure_data
```

**Output (`infrastructure_data`):**

```
vpc_id=vpc-005889f22c09c3e72
subnet_id=subnet-0097cb0f4e5724619
```

**Documentation:** [create-vpc](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-vpc.html), [create-subnet](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-subnet.html), [create-internet-gateway](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-internet-gateway.html)

---

### 4. create-ec2.sh

Launches an EC2 instance in the public subnet using the Debian AMI, security group, and imported key. Writes public IP to `instance_data`.

```bash
#!/usr/bin/env bash
set -euo pipefail

region="us-west-2"
key_name="bcitkey"

source ./infrastructure_data

debian_ami=$(aws ec2 describe-images \
  --owners "136693071363" \
  --filters 'Name=name,Values=debian-*-amd64-*' 'Name=architecture,Values=x86_64' 'Name=virtualization-type,Values=hvm' \
  --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
  --output text)

security_group_id=$(aws ec2 create-security-group --group-name MySecurityGroup \
 --description "Allow SSH and HTTP" --vpc-id $vpc_id --query 'GroupId' \
 --region $region --output text)

aws ec2 authorize-security-group-ingress --group-id $security_group_id \
 --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $region

aws ec2 authorize-security-group-ingress --group-id $security_group_id \
 --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $region

instance_id=$(aws ec2 run-instances \
  --image-id "$debian_ami" \
  --instance-type t3.micro \
  --security-group-ids "$security_group_id" \
  --subnet-id "$subnet_id" \
  --associate-public-ip-address \
  --key-name "$key_name" \
  --region "$region" \
  --query 'Instances[0].InstanceId' \
  --output text)

aws ec2 wait instance-running --instance-ids "$instance_id"

public_ip=$(aws ec2 describe-instances \
  --instance-ids "$instance_id" \
  --region "$region" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "$public_ip" > instance_data
```

**Output (`instance_data`):**

```
54.218.43.226
```

**SSH Test:**

```bash
ssh -i <your-private-key> admin@54.218.43.226
```

* Successfully connected and verified Debian 11 (bullseye) running.

**Documentation:** [run-instances](https://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html), [describe-instances](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html)

<img width="2194" height="1052" alt="image" src="https://github.com/user-attachments/assets/228e3471-fb21-4084-a043-8cc76428d122" />


---

