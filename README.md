# Enterprise Terraform 
## Cumberland Cloud Platform
## AWS Core - S3

This is the baseline module for a **S3** bucket on the **Cumberland Cloud Platform**. It has been setup with ease of deployment in mind, so that platform compliant simple storage space be easily provisioned with minimum configuration.

### Usage

The bare minimum deployment can be achieved with the following configuration,

**providers.tf**

```
provider "aws" {
	region					= "<region-name>"

	assume_role {
		role_arn 			= "arn:aws:iam::<tenant-account>:role/<role-name>"
	}
}
```

**modules.tf**

```
module "s3" {
	source          		= "ssh://git@github.com:cumberland-terraform/storage-s3.git"
	
	platform 				= {
		aws_region      	= "<aws-region>"
    	account         	= "<account>"
    	acct_env        	= "<account-env>"
    	agency          	= "<agency>"
    	program         	= "<program>"
    	pca             	= "<pca>"
	}

	s3						= {
		purpose             = "<purpose>"
	}

}
```

`platform` is a parameter for *all* **cumberland-cloud** modules. See the platform module documentation for more information.,

### Parameters

The `s3` object represents the configuration for a new deployment. Only one fields is absolutely required: `purpose`. See previous section for example usage. The following bulleted list shows the entire hierarchy of allowed values for the `s3` object fields and their purpose,

- `purpose`: TODO
- `name_override`: TODO
- `suffix`: TODO
- `acl`: TODO
- `kms_key`: TODO
	- `aws_managed`: TODO
	- `id`: TODO
	- `arn`: TODO
	- `alias_arn`: TODO
- `logging`: TODO
- `notification`: TODO
- `notification_events`: TODO
- `policy`: TODO
- `replicas`: TODO
- `replication_role`: TODO
	- `arn`: TODO
	- `id`: TODO
	- `name`: TODO
- `website_configuration`: TODO
	- `enabled`: TODO
	- `index_document`: TODO
		- `suffix`: TODO
	- `error_document`: TODO
		`key`: TODO

## KMS Key Deployment Options

### 1: Module Provisioned Key

If the `var.s3.kms_key` is set to `null` (default value), the module will attempt to provision its own KMS key. This means the role assumed by Terraform in the `provider` 

### 2: User Provided Key

If the user of the module prefers to use a pre-existing customer managed key, the `id`, `arn` and `alias_arn` of the `var.s3.kms_key` variable must be passed in. This will override the provisioning of the KMS key inside of the module.

### 3: AWS Managed Key

If the user of the module prefers to use an AWS managed KMS key, the `var.s3.kms_key.aws_managed` property must be set to `true`.

## Contributing

The below instructions are to be performed within Unix-style terminal. 

It is recommended to use Git Bash if using a Windows machine. Installation and setup of Git Bash can be found [here](https://git-scm.com/downloads/win)

### Step 1: Clone Repo

Clone the repository. Details on the cloning process can be found [here](https://support.atlassian.com/bitbucket-cloud/docs/clone-a-git-repository/)

If the repository is already cloned, ensure it is up to date with the following commands,

```bash
git checkout master
git pull
```

### Step 2: Create Branch

Create a branch from the `master` branch. The branch name should be formatted as follows:

	feature/<TICKET_NUMBER>

Where the value of `<TICKET_NUMBER>` is the ticket for which your work is associated. 

The basic command for creating a branch is as follows:

```bash
git checkout -b feature/<TICKET_NUMBER>
```

For more information, refer to the documentation [here](https://docs.gitlab.com/ee/tutorials/make_first_git_commit/#create-a-branch-and-make-changes)

### Step 3: Commit Changes

Update the code and commit the changes,

```bash
git commit -am "<TICKET_NUMBER> - description of changes"
```

More information on commits can be found in the documentation [here](https://docs.gitlab.com/ee/tutorials/make_first_git_commit/#commit-and-push-your-changes)

### Step 4: Merge With Master On Local


```bash
git checkout master
git pull
git checkout feature/<TICKET_NUMBER>
git merge master
```

For more information, see [git documentation](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)


### Step 5: Push Branch to Remote

After committing changes, push the branch to the remote repository,

```bash
git push origin feature/<TICKET_NUMBER>
```

### Step 6: Pull Request

Create a pull request. More information on this can be found [here](https://www.atlassian.com/git/tutorials/making-a-pull-request).

Once the pull request is opened, a pipeline will kick off and execute a series of quality gates for linting, security scanning and testing tasks.

### Step 7: Merge

After the pipeline successfully validates the code and the Pull Request has been approved, merge the Pull Request in `master`.

After the code changes are in master, the new version should be tagged. To apply a tag, the following commands can be executed,

```bash
git tag v1.0.1
git push tag v1.0.1
```

### Pull Request Checklist

Ensure each item on the following checklist is complete before updating any tenant deployments with a new version of this module,

- [] Merge `master` into `feature/*` branch
- [] Open PR from `feature/*` branch into `master` branch
- [] Get approval from owner
- [] Merge into `master`
- [] Increment `git tag` version