module AWS
  class EC2
    class Instance
      def contact_point
        public_dns_name || public_ip_address || private_ip_address
      end
    end
  end
end