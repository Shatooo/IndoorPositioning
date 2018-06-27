clc;clear;close all;
format compact;
addpath('utilities');
addpath('AIS');addpath('PSO');addpath('RBF');
%% Parameter setting
sigma= 3;%���ӵ�0��ֵ��˹���̵ı�׼��
N = 100;%�ռ���100������

load(fullfile('DataSet','TrainSet','trainSet_3sigma_100N.mat'));
load(fullfile('DataSet','TestSet','testSet_3sigma_100N.mat'));

NumberofTag = trainSet.NumberofTag;    % �ο���ǩ������
PosTag = trainSet.label;

NumberofValTag = NumberofTag;
PosValTag = PosTag;
% �ڿռ����������1000�����Ա�ǩ�����ڲ��Զ�λЧ����
NumberofTestTag = testSet.NumberofTag;     % ���Ա�ǩ������
PosTestTag = testSet.label;    % ����������Ա�ǩ��λ��

TrainData = trainSet.Data;
ValData = TrainData;
TestData = testSet.Data;
%% Experiment setting

Iters = 1;  % ����������
Error1 = zeros(Iters, 4); % ÿ�ε�����ѵ�����
Error2 = zeros(Iters,4);  % ÿ�ε����Ĳ������
trainError = [];
testError = [];

% ѵ������Ͳ���������
OutputofTrain = zeros(NumberofTag,2);
OutputofTest = zeros(NumberofTestTag,2);
%% Start running
for n = 10
    fprintf('The loss path constant is: %d\n', n);
    TrainInput = TrainData{n};
    ValInput = TrainInput;
    TestInput = TestData{n};
for iter = 1:Iters    
    %% ELM
    % Initialize the parameters of ELM
    NumberofHidden = 30;    % ����ڵ����
    epsilon_init = sqrt(6)./sqrt(4+NumberofHidden); % ���ú������ֵ 
    InputWeight_init = 2*rand(NumberofHidden, NumberofReader)*epsilon_init-epsilon_init;% ��ʼ������Ȩ��
    HiddenBias_init = 2*rand(NumberofHidden,1)*epsilon_init-epsilon_init; % ��ʼ��������Ԫƫ��
    % ֱ��ʹ��ELM
    [OutputofTrain,OutputofTest,trainTime,testTime]= ...
        ELM(PosTag,TrainInput,TestInput,NumberofHidden,...
        InputWeight_init,HiddenBias_init);
    % ���㶨λ���
    Error1(iter, 1) = calLoss(NumberofTag,OutputofTrain, PosTag); % ѵ�����
    [Error2(iter, 1),max_error, min_error] = ...
        calLoss(NumberofTestTag,OutputofTest, PosTestTag);
    %% ʹ�������㷨�Ż�
    NumberofHidden = 30;
    InputWeight_init = 2*rand(NumberofHidden, NumberofReader)*epsilon_init-epsilon_init;% ��ʼ������Ȩ��
    HiddenBias_init = 2*rand(NumberofHidden,1)*epsilon_init-epsilon_init; % ��ʼ��������Ԫƫ��
    [InputWeight_AIS,HiddenBias_AIS]=AIS_ELM(InputWeight_init,HiddenBias_init,...
        NumberofHidden, NumberofTag, PosTag,TrainInput, NumberofValTag, ...
        PosValTag, ValInput);
       % ʹ�� ELM
    [OutputofTrain,OutputofTest]= ...
        ELM(PosTag,TrainInput,TestInput,NumberofHidden,InputWeight_AIS,HiddenBias_AIS);
    % ������Զ�λ���
    Error1(iter, 2) = calLoss(NumberofTag,OutputofTrain, PosTag); % ѵ�����
    Error2(iter, 2) = calLoss(NumberofTestTag,OutputofTest, PosTestTag);
    %% ʹ��PSO�Ż�
    [InputWeight_PSO, HiddenBias_PSO] = ...
        PSO_ELM(InputWeight_init, HiddenBias_init, NumberofHidden, ...
        PosTag,TrainInput, PosValTag, ValInput);
    % ʹ�� ELM
    [OutputofTrain,OutputofTest]= ...
        ELM(PosTag,TrainInput,TestInput,NumberofHidden,InputWeight_PSO,HiddenBias_PSO);
    % ������Զ�λ���
    Error1(iter, 3) = calLoss(NumberofTag,OutputofTrain, PosTag); % ѵ�����
    Error2(iter, 3) = calLoss(NumberofTestTag,OutputofTest, PosTestTag);
    
    %% ʹ��RBF
    [error]=RBFILS(PosTag,TrainInput,TestInput,35,PosTestTag);
    Error1(iter, 4) = error(1,1);
    Error2(iter, 4) = error(1,2);
end
    trainError = [trainError; mean(Error1, 1)];  % ƽ��ѵ�����
    testError = [testError; mean(Error2, 1)]   % ƽ���������
end