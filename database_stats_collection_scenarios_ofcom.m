% This script output/plot the delay and delay destribtion of the response time of querying Ofcom WSDB.
%   Last update: 10 January 2015

% Reference:
%   P. Pawelczak et al. (2014), "Will Dynamic Spectrum Access Drain my
%   Battery?," submitted for publication.

%   Code development: Amjed Yousef Majid (amjadyousefmajid@student.tudelft.nl),
%                     Przemyslaw Pawelczak (p.pawelczak@tudelft.nl)

% Copyright (c) 2014, Embedded Software Group, Delft University of
% Technology, The Netherlands. All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
% HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
% TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
tic;
clear;
close all;
clc;
%%
%Path to save files (select your own)
my_path='/home/amjed/Documents/Gproject/workspace/data/WSDB_DATA';
% Query params
request_type='"AVAIL_SPECTRUM_REQ"';
orientation= 45;
semiMajorAxis = 50;
SemiMinorAxis = 50;
start_freq = 470000000;
stop_freq = 790000000;
height=7.5;
heightType = '"AGL"';
%%
longitude_interval=100; % the number of intervals
no_queries=20; %Number of queries per individual location
delay_ofcom=[];
inx=0; %Initialize position counter

%Location of start and finish query
%Query start location
WSDB_data{1}.name='LO'; %London
WSDB_data{1}.latitude='51.506753';
WSDB_data{1}.longitude='-0.127686';
WSDB_data{1}.delay_ofcom=[];

%Query finish location
WSDB_data{2}.name='BR'; % Bristol
WSDB_data{2}.latitude='51.431471';
WSDB_data{2}.longitude='-2.577637';
WSDB_data{2}.delay_ofcom=[];

longitude_start=str2num(WSDB_data{1}.longitude); %Start of the spectrum scanning trajectory
longitude_end=str2num(WSDB_data{2}.longitude); %End of spectrum scanning trajectory

longitude_step=(longitude_end-longitude_start)/longitude_interval;

for xx=longitude_start:longitude_step:longitude_end
    inx=inx+1;
    iny=0; %Initialize query counter
    for yy=1:no_queries
        iny=iny+1;
        fprintf('[Query no., Location no.]: %d, %d\n',iny,inx);
        %Fetch location data
        latitude=WSDB_data{1}.latitude; % latitude is fixed
        longitude=num2str(xx);
        %Query ofcom
        fprintf('ofcom\n')
        instant_clock=clock; %Start clock again if scanning only one database
        cd(my_path);
        
        [msg_ofcom,delay_ofcom_tmp,error_ofcom_tmp]=...
            database_connect_ofcom(request_type,latitude,longitude,orientation,...
            semiMajorAxis,SemiMinorAxis,start_freq,stop_freq,height,heightType,my_path);
        
        var_name=(['ofcom_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        if error_ofcom_tmp==0
            dlmwrite([var_name,'.txt'],msg_ofcom,'');
            delay_ofcom=[delay_ofcom,delay_ofcom_tmp];
        end
    end
    %%
    %Assign delay per location per WSDB to a new variable
    delay_ofcom_loc{inx}=delay_ofcom;
    delay_ofcom=[];
end
%%
%Compute means of queries per location
Vm_ofcom=[];
for xx=1:inx
    mtmp_ofcom=delay_ofcom_loc{xx};
    Vm_ofcom=[Vm_ofcom,mean(mtmp_ofcom)];
end
%Clear old query results
cd(my_path);
%%
%Plot distribution curves
%Plot figures
figure
[fg,xg]=ksdensity(Vm_ofcom,'support','positive');
fg=fg./sum(fg);
plot(xg,fg , 'g-', 'LineWidth' , 2);
xlabel('Response time (sec)');
figure
plot(Vm_ofcom , 'r-' , 'LineWidth' , 2);
xlabel('Number of location');
ylabel('Response time (sec)');
%% statistical results
ave_delay = mean(Vm_ofcom)
std_delay = std(Vm_ofcom)
%%
['Elapsed time: ',num2str(toc/60),' min']