---

````markdown
# Lab Week 3 - AWS CLI

 Our team successfully created a VPC, public subnet, security group, S3 bucket, and an EC2 instance. We also imported an SSH key and connected to the EC2 instance.  

## Team Members
- Jessica
- Kyle
- Cole

---

## Scripts

### 1. import-key.sh
Imports an SSH public key into our AWS account so we can connect to EC2 instances.  

**Usage:**  
```bash
./import-key.sh <path-to-your-public-key>
````

**Output:**

* `key_data` file with the imported key info.

**AWS CLI documentation used:**

* [import-key-pair](https://docs.aws.amazon.com/cli/latest/reference/ec2/import-key-pair.html)

---

### 2. create-bucket.sh

Creates an S3 bucket in **us-west-2** if it doesn’t already exist.

**Usage:**

```bash
./create-bucket.sh <unique-bucket-name>
```

**Output:**

* `bucket_data` file with bucket location and ARN.

**AWS CLI documentation used:**

* [create-bucket](https://docs.aws.amazon.com/cli/latest/reference/s3api/create-bucket.html)

**Example output (`bucket_data`):**

```json
{
  "Location": "http://jessica-bucket-3420.s3.amazonaws.com/",
  "BucketArn": "arn:aws:s3:::jessica-bucket-3420"
}
```

---

### 3. create-vpc.sh

Creates a VPC with a public subnet, internet gateway, and route table. Writes IDs to `infrastructure_data`.

**Output (`infrastructure_data`):**

```
vpc_id=vpc-005889f22c09c3e72
subnet_id=subnet-0097cb0f4e5724619
```

**AWS CLI documentation used:**

* [create-vpc](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-vpc.html)
* [create-subnet](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-subnet.html)
* [create-internet-gateway](https://docs.aws.amazon.com/cli/latest/reference/ec2/create-internet-gateway.html)

---

### 4. create-ec2.sh

Launches an EC2 instance in the public subnet using:

* the Debian AMI
* the security group created in the script
* the key pair imported with `import-key.sh`

It writes the **public IP** to `instance_data`.

**Output (`instance_data`):**

```
54.218.43.226
```

**AWS CLI documentation used:**

* [run-instances](https://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html)
* [describe-instances](https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-instances.html)

**SSH Test:**

```bash
ssh -i <your-private-key> admin@54.218.43.226
```

* We successfully connected to the EC2 instance and verified Debian was running.

---

```

---
```
