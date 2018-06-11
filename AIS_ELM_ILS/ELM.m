function [OutputOfTrain,OutputOfTest,trainEndTime,testEndTime] = ...
    ELM(PosTag,TrainInput, TestInput, NumberofHidden,InputWeight,HiddenBias)
    C = 10;    % ����ϵ��
    NumberofTag = size(TrainInput, 1);
    NumberofTestTag = size(TestInput, 1);
    
    tic;       % ѵ����ʱ��ʼ
%% training phase
    tempH = TrainInput * InputWeight';
    ind = ones(1, NumberofTag);
    tempH = tempH + HiddenBias(:,ind)';
    H = 1 ./ (1 + exp(-tempH)); % sigmoid �����
    
    %----------------------------�������Ȩ��----------------------------%
    OutputWeight=pinv(H) * PosTag;
%     OutputWeight = pinv(H'*H + 1./C) * H' * PosTag;
    OutputOfTrain = H * OutputWeight;
    trainEndTime = toc; % ѵ����ʱ����
%% testing phase
    tic;              % ���Կ�ʼ��ʱ

    tempH1 = TestInput * InputWeight';
    tempH1 = tempH1 + HiddenBias(:, ones(1, NumberofTestTag))';
    H1 = 1./(1+exp(-tempH1));
    OutputOfTest = H1 * OutputWeight;     % ���Լ�ʵ�����
    testEndTime = toc; % ���Խ�����ʱ
    
end