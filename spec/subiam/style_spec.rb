describe 'style' do
  context 'Symbol keys in policies' do
    let(:dsl) do
      <<-RUBY
        user "iam-test-bob", :path=>"/devloper/" do
          login_profile :password_reset_required=>true

          groups(
            "iam-test-Admin",
            "iam-test-SES"
          )

          policy "S3" do
            {Statement:
              [{Action:
                 ["s3:Get*",
                  "s3:List*"],
                Effect: "Allow",
                Resource: "*"}]}
          end
        end

        user "iam-test-mary", :path=>"/staff/" do
          policy "S3" do
            {Statement:
              [{Action:
                 ["s3:Get*",
                  "s3:List*"],
                Effect: "Allow",
                Resource: "*"}]}
          end
        end

        group "iam-test-Admin", :path=>"/admin/" do
          policy "Admin" do
            {Statement: [{Effect: "Allow", Action: "*", Resource: "*"}]}
          end
        end

        group "iam-test-SES", :path=>"/ses/" do
          policy "ses-policy" do
            {Statement:
              [{Effect: "Allow", Action: "ses:SendRawEmail", Resource: "*"}]}
          end
        end

        role "iam-test-my-role", :path=>"/any/" do
          instance_profiles(
            "iam-test-my-instance-profile"
          )

          assume_role_policy_document do
            {Version: "2012-10-17",
             Statement:
              [{Sid: "",
                Effect: "Allow",
                Principal: {"Service"=>"ec2.amazonaws.com"},
                Action: "sts:AssumeRole"}]}
          end

          policy "role-policy" do
            {Statement:
              [{Action:
                 ["s3:Get*",
                  "s3:List*"],
                Effect: "Allow",
                Resource: "*"}]}
          end
        end

        instance_profile "iam-test-my-instance-profile", :path=>"/profile/"
      RUBY
    end

    let(:expected) do
      {:users =>
           {"iam-test-bob" =>
                {:path => "/devloper/",
                 :groups => ["iam-test-Admin", "iam-test-SES"],
                 :attached_managed_policies => [],
                 :policies =>
                     {"S3" =>
                          {"Statement" =>
                               [{"Action" => ["s3:Get*", "s3:List*"],
                                 "Effect" => "Allow",
                                 "Resource" => "*"}]}},
                 :login_profile => {:password_reset_required => true}},
            "iam-test-mary" =>
                {:path => "/staff/",
                 :groups => [],
                 :attached_managed_policies => [],
                 :policies =>
                     {"S3" =>
                          {"Statement" =>
                               [{"Action" => ["s3:Get*", "s3:List*"],
                                 "Effect" => "Allow",
                                 "Resource" => "*"}]}}}},
       :groups =>
           {"iam-test-Admin" =>
                {:path => "/admin/",
                 :attached_managed_policies => [],
                 :policies =>
                     {"Admin" =>
                          {"Statement" => [{"Effect" => "Allow", "Action" => "*", "Resource" => "*"}]}}},
            "iam-test-SES" =>
                {:path => "/ses/",
                 :attached_managed_policies => [],
                 :policies =>
                     {"ses-policy" =>
                          {"Statement" =>
                               [{"Effect" => "Allow",
                                 "Action" => "ses:SendRawEmail",
                                 "Resource" => "*"}]}}}},
       :policies => {},
       :roles =>
           {"iam-test-my-role" =>
                {:path => "/any/",
                 :assume_role_policy_document =>
                     {"Version" => "2012-10-17",
                      "Statement" =>
                          [{"Sid" => "",
                            "Effect" => "Allow",
                            "Principal" => {"Service" => "ec2.amazonaws.com"},
                            "Action" => "sts:AssumeRole"}]},
                 :instance_profiles => ["iam-test-my-instance-profile"],
                 :attached_managed_policies => [],
                 :policies =>
                     {"role-policy" =>
                          {"Statement" =>
                               [{"Action" => ["s3:Get*", "s3:List*"],
                                 "Effect" => "Allow",
                                 "Resource" => "*"}]}}}},
       :instance_profiles => {"iam-test-my-instance-profile" => {:path => "/profile/"}}}
    end

    it "should coverted to String keys" do
      parsed = parse { dsl }
      parsed.delete(:target)
      expect(parsed).to eq expected
    end
  end

  context 'ARN helpers' do
    let(:dsl) do
      <<-RUBY
        user "iam-test-bob", :path=>"/devloper/" do
          attached_managed_policies(
            arn_policy_by_aws("AdministratorAccess"),
            arn_policy_by_current_account("MyPolicy")
          )
        end

        group "iam-test-Admin", :path=>"/admin/" do
          attached_managed_policies(
            arn_policy_by_aws("AdministratorAccess"),
            arn_policy_by_current_account("MyPolicy")
          )
        end

        role "iam-test-my-role", :path=>"/any/" do
          attached_managed_policies(
            arn_policy_by_aws("AdministratorAccess"),
            arn_policy_by_current_account("MyPolicy")
          )

          assume_role_policy_document do
            {Version: "2012-10-17",
             Statement:
              [{Sid: "",
                Effect: "Allow",
                Principal: {"Service"=>"ec2.amazonaws.com"},
                Action: "sts:AssumeRole"}]}
          end
        end
      RUBY
    end

    it "should convert policy names to arn" do
      parsed = parse { dsl }
      expect(parsed[:users]["iam-test-bob"][:attached_managed_policies][0]).to eq "arn:aws:iam::aws:policy/AdministratorAccess"
      expect(parsed[:groups]["iam-test-Admin"][:attached_managed_policies][0]).to eq "arn:aws:iam::aws:policy/AdministratorAccess"
      expect(parsed[:roles]["iam-test-my-role"][:attached_managed_policies][0]).to eq "arn:aws:iam::aws:policy/AdministratorAccess"

      expect(parsed[:users]["iam-test-bob"][:attached_managed_policies][1]).to match %r(arn:aws:iam::\d+:policy/MyPolicy)
      expect(parsed[:groups]["iam-test-Admin"][:attached_managed_policies][1]).to match %r(arn:aws:iam::\d+:policy/MyPolicy)
      expect(parsed[:roles]["iam-test-my-role"][:attached_managed_policies][1]).to match %r(arn:aws:iam::\d+:policy/MyPolicy)
    end
  end
end