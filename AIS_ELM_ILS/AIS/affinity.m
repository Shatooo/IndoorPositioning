function aff = affinity(AbPop, NumberofHidden, NumberofTag, TrainInput,...
    PosTag, NumberofValidation, ValidationInput, PosValidation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����AIS�㷨��Ⱥÿ��������׺�����AbPop Ϊ��Ҫ�������Ⱥ������aff ��Ⱥ�׺�����
% aff ֵԽ��������ĸ�����š�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[row, col] = size(AbPop);
NumberofInput = size(TrainInput, 2);
C = 0.1;
aff = zeros(row, 1);
for irow = 1:row
   InputWeight = reshape(AbPop(irow,1:NumberofHidden*NumberofInput)', ...
     NumberofHidden, NumberofInput);
   HiddenBias = reshape(AbPop(irow,NumberofHidden*NumberofInput+1:end)',...
       NumberofHidden, 1);  
   %% training phase
    tempH = TrainInput * InputWeight';
    ind = ones(1, NumberofTag);
    tempH = tempH + HiddenBias(:,ind)';
    H = 1 ./ (1 + exp(-tempH)); % sigmoid �����
    H = logsig(tempH);
    %----------------------------�������Ȩ��----------------------------%
    OutputWeight=pinv(H) * PosTag;
%     OutputWeight = pinv(H'*H + 1./C) * H' * PosTag;
%     OutputOfTrain = H * OutputWeight;
%% ���㶨λ���
    tempH1 = ValidationInput * InputWeight';
    tempH1 = tempH1 + HiddenBias(:, ones(1, NumberofValidation))';
    H1 = 1./(1+exp(-tempH1));
    Output = H1 * OutputWeight;

    Error = calLoss(NumberofValidation, Output, PosValidation);
    aff(irow, 1) = 1./(1+Error);
end