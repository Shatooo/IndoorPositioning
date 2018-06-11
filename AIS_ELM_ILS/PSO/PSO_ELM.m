function [InputWeight, HiddenBias] = ...
    PSO_ELM(InputWeight_init, HiddenBias_init, ...
    hiddennum, PosTag,TrainInput,PosValTag, ValInput)


numSum=4*hiddennum+hiddennum;

MAX_GEN = 5;        % ����������
POP_SIZE = 50;        % Ⱥ���С
c1 = 0.5;
c2 = 0.5;
w = 0.5;
range = sqrt(6)./sqrt(4+hiddennum);
[x y] = PSO(@(x)FitnessFunc(x,4,hiddennum,TrainInput, PosTag,...
    ValInput, PosValTag), POP_SIZE, c1, c2, w, MAX_GEN, numSum, range,...
    InputWeight_init, HiddenBias_init);
% range = repmat([-1, 1], numSum, 1);
% Max_V = 0.2* (range(:,2)-range(:,1)); % ����ٶ�ȡ��Χ��10%-20%
% PSOparameters = [0 MAX_GEN POP_SIZE c1 c2 0.5 0.5 100 1e-25 150 NaN 0 0];
% [x,out] = pso_Trelea_vectorized(@(x)FitnessFunc(x,4,hiddennum,TrainInput,...
%     PosTag,ValInput, PosValTag),numSum,Max_V, range, 1, PSOparameters);
 % ��ȡ  
InputWeight = reshape(x(1:4*hiddennum),hiddennum,4);
HiddenBias = reshape(x(4*hiddennum+1:4*hiddennum+hiddennum),...
    hiddennum,1);
end