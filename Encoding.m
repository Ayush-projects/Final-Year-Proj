% Channel Encoder: Performs convolution encoding of the multi-user data
%                  matrix
%
% Input: data, System_Parameters
%        data           - A matrix containing information of multiple user
%                         where each user is assigned one column.
%        System_Parameters       - A structure containing system parameters like
%                         number of users, code rate, qam alphabet etc.
%
% Output: encodedData   - A matrix containing convolutionally encoded 
%                         information of multiple user where each user is 
%                         assigned one column.
%

function encodedData = Encoding(data, System_Parameters)   
    % Perform convolutional coding
    encodedData = convenc(data, System_Parameters.coding.cc.trellis);
end