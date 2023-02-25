% UplinkRx - Uplink Receiver
% Performs CSI Estimation and other processing of the uplink signal
% received from Mobile Stations.
function CSI = UplinkRx(ULRx_Stream, System_Parameters)
    % Number of users being served by Base Station (BS)
    numUsers = System_Parameters.numUsers;
    
    % OFDM Modulation parameters
    N = System_Parameters.OFDM.N;
    cp = System_Parameters.OFDM.cp;
    DataCarriers = System_Parameters.OFDM.DataCarriers;
    
    CSI = zeros(numUsers, 1); 

    % OFDM Demodulation
    ULRx_User = ULRx_Stream(cp + 1: N + cp, :);
    ULRx_User = fft(ULRx_User, N);
    ULRx_User = circshift(ULRx_User, N / 2);
    
    % Iterate over each user and perform CSI estimation using ZC Seq as
    % reference signal.
    for iter_user = 1: numUsers
        ULRx_User_Data = ULRx_User(DataCarriers, iter_user);
        CSI(iter_user, 1) = mean(ULRx_User_Data .* conj(System_Parameters.ULTx.zcSeq(:, iter_user)) ./ (abs(System_Parameters.ULTx.zcSeq(:, iter_user)) .^ 2));
    end
    
end