

% UplinkTx - Uplink Transmission
% Performs OFDM Modulation of ZC Sequences for each users meant for uplink
% transmission. This will be used as Reference signal for CSI Estimation
function ULTX_Stream = UplinkTx(System_Parameters)
    % Number of users being served by Base Station (BS)
    numUsers = System_Parameters.numUsers;
    
    % OFDM Modulation parameters
    OFDM = System_Parameters.OFDM;
    N = OFDM.N;
    cp = OFDM.cp;
    ULTx = System_Parameters.ULTx;
    
    % Buffers for OFDM Frame and Datastream
    ULTX_Frame = zeros(N, numUsers);
    ULTX_Stream = zeros((N + cp), numUsers);
    
   
   
    
    % OFDM Modulation
   
   
    ULTX_Frame(OFDM.DataCarriers, :) = ULTx.zcSeq;
    disp(size(ULTX_Frame))
    ULTX_Frame = circshift(ULTX_Frame, N / 2);
    disp('After Shift')
    disp(size(ULTX_Frame))
       
    ULTX_Frame = ifft(ULTX_Frame, N);
    

    %disp(ULTX_Frame)
    
    for iter_user = 1: numUsers 
        ULTX_Stream(1: cp, iter_user) = ULTX_Frame(end - cp + 1: end, iter_user);
        ULTX_Stream(cp + 1: N + cp, iter_user) = ULTX_Frame(:, iter_user);
    end

end