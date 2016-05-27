# Subiam

Subiam is a tool to manage IAM.

It defines the state of IAM using DSL, and updates IAM according to DSL.

It's forked from Miam. Miam is designed to manage all IAM entities in the AWS account. Subiam is not so. Subiam is designed to manage sub part of IAM entities in the AWS account. For example around MySQL instances / around web servers / around lambda functions / around monitoring systems.

**Notice**
* `>= 1.3.0`
  * Specify default region: `ap-northeast-1`. User does't have to specify region unless using isolated AWS region like GovCloud.

* `>= 1.2.0`
  * Add helper methods: `arn_policy_by_aws`, `arn_policy_by_current_account`

* `>= 1.1.0`
  * Rename `require` DSL command to `import` to avoid override Kernel#require
  * Allow Symbols alternative to Strings at Hash keys. It's a bit easy to write!

* `>= 1.0.0`
  * Forked from miam
  * Required to specify `target` in DSL or json
  * `instance_profile` also follow target (bug fix)
  * don't delete top level entity (user, group, role, instance_profile) by default. Use the `--enable-delete` option.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'subiam'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install subiam

## Usage

```sh
export AWS_ACCESS_KEY_ID='...'
export AWS_SECRET_ACCESS_KEY='...'
vi subiam-xxx.rb
subiam -a --dry-run subiam-xxx.rb
subiam -a subiam-xxx.rb
```

## Help

```
Usage: subiam [options]
    -p, --profile PROFILE_NAME
        --credentials-path PATH
    -k, --access-key ACCESS_KEY
    -s, --secret-key SECRET_KEY
    -r, --region REGION              default: ap-northeast-1
    -a, --apply
    -f, --file FILE                  Specify the file path to apply.
        --dry-run
        --account-output FILE
    -e, --export
    -o, --output FILE                Specify the file path to export current IAM settings.
        --split
        --split-more
        --format FORMAT
                                     ruby or json. (default: ruby)
        --export-concurrency N
        --ignore-login-profile
        --no-color
        --no-progress
        --debug
        --enable-delete
                                     Enable to delete top level elements. (default: false)
```

## IAM definition files example
subiam_mytool.rb

```ruby
import 'subiam_ec2_assume_role_attrs.rb'

target /^mytool/ # required!!!

role 'mytool', path: '/' do
  context.version = '2012-10-17'

  include_template 'ec2-assume-role-attrs'

  instance_profiles(
    'mytool'
  )

  policy 'mytool-role-policy' do
    {
      Version: context.version,
      Statement: [
        {
          Effect: "Allow",
          Action: [
            "ec2:DescribeInstances",
            "ec2:DescribeVpcs"
          ],
          Resource: [
            "*"
          ]
        },
        {
          Effect: "Allow",
          Action: [
            "route53:Get*",
            "route53:List*",
            "route53:ChangeResourceRecordSets*"
          ],
          Resource: [
            "*"
          ]
        },
      ],
    }
  end
end

instance_profile 'mytool', path: '/'

```

subiam_ec2_assume_role_attrs.rb

```ruby
template "ec2-assume-role-attrs" do
  assume_role_policy_document do
    {
      Version: context.version,
      Statement: [
        {
          Sid: "",
          Effect: "Allow",
          Principal: {Service: "ec2.amazonaws.com"},
          Action: "sts:AssumeRole",
        },
      ],
    }
  end
end
```

## General example (User / Group / Role)

```ruby
import 'other/iamfile'

target /.*/ # managing IAMs whole account

user "monitoring-bob", path: "/monitoring-user/" do
  login_profile password_reset_required: true

  groups(
    "Admin"
  )

  policy "bob-policy" do
    {Version: "2012-10-17",
     Statement:
      [{Action:
         ["s3:Get*",
          "s3:List*"],
        Effect: "Allow",
        Resource: "*"}]}
  end

  attached_managed_policies(
    # attached_managed_policy
  )
end

user "mary", path: "/staff/" do
  # login_profile password_reset_required: true

  groups(
    # no group
  )

  policy "s3-readonly" do
    {Version: "2012-10-17",
     Statement:
      [{Action:
         ["s3:Get*",
          "s3:List*"],
        Effect: "Allow",
        Resource: "*"}]}
  end

  policy "route53-readonly" do
    {Version: "2012-10-17",
     Statement:
      [{Action:
         ["route53:Get*",
          "route53:List*"],
        Effect: "Allow",
        Resource: "*"}]}
  end

  attached_managed_policies(
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:iam::123456789012:policy/my_policy"
  )
end

group "Admin", path: "/admin/" do
  policy "Admin" do
    {Statement: [{Effect: "Allow", Action: "*", Resource: "*"}]}
  end
end

role "S3", path: "/" do
  instance_profiles(
    "S3"
  )

  assume_role_policy_document do
    {Version: "2012-10-17",
     Statement:
      [{Sid: "",
        Effect: "Allow",
        Principal: {Service: "ec2.amazonaws.com"},
        Action: "sts:AssumeRole"}]}
  end

  policy "S3-role-policy" do
    {Version: "2012-10-17",
     Statement: [{Effect: "Allow", Action: "*", Resource: "*"}]}
  end
end

instance_profile "S3", path: "/"
```

## Rename

```ruby
user "bob2", path: "/developer/", renamed_from: "bob" do
  # ...
end

group "Admin2", path: "/admin/", renamed_from: "Admin" do
  # ...
end
```

## Managed Policy attach/detach

```ruby
user "bob", path: "/developer/" do
  login_profile password_reset_required: true

  groups(
    "Admin"
  )

  policy "bob-policy" do
    # ...
  end

  attached_managed_policies(
    "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
  )
end
```

## Custom Managed Policy

```ruby
managed_policy "my-policy", path: "/" do
  {Version: "2012-10-17",
   Statement:
    [{Effect: "Allow", Action: "directconnect:Describe*", Resource: "*"}]}
end

user "bob", path: "/developer/" do
  login_profile password_reset_required: true

  groups(
    "Admin"
  )

  policy "bob-policy" do
    # ...
  end

  attached_managed_policies(
    "arn:aws:iam::123456789012:policy/my-policy"
  )
end
```

## Use JSON

```sh
$ subiam -e -o iam.json
   ᗧ 100%
Export IAM to `iam.json`

$ cat iam.json
{
  "users": {
    "bob": {
      "path": "/",
      "groups": [
        "Admin"
      ],
      "policies": {
      ...

$ vi iam.json # add target
$ subiam -a -f iam.json --dry-run
Apply `iam.json` to IAM (dry-run)
   ᗧ 100%
No change
```

## Use Template

```ruby
template "common-policy" do
  policy "my-policy" do
    {Version: context.version,
     Statement:
      [{Action:
         ["s3:Get*",
          "s3:List*"],
        Effect: "Allow",
        Resource: "*"}]}
  end
end

template "common-role-attrs" do
  assume_role_policy_document do
    {Version: context.version,
     Statement:
      [{Sid: "",
        Effect: "Allow",
        Principal: {Service: "ec2.amazonaws.com"},
        Action: "sts:AssumeRole"}]}
  end
end

user "bob", path: "/developer/" do
  login_profile password_reset_required: true

  groups(
    "Admin"
  )

  include_template "common-policy", version: "2012-10-17"
end

user "mary", path: "/staff/" do
  # login_profile password_reset_required: true

  groups(
    # no group
  )

  context.version = "2012-10-17"
  include_template "common-policy"

  attached_managed_policies(
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:iam::123456789012:policy/my_policy"
  )
end

role "S3", path: "/" do
  instance_profiles(
    "S3"
  )

  include_template "common-role-attrs"

  policy "S3-role-policy" do
    {Version: "2012-10-17",
     Statement: [{Effect: "Allow", Action: "*", Resource: "*"}]}
  end
end
```

## Use management policy

```ruby
user "foo", path: '/' do
  attached_managed_policies(
    'arn:aws:iam::0123456789:policy/MyPolicy',

    arn_policy_by_current_account("MyPolicy2"),
    # == "arn:aws:iam::0123456789:policy/MyPolicy2'

    arn_policy_by_aws("AdministratorAccess")
    # == 'arn:aws:iam::aws:policy/AdministratorAccess'
  )
end
```

## Similar tools
* [Codenize.tools](http://codenize.tools/)
