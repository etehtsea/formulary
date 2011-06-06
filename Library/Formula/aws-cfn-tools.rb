require 'formula'

# Require ec2-api-tools to get the base class
require "#{File.dirname __FILE__}/ec2-api-tools.rb"

class AwsCfnTools < AmazonWebServicesFormula
  homepage 'http://aws.amazon.com/developertools/AWS-CloudFormation/2555753788650372'
  url 'https://s3.amazonaws.com/cloudformation-cli/AWSCloudFormation-cli.zip'
  version '1.0.7'
  md5 '0ba857ef6beca08c20f5d57a31585098'

  depends_on 'ec2-api-tools'

  def install
    standard_install
  end

  def caveats
    standard_instructions "AWS_CLOUDFORMATION_HOME"
  end
end
