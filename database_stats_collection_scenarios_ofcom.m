%   Amjad Yousef Majid  
%   Reference: [1] "Will Dynamic Spectrum Access Drain my
%   Battery?", submitted for publication, July 2014

%   Code development: 

%   Last update: 22 Dec 2014

%   This work is licensed under a Creative Commons Attribution 3.0 Unported
%   License. Link to license: http://creativecommons.org/licenses/by/3.0/

tic;
clear;
close all;
clc;

%%
%Path to save files (select your own)
my_path='/home/amjed/Documents/Gproject/workspace/data/WSDB_DATA';
type='"AVAIL_SPECTRUM_REQ"';
height='7.5';
%%
    longitude_interval=1;
    no_queries=1; %Number of queries per individual location
    delay_ofcom=[];   
    inx=0; %Initialize position counter
    
    %Location of start and finish query
    %Query start location
    WSDB_data{1}.name='LO'; %London
    WSDB_data{1}.latitude='51.506753';
    WSDB_data{1}.longitude='-0.127686';
    WSDB_data{1}.delay_microsoft=[];
    WSDB_data{1}.delay_ofcom=[];
    
    %Query finish location
    WSDB_data{2}.name='BR'; % Bristol
    WSDB_data{2}.latitude='51.431471';
    WSDB_data{2}.longitude='-2.577637';
    WSDB_data{2}.delay_microsoft=[];
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
                cd([my_path,'/ofcom']);
                [msg_ofcom,delay_ofcom_tmp,error_ofcom_tmp]=...
                    database_connect_ofcom(type,latitude,longitude,height,[my_path,'/ofcom']);
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
        cd([my_path,'/ofcom']);
        %system('rm *');

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