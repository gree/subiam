describe 'style' do
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

  context 'Symbol keys in policies' do
    it "should coverted to String keys" do
      parsed = parse { dsl }
      parsed.delete(:target)
      expect(parsed).to eq expected
    end
  end
end