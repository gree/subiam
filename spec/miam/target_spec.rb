describe 'specify target' do
  let(:dsl_another_prefix) do
    <<-RUBY
      user "another-prefix-bob", :path=>"/devloper/" do
        login_profile :password_reset_required=>true

        groups(
          "another-prefix-Admin",
          "another-prefix-SES"
        )

        policy "S3" do
          {"Statement"=>
            [{"Action"=>
               ["s3:Get*",
                "s3:List*"],
              "Effect"=>"Allow",
              "Resource"=>"*"}]}
        end
      end

      user "another-prefix-mary", :path=>"/staff/" do
        policy "S3" do
          {"Statement"=>
            [{"Action"=>
               ["s3:Get*",
                "s3:List*"],
              "Effect"=>"Allow",
              "Resource"=>"*"}]}
        end
      end

      group "another-prefix-Admin", :path=>"/admin/" do
        policy "Admin" do
          {"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}
        end
      end

      group "another-prefix-SES", :path=>"/ses/" do
        policy "ses-policy" do
          {"Statement"=>
            [{"Effect"=>"Allow", "Action"=>"ses:SendRawEmail", "Resource"=>"*"}]}
        end
      end

      role "another-prefix-my-role", :path=>"/any/" do
        instance_profiles(
          "another-prefix-my-instance-profile"
        )

        assume_role_policy_document do
          {"Version"=>"2012-10-17",
           "Statement"=>
            [{"Sid"=>"",
              "Effect"=>"Allow",
              "Principal"=>{"Service"=>"ec2.amazonaws.com"},
              "Action"=>"sts:AssumeRole"}]}
        end

        policy "role-policy" do
          {"Statement"=>
            [{"Action"=>
               ["s3:Get*",
                "s3:List*"],
              "Effect"=>"Allow",
              "Resource"=>"*"}]}
        end
      end

      instance_profile "another-prefix-my-instance-profile", :path=>"/profile/"
    RUBY
  end

  let(:expected) do
    {:users=>
         {"another-prefix-bob"=>
              {:path=>"/devloper/",
               :groups=>["another-prefix-Admin", "another-prefix-SES"],
               :attached_managed_policies=>[],
               :policies=>
                   {"S3"=>
                        {"Statement"=>
                             [{"Action"=>["s3:Get*", "s3:List*"],
                               "Effect"=>"Allow",
                               "Resource"=>"*"}]}},
               :login_profile=>{:password_reset_required=>true}},
          "another-prefix-mary"=>
              {:path=>"/staff/",
               :groups=>[],
               :attached_managed_policies=>[],
               :policies=>
                   {"S3"=>
                        {"Statement"=>
                             [{"Action"=>["s3:Get*", "s3:List*"],
                               "Effect"=>"Allow",
                               "Resource"=>"*"}]}}}},
     :groups=>
         {"another-prefix-Admin"=>
              {:path=>"/admin/",
               :attached_managed_policies=>[],
               :policies=>
                   {"Admin"=>
                        {"Statement"=>[{"Effect"=>"Allow", "Action"=>"*", "Resource"=>"*"}]}}},
          "another-prefix-SES"=>
              {:path=>"/ses/",
               :attached_managed_policies=>[],
               :policies=>
                   {"ses-policy"=>
                        {"Statement"=>
                             [{"Effect"=>"Allow",
                               "Action"=>"ses:SendRawEmail",
                               "Resource"=>"*"}]}}}},
     :policies=>{},
     :roles=>
         {"another-prefix-my-role"=>
              {:path=>"/any/",
               :assume_role_policy_document=>
                   {"Version"=>"2012-10-17",
                    "Statement"=>
                        [{"Sid"=>"",
                          "Effect"=>"Allow",
                          "Principal"=>{"Service"=>"ec2.amazonaws.com"},
                          "Action"=>"sts:AssumeRole"}]},
               :instance_profiles=>["another-prefix-my-instance-profile"],
               :attached_managed_policies=>[],
               :policies=>
                   {"role-policy"=>
                        {"Statement"=>
                             [{"Action"=>["s3:Get*", "s3:List*"],
                               "Effect"=>"Allow",
                               "Resource"=>"*"}]}}}},
     :instance_profiles=>{"another-prefix-my-instance-profile"=>{:path=>"/profile/"}}}
  end

  before(:each) do
    c = client(target: nil)
    apply(c) { dsl_another_prefix }
  end

  context 'apply when empty dsl to exists environment' do
    subject { client(target: /^iam-test-/) }

    it 'should change nothing' do
      updated = apply(subject) { '' }
      expect(updated).to be_falsey
      expect(export).to eq expected
    end
  end
end
