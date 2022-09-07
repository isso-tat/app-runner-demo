# Run example

```
cd example

tfenv install

env AWS_PROFILE=your_profile terraform init
env AWS_PROFILE=your_profile terraform plan
env AWS_PROFILE=your_profile terraform apply

// Deploy other than nginx
env AWS_PROFILE=your_profile TF_VAR_image_dir=php_apache terraform apply
```

# Curl request test

```
curl -w "@curl-format.txt" -o /dev/null -s "https://********.us-east-1.awsapprunner.com"
```
