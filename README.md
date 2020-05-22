### Prerequisites

- create AWS account

https://aws.amazon.com/resources/create-account/

- AWS CLI

https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html

https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html

- terraform CLI

https://www.terraform.io/downloads.html

Terraform is distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's PATH .

- Docker (step is optional for training with Docker)

https://docs.docker.com/docker-for-windows/install/

https://docs.docker.com/docker-for-mac/install/

- Configuration

- clone repository to local computer
  - git clone 

- create aws_configure.sh in main folder (where this README.md file exists)
  please do not enter values, creds will be available after IAM introduction and creation of user in IAM

```
#!/usr/bin/env bash
export AWS_ACCESS_KEY_ID=user access key id
export AWS_SECRET_ACCESS_KEY=user secret access key
export AWS_DEFAULT_REGION=aws region
```

- prepare github account
  - create one if you have not
  - create personal acces token
  
    https://github.com/settings/tokens/new
    
    name docker
    
    select:
    
    - write:packages
     
    - read:packages
     
    - delete:packages
     
    write token to file, for example ~/TOKEN.txt (if it is different - update docker_build.sh script)

- fork repository in github (step is optional for training with Docker)

- update scripts docker_build.sh - update GITHUB_USER, GITHUB_OWNER and GITHUB_REPOSITORY (step is optional for training with Docker)
    