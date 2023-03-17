% Transmitter: Performs data processing operations like power allocation,
%              channel coding, qam modulation, etc. at the Transmitter End
% Input: data, System_Parameters
%        data           - A matrix containing information of multiple user
%                         where each user is assigned one column.
%        System_Parameters       - A structure containing system parameters like
%                         number of users, code rate, qam alphabet etc.
%
% Output: modDataStream - A column vector containing qam modulated information of
%                         the user data (after additional processing like
%                         channel coding, scrambling, etc).
%

function [modDataStream, System_Parameters] = Transmitter(data, System_Parameters)  
    %% Channel Coding
    
    % Allocating buffer for encoding
    encodedData = zeros(System_Parameters.dataLength / System_Parameters.coding.codeRate, System_Parameters.numUsers);
    for iter_user = 1:System_Parameters.numUsers
        encodedData(:, iter_user) = Encoding(data(:, iter_user), System_Parameters);
    end
    
    %% QAM
    modData = qammod(encodedData, System_Parameters.QAM, 'InputType', 'bit', 'UnitAveragePower', 1);
    
    %% Power Allocation    
    
    % User Pairing
    System_Parameters.userPairs = zeros(System_Parameters.numUsers / 2, 2);
    
    for iter_pairs = 1: System_Parameters.numUsers / 2
        System_Parameters.userPairs(iter_pairs, 1) = System_Parameters.sorted_CSI_Idx(iter_pairs);
        System_Parameters.userPairs(iter_pairs, 2) = System_Parameters.sorted_CSI_Idx(System_Parameters.numUsers - iter_pairs + 1);
    end
    % Calculate Power coefficients for each pair
    System_Parameters.powerCoeffs = zeros(System_Parameters.numUsers, 1);
    
        for iter_pairs = 1: System_Parameters.numUsers / 2
            System_Parameters.powerCoeffs(System_Parameters.userPairs(iter_pairs, 1), 1) = (sqrt(1 + System_Parameters.sysPower * abs(System_Parameters.est_CSI(System_Parameters.userPairs(iter_pairs, 2), 1)) .^ 2) - 1) / (System_Parameters.sysPower * abs(System_Parameters.est_CSI(System_Parameters.userPairs(iter_pairs, 2), 1)));
            System_Parameters.powerCoeffs(System_Parameters.userPairs(iter_pairs, 2), 1) = System_Parameters.sysPower - System_Parameters.powerCoeffs(System_Parameters.userPairs(iter_pairs, 1), 1);
        end
   

    
    % Assign them to OFDM
    N = System_Parameters.OFDM.N;
    cp = System_Parameters.OFDM.cp;
    numOFDMSyms = System_Parameters.slotLen;
    
    % Creating the Superposed Data Matrix
    modDataMat = zeros(size(System_Parameters.userPairs, 1), numOFDMSyms);

    
    for iter_pairs = 1: System_Parameters.numUsers / 2
        modDataMat(iter_pairs, :) = sqrt(System_Parameters.powerCoeffs(System_Parameters.userPairs(iter_pairs, 1), 1)) * modData(:, System_Parameters.userPairs(iter_pairs, 1));
        modDataMat(iter_pairs, :) = modDataMat(iter_pairs, :) + sqrt(System_Parameters.powerCoeffs(System_Parameters.userPairs(iter_pairs, 2), 1)) * modData(:, System_Parameters.userPairs(iter_pairs, 2))';
    end
        
    modDataFrame = zeros(N, numOFDMSyms);
    modDataStream = zeros(N + cp, numOFDMSyms); 

 
    %disp(height(modDataFrame) +""+ width(modDataFrame))
    
    modDataFrame(System_Parameters.OFDM.DataCarriers(1: size(modDataMat, 1)), :) = modDataMat;
    modDataFrame = fftshift(modDataFrame);
    modDataFrame = ifft(modDataFrame, N) * sqrt(N);
    
    modDataStream(1:cp, :) = modDataFrame(end - cp + 1: end, :);
    modDataStream(cp + 1: end, :) = modDataFrame;
    
    modDataStream = modDataStream(:);


    %disp(modDataStream)
    
end