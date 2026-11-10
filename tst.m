close all
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Definition of Main simulations parameters %%%%

x_max=1000; % Definition of Area in meters (x-axes)
y_max=1000; % Definition of Area in meters (y-axes)
Number_MS=100; % Number of MS in the system level simulation
Number_BS=4; % Number of BS in the system level simulation
f=2; % carrier frequency in GHz
BW = 50*10.^6;  % channel bandwidth
Pt_BS=35;  %transmission power of base station in dBm
Pt_MS=23;  %transmission power of MS (in dBm)

%%%% Definition of Main simulations parameters %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

PosBS = [250 250 30; 250 750 30; 750 250 30; 750 750 30]; % fixed position of SBSs

PosMS=MS_position(x_max,y_max,Number_MS); % using function for generation of initial coordinates of MSs
d = distance(Number_MS,Number_BS,PosMS,PosBS);

% calculation of noise
N_W = (BW*4*10.^-12)/10.^9; % noise [W]
N_dBm = 10*log10(N_W/0.001); % noise [dBm]



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Calculation of PL, RSS, SNR, association of MSs to BSs, SINR %%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Calculation of PL, RSS, SNR, association of MSs to BSs, SINR %%%%

% 1. Path Loss [dB]
PL = 35.2 + 35*log10(d) + 26*log10(f/2);

% 2. Received Signal Strength (Downlink) [dBm]
RSS = Pt_BS - PL;

% 3. Signal to Noise Ratio [dB]
SNR = RSS - N_dBm;

% 4. Association based on Max RSS
[max_RSS, BS_assoc] = max(RSS, [], 2);

% 5. SINR [dB]
RSS_W = 0.001 * 10.^(RSS ./ 10); % Convert dBm to Watts
SINR = zeros(Number_MS, 1);

for i = 1:Number_MS
    serving_bs = BS_assoc(i);
    interf_W = sum(RSS_W(i, :)) - RSS_W(i, serving_bs);
    NI_W = interf_W + N_W;
    NI_dBm = 10 * log10(NI_W / 0.001);
    SINR(i) = RSS(i, serving_bs) - NI_dBm;
end

%%%% Calculation of PL, RSS, SNR, association of MSs to BSs, SINR %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Calculation of PL, RSS, SNR, association of MSs to BSs, SINR %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plot of Figure %%%%

figure(1)
hold on;
axis([0 x_max 0 y_max]);
plot (PosBS(1:4,1), PosBS(1:4,2),'o')
text(PosBS(1:4,1),PosBS(1:4,2),'BS')
h1=zeros(Number_MS,1);

%%% NOTE: BS_assoc includes association information (i.e., index of BS to which each MS is connected)
%Template randomly generates association, delete lines 52-56 and replace by correct association!!!!

BS_assoc=zeros(Number_MS,1);
for i=1:Number_MS
   BS_assoc(i,1)= ceil(4*rand); 
end

for j=1:Number_MS
    if BS_assoc(j,1)==1
        h1(j,1)=plot (PosMS(j,1), PosMS(j,2),'xr'); % plot of MS location
        h1(j,2)=plot([PosMS(j,1) PosBS(BS_assoc(j,1),1)],[PosMS(j,2) PosBS(BS_assoc(j,1),2)], 'r'); % plot of connecting line between MS and BS (basically x and y coordinates of beginning and end of line)
    end
    if BS_assoc(j,1)==2
        h1(j,1)=plot (PosMS(j,1), PosMS(j,2),'xb');
        h1(j,2)=plot([PosMS(j,1) PosBS(BS_assoc(j,1),1)],[PosMS(j,2) PosBS(BS_assoc(j,1),2)], 'b');
    end
    if BS_assoc(j,1)==3
        h1(j,1)=plot (PosMS(j,1), PosMS(j,2),'xg');
        h1(j,2)=plot([PosMS(j,1) PosBS(BS_assoc(j,1),1)],[PosMS(j,2) PosBS(BS_assoc(j,1),2)], 'g');
    end
    if BS_assoc(j,1)==4
        h1(j,1)=plot (PosMS(j,1), PosMS(j,2),'xm');
        h1(j,2)=plot([PosMS(j,1) PosBS(BS_assoc(j,1),1)],[PosMS(j,2) PosBS(BS_assoc(j,1),2)], 'm');
    end
end

print('-f1', '-r300', '-dpng','Association_BS');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Bonus: Flying Base Stations %%%%%%

Number_FBS = 4;
% Cluster MSs based on 2D coordinates
[ID_cluster, PosFBS_2D] = kmeans(PosMS(:, 1:2), Number_FBS);

% Set altitude z = 30m
PosFBS = [PosFBS_2D, 30 * ones(Number_FBS, 1)];

% Plot Bonus Figure
figure(2)
hold on;
axis([0 x_max 0 y_max]);
plot(PosFBS(:, 1), PosFBS(:, 2), 'k^', 'MarkerSize', 10, 'LineWidth', 2);
text(PosFBS(:, 1), PosFBS(:, 2), ' FBS', 'FontWeight', 'bold');

colors = ['r', 'b', 'g', 'm'];
for j = 1:Number_MS
    c_idx = ID_cluster(j);
    plot(PosMS(j, 1), PosMS(j, 2), ['x', colors(c_idx)]);
    plot([PosMS(j, 1), PosFBS(c_idx, 1)], [PosMS(j, 2), PosFBS(c_idx, 2)], colors(c_idx));
end
title('MS Association to Flying Base Stations (K-Means Centroids)');
print('-f2', '-r300', '-dpng', 'Association_FBS');





