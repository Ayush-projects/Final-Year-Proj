% Receiver: Performs data processing operations like SIC,
%           channel decoding, qam demodulation, etc at the receiver end.
% Input: rxDataStreamMat, System_Parameters
%        rxDataStreamMat - A qam modulated data stream containing information
%                          of multiple users
%        System_Parameters        - A structure containing system parameters like
%                          number of users, code rate, qam alphabet etc.
%
% Output: data -          A matrix containing infrmation of multiple user
%                         where each user is assigned one column.
%

function data = Receiver(rxDataStream, System_Parameters)
    
   
    %disp(height(rxDataStream))
    % System Parameters
    N = System_Parameters.OFDM.N;
    cp = System_Parameters.OFDM.cp;
    numOFDMSyms = System_Parameters.slotLen;

    data = zeros(System_Parameters.dataLength, System_Parameters.numUsers);
    
    % OFDM Demodulator
    modDataMat = zeros(N, numOFDMSyms);
    
    for iter_syms = 1: numOFDMSyms
        currSym = rxDataStream((iter_syms - 1) * (N + cp) + cp + 1: iter_syms * (N + cp), 1);
        modDataMat(:, iter_syms) = currSym;
    end
    
    modDataMat = fft(modDataMat, N) / sqrt(N);
    modDataMat = fftshift(modDataMat);
    
    % Extracting Superposed Signal
    modDataMat = modDataMat(System_Parameters.OFDM.DataCarriers(1: System_Parameters.numUsers / 2), :);
%    disp(width(modDataMat))
    % SIC
    for iter_pairs = 1: System_Parameters.numUsers / 2
        pair_data = modDataMat(iter_pairs, :)';
        for iter_user = 1: 2
            H = System_Parameters.CSI(System_Parameters.userPairs(iter_pairs, iter_user));
            H_hat = System_Parameters.est_CSI(System_Parameters.userPairs(iter_pairs, iter_user));
   
            
            %disp(pair_data)
            if(iter_user == 2) 
                pair_data = pair_data_copy;
            end

            pair_data = H * pair_data; % Adding Channel effect
            pair_data = pair_data / H_hat; % Equalising Channel effect
            for iter_sic = 1: iter_user
                %disp("ok"+iter_sic)
                pair_data_copy = pair_data;
                P = System_Parameters.powerCoeffs(System_Parameters.userPairs(iter_pairs, iter_sic), 1);
                %disp(P)
                demodData = qamdemod(pair_data ./ sqrt(P), System_Parameters.QAM, 'UnitAveragePower', 1, 'OutputType', 'approxllr');
                usr_data = Decoding(demodData, System_Parameters);

                enc_data = Encoding(usr_data, System_Parameters);
                modData = qammod(enc_data, System_Parameters.QAM, 'UnitAveragePower', 1, 'InputType', 'bit');

                pair_data = pair_data - H_hat * sqrt(P) * modData;
            end
            data(:, System_Parameters.userPairs(iter_pairs, iter_user)) = usr_data;
           % disp(usr_data)
        end
    end
    
end