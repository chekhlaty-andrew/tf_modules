aws s3api list-buckets --query "Buckets[].Name"

aws s3 ls s3://andrew-chekhlatyy-lessons-tfstate/uat/network/
aws s3 cp s3://andrew-chekhlatyy-lessons-tfstate/uat/network/terraform.tfstate terraform-uat.tfstate