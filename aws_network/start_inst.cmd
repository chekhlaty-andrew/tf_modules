terraform.exe    apply --var-file="uat.auto.tfvars"  -auto-approve  
rem terraform output -raw data_aws_rds_password
rem terraform init  -backend-config=backend-uat.conf   -reconfigure 2>1