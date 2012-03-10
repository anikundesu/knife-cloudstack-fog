class Chef
  class Knife
    class CloudstackVolumeList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack volume list (options)"
      def run

        validate!

        volume_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Size', :bold),
          ui.color('Type', :bold),
          ui.color('State', :bold),
        ]
        response = connection.list_templates['listvolumesresponse']
        puts response
        if volumes = response['volume']
        end
          
    end
  end
end