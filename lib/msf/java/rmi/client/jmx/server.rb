# -*- coding: binary -*-

module Msf
  module Java
    module Rmi
      module Client
        module Jmx
          module Server
            require 'msf/java/rmi/client/jmx/server/builder'
            require 'msf/java/rmi/client/jmx/server/parser'

            include Msf::Java::Rmi::Client::Jmx::Server::Builder
            include Msf::Java::Rmi::Client::Jmx::Server::Parser

            # Sends a call to the JMXRMI endpoint to retrieve an MBean instance. Simulates a call
            # to the Java javax/management/remote/rmi/RMIServer_Stub#newClient()
            # method.
            #
            # @param opts [Hash]
            # @option opts [Rex::Socket::Tcp] :sock
            # @return [Hash, NilClass] The connection information if success, nil otherwise
            # @raise [Rex::Proto::Rmi::Exception] if the endpoint raises a remote exception
            # @see Msf::Java::Rmi::Client::Registry::Builder.build_jmx_new_client
            def send_new_client(opts = {})
              send_call(
                sock: opts[:sock] || sock,
                call: build_jmx_new_client(opts)
              )

              return_value = recv_return(
                sock: opts[:sock] || sock
              )

              if return_value.nil?
                return nil
              end

              if return_value.is_exception?
                raise ::Rex::Proto::Rmi::Exception, return_value.get_class_name
              end

              remote_object = return_value.get_class_name

              unless remote_object && remote_object == 'javax.management.remote.rmi.RMIConnectionImpl_Stub'
                return nil
              end

              reference = parse_jmx_new_client_endpoint(return_value)

              reference
            end
          end
        end
      end
    end
  end
end
