function Main()
% The function "Main" is the main body of code that the program executes. 

    sysPower = 1; 
    % Defining a variable 'sysPower' and assigning it a value of 1. 

    %% System Initialisation
    % Initializing all system parameters at the start of the program.

    % rng function is used to control the random number generation process.
    % Here, seed is set to 65
    rng(65);

    % Calling the Parameters function to initialize all system parameters.
    System_Parameters = Parameters();
    
    %% Uplink Channel Estimation

    % Simulating UE Uplink Tx
    % Setting the values of N and cp to be equal to the ones defined in the system parameters.
    N = System_Parameters.OFDM.N;
    cp = System_Parameters.OFDM.cp;
    
    % Generating a Uplink Stream for each UE using the 'UplinkTx' function.
    ULTx_Stream = UplinkTx(System_Parameters);
    
    % Adding a single tap Rayleigh fading channel and AWGN noise to the data stream.
    % Creating a CSI (Channel State Information) matrix with complex Gaussian entries.
    System_Parameters.CSI = (1 / sqrt(2)) * (randn(1, System_Parameters.numUsers) + 1i * randn(1, System_Parameters.numUsers));
    % Creating AWGN (Additive White Gaussian Noise) that will be used to corrupt the signal.
    UL_Noise = (1 / sqrt(2 * System_Parameters.SNR * N)) * (randn((N + cp), System_Parameters.numUsers) + 1i * randn((N + cp), System_Parameters.numUsers));
    % Applying the CSI and AWGN to the uplink data stream using element-wise multiplication.
    ULRx_Stream = ULTx_Stream .* System_Parameters.CSI + UL_Noise;
    
    % Estimating CSI (channel state information) of each UE from the uplink data.
    System_Parameters.est_CSI = UplinkRx(ULRx_Stream, System_Parameters);

    [~, System_Parameters.sorted_CSI_Idx] = sort(System_Parameters.est_CSI, 'descend'); 
    
    %% Generating Data 

    % Generating random data
    txBitStreamMat = randi([0, 1], System_Parameters.dataLength - System_Parameters.coding.cc.tbl, System_Parameters.numUsers);
    disp(size(txBitStreamMat))
    txBitStreamMat = [txBitStreamMat; zeros(System_Parameters.coding.cc.tbl, System_Parameters.numUsers)];
     disp(size(txBitStreamMat))
    %% Data Processing at Tx
    % Passing the generated data through the transmitter.

    [txOut, System_Parameters] = Transmitter(txBitStreamMat, System_Parameters);

    %% Channel Model

    % For Simulation purposes, the flat fading channel will added at the receiver
    
    % Noise

    SNR = System_Parameters.SNR;
    noise = (sqrt(sysPower) / sqrt(2 * SNR)) .* (randn(size(txOut)) + (1i) * randn(size(txOut)));
    
    % Combining the transmitted signal with AWGN noise.
   rxDataStream = txOut + noise;


    %% Receiver
    % Detecting the information from received signal
    % Decoding the data at the receiver using the 'Receiver' function.
    rxBitStreamMat = Receiver(rxDataStream, System_Parameters);

    % Calculating the number of bits in error between the transmitted and received data.
    errBits = sum(bitxor(txBitStreamMat, rxBitStreamMat));
    disp('Sorted CSI values for the two users: ')
    disp(System_Parameters.sorted_CSI_Idx);
    % Printing out whether transmission was successful or not, along with number of bits in error.
    if (~errBits)
        disp('Successful Transmission');
    else
        disp(['Number of bits with error for the two users: ', num2str(errBits)]);
    end

    % Displaying the CSI values before and after sorting in descending order.
    %disp(System_Parameters.CSI);
    
end
