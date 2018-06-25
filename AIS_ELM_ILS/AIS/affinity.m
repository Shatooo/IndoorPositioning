function aff = affinity(AbPop, NumberofHidden, NumberofTag, TrainInput,...
    PosTag, NumberofValidation, ValidationInput, PosValidation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����AIS�㷨��Ⱥÿ��������׺�����AbPop Ϊ��Ҫ�������Ⱥ������aff ��Ⱥ�׺�����
% aff ֵԽ��������ĸ�����š�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[row, col] = size(AbPop);
NumberofInput = size(TrainInput, 2);

aff = zeros(row, 1);
for irow = 1:row
   InputWeight = reshape(AbPop(irow,1:NumberofHidden*NumberofInput)', ...
     NumberofHidden, NumberofInput);
   HiddenBias = reshape(AbPop(irow,NumberofHidden*NumberofInput+1:end)',...
       NumberofHidden, 1);  
   % ʹ��ELM��������ֵ�����Լ������
   Output=ELM(PosTag,TrainInput, ValidationInput, NumberofHidden,InputWeight,HiddenBias);

    Error = calLoss(NumberofValidation, Output, PosValidation);
    aff(irow, 1) = 1./(1+Error);
end