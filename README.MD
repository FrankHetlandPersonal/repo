```console
rm -rf .terraform
terraform init -backend-config=bucket=<BUCKET> -backend-config=key=<PATHINBUCKET>
terraform plan 
```
