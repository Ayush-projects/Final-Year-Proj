% Channel Decoder: Performs convolution decoding of the multi-user encoded
%                  data matrix
%
% Input: encodedData, System_Parameters
%        encodedData    - A matrix containing convolutionally encoded 
%                         information of multiple user where each user is 
%                         assigned one column.
%        System_Parameters       - A structure containing system parameters like
%                         number of users, code rate, qam alphabet etc.
%
% Output: data   - A matrix containing information of multiple user
%                         where each user is assigned one column.
%

function data = Decoding(encodedData, System_Parameters)   
    % Perform convolutional decoding
    if (System_Parameters.softQAM)
        data = vitdec(encodedData, System_Parameters.coding.cc.trellis, System_Parameters.coding.cc.tbl, 'cont', 'unquant');
        data = data(System_Parameters.coding.cc.tbl + 1: end);
        data = [data; zeros(System_Parameters.coding.cc.tbl, 1)];
    else
        data = vitdec(encodedData, System_Parameters.coding.cc.trellis, System_Parameters.coding.cc.tbl, 'trunc', 'hard');
    end
end