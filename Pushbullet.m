classdef Pushbullet < handle
    %Pushbullet Connect to pushbullet and send notes/links/files to the
    %connected smartphone as a push notification
    %   Detailed explanation goes here
    
    properties
        HOST = 'https://api.pushbullet.com/v2'
        DEVICES_URL = '/devices'
        CONTACTS_URL = '/contacts'
        ME_URL = '/users/me'
        PUSH_URL = '/pushes'
        UPLOAD_REQUEST_URL = '/upload-request'
        ApiKey
        Devices
    end
    
    methods
        
        function self = Pushbullet(apikey)
            self.ApiKey = apikey;
        end
        
        function load_devices(self)
            % Get a list of devices
            output = urlread([self.HOST,self.DEVICES_URL],...
                'Authentication','Basic',...
                'Username',self.ApiKey,'Get',{});
            output_converted = json_parser(output);
            self.Devices = output_converted{1}.devices;
            for i=1:length(self.Devices)
                display(self.Devices{i}.nickname)
            end
        end
            
        
        function output = pushNote(self, device_iden, title, message)
            % Push a note
            % https://docs.pushbullet.com/v2/pushes
            % Arguments:
            % device_iden -- iden of device to push to
            % title -- a title for the note
            % body -- the body of the note

            data = {'type', 'note',...
                'device_iden',device_iden,...
                'title', title,...
                'body', message};
            
            if isempty(device_iden)
                data(3:4) = []; %delete device_iden in data -> push to all connected devices
            end
            
            output = push(self, data);
        end
 
                      
        function output = pushPic(self, device_iden, file_name, file_type, file_url)
            % Push a picture
            % https://docs.pushbullet.com/v2/pushes
            % Arguments:
            % device_iden -- iden of device to push to
            % file_name -- the name for the file
            % file_type -- The MIME type of the file (for example
            % 'image/png')
            % file_url -- the url of the file

            data = {'type','file',...
                    'device_iden',device_iden,...
                    'file_name',file_name,...
                    'file_type',file_type,...
                    'file_url',file_url};
                
            if isempty(device_iden)
                data(3:4) = []; %delete device_iden in data -> push to all connected devices
            end

            output = push(self, data);
        end
        
        function output = push(self, data)
            % Perform the POST Request
            output = urlread([self.HOST,self.PUSH_URL],...
                            'Authentication','Basic',...
                            'Username',self.ApiKey,...
                            'Post',data);
        end
        
        % HELPER FUNCTIONS
        function get_device_iden_from_nickname(self, nickname)
            if isempty(self.Devices)
                load_devices(self)
            end
            if ~isempty(self.Devices)
                for i=1:length(self.Devices)
                    if strcmp(self.Devices{i}.nickname, nickname)
                        device_iden = self.Devices{i}.iden;
                    end
                end
            end
        end       
    
    end
    
end

