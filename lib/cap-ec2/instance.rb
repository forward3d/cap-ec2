# Monkey patch the AWS SDK to return a variable
# "contact point" we can reach the server on
module AWS
  class EC2
    class Instance
      def contact_point
        public_dns_name || public_ip_address || private_ip_address
      end
    end
  end
end