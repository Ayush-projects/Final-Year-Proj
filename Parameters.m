function System_Parameters = Parameters()

    System_Parameters.QAM = 4;
    System_Parameters.softQAM = 1;
    
    % SNR Config
    System_Parameters.SNRdb = 10;
    System_Parameters.SNR = 10 ^ (System_Parameters.SNRdb / 10);
    

    % Ye samajna hoga
    % Trellis Structure for 1/2 code rate convolution coder obtained from
    % a MATLAB tutorial on channel coding. (Constraint length, M = 7)
    System_Parameters.coding.cc.trellis = poly2trellis(7, {'1 + x^3 + x^4 + x^5 + x^6', '1 + x + x^3 + x^4 + x^6'});
    System_Parameters.coding.cc.tbl = 32;
    System_Parameters.coding.codeRate = 1/2;
    
    % Length of each message of every user
    System_Parameters.dataLength = 300;
    
    
    System_Parameters.slotLen = System_Parameters.dataLength;
    % Number of users
    System_Parameters.numUsers = 2;
    
    %% Power Allocation
    % We calculate the optimal values for power allocation coefficients using
    % the method of Lagrange Multipliers. 

    % The total power available for allocation
    System_Parameters.sysPower = 1; 

    System_Parameters.pwrAllocMthd = 1;
    
    % Guard wala hata denge 
    %% OFDM Symbol Structure
    OFDM.N = 16;
    OFDM.cp = OFDM.N / 8;
    OFDM.GuardInt1 = 0;
    OFDM.GuardInt2 = 0;
    OFDM.DCSpacing = 5;
    OFDM.DCSpacingCarriers = OFDM.N / 2 - ((OFDM.DCSpacing - 1) / 2): OFDM.N / 2 + ((OFDM.DCSpacing - 1) / 2); 
    OFDM.numDataCarriers = OFDM.N - OFDM.GuardInt1 - OFDM.GuardInt2 - OFDM.DCSpacing;
    OFDM.DataCarriers = setdiff(1:OFDM.N, OFDM.DCSpacingCarriers);
    System_Parameters.OFDM = OFDM;
    
   %% Uplink Transmission Parameters

    ULTx.zcRoots = nthprime(1: System_Parameters.numUsers + 1);
    ULTx.zcLen = OFDM.numDataCarriers;
    ULTx.zcRoots = setdiff(ULTx.zcRoots, [ULTx.zcLen]);
    ULTx.zcSeq = zeros(ULTx.zcLen, System_Parameters.numUsers);
    
    for iter_user = 1: System_Parameters.numUsers
        ULTx.zcSeq(:, iter_user) = zadoffChuSeq(ULTx.zcRoots(iter_user), ULTx.zcLen);
    end
    System_Parameters.ULTx = ULTx;
    
end