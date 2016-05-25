module Subiam::DSL::Helper
  module Arn
    private

    def arn_policy_by_aws(name)
      "arn:aws:iam::aws:policy/#{name}"
    end

    def arn_policy_by_current_account(name)
      "arn:aws:iam::#{current_account}:policy/#{name}"
    end

    def current_account
      if @current_account
        return @current_account
      end
      aws_config = (@context.options && @context.options[:aws_config]) ? @context.options[:aws_config] : {}
      sts = Aws::STS::Client.new(aws_config)
      @current_account = sts.get_caller_identity.user_id
    end
  end
end