# Excercise Statement

1. Create IAC using terraform for:
- Python script that creates a file with random data and uploads it to an s3 bucket
- Script will run within a lambda
- Lambda is triggered via API gateway
- API gateway has a custom domain
- S3 bucket where data is dumped is in another AWS account
2. Deployment done via terraform + github actions.

----

# Solution

Following is a quick overview of the solution provided:

- Created a Lambda function which triggers a python script to create a file of randomly generated data into an S3 bucket belonging to a different account
- The lambda function is accessible via an API Gateway ELB, although whilst this is working when testing in AWS it has not been linked to a custom domain
- A GitHub action has been created to perform a plan when a PR is generated and an apply on merge.


# Points of note

The following points are in reflection of the above solution:

- Not having my own domain meant I have been unable to test the Terraform for that part, though custom domain aside, it's working as expected
- I was unable to fully test the GitHub Actions fully as the plan failed because of the provider profiles I'd created to deal with two different AWS account:
  - I could have implemented an AWS organisation and OUs. This would have enabled me to use a root account user. I did not do this as only one account in an organisation is able to make use of the free tier credits.
  - I could have implemented OIDC and used IAM roles but my GitHub account is a personal and not an organisational account


# Improvements

If time had allowed, I would have like to have completed the following:

- Improve the re-usability of the Terraform:
  - Split the Terraform into modules, one for each component being created
  - Configure the variables into tfvars files, which then overwrite the defaults values configured
  - Review where the use of locals could have helped with the readability of the code
- The S3 bucket name is static in the Terraform code. Not only would I configure a variable for this, but I would also consider using the random provider to create a random string to append to the bucket name in order to make it globally unique.
- I have retained the same object name in the S3 bucket, so each time the script runs, it replaces the object. This could be adjusted to create a new object each time. Object versioning and lifecycle rules could then be implemented.
- Comment the code further to help someone follow what's going to be build. I would also use more tags on the AWS side.
- Implement tighter security:
  - Lock down the roles created to implement the least privilage use approach
