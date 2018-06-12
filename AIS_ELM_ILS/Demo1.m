clc;clear;close all;
format compact;
addpath('AIS');addpath('PSO');addpath('RBF');
%% Parameter setting
d0 = 1;%��λm
Pd0 = 31.7;%��λdb���������ֵ
PT = 0;%��λdbm,���书��0
n = 2.2;%·�����ָ��
sigma= 3;%���ӵ�0��ֵ��˹���̵ı�׼��
N = 1000;%�ռ���100������
%% The setting of Reader, Reference tag and Test tag
% �ڿռ�Ľ������4���Ķ���
NumberofReader =  4;
PosReader = [-0.5,-0.5;-0.5,10.5;10.5,-0.5;10.5,10.5];
NumberofTag = 121;    % �ο���ǩ������
PosTag = zeros(NumberofTag, 2);
% �� 11 x 11 �Ŀռ��з��� 121 ���ο���ǩ
%ÿ����ǩ��� 1 m��������(0,0)������(10,10)
for iRow = 1:11
   for jCol = 1:11
      PosTag((iRow-1)*11+jCol,:) = [(jCol-1) (iRow-1)]; 
   end
end
% ʹ�òο���ǩ������֤���
NumberofValTag = 121;
PosValTag = PosTag;
% �ڿռ����������1000�����Ա�ǩ�����ڲ��Զ�λЧ����
NumberofTestTag = 1000;     % ���Ա�ǩ������
PosTestTag = 10 * rand(NumberofTestTag, 2);    % ����������Ա�ǩ��λ��

PR = zeros(NumberofTag, NumberofReader, N);        % �ο���ǩRSSIֵ
PR_Val = zeros(NumberofValTag, NumberofReader, N); % ��֤��ǩRSSIֵ 
PR_Test = zeros(NumberofTestTag, NumberofReader, N); % ���Ա�ǩRSSIֵ

%% Calculate the distances
  % �ο���ǩ���Ķ���֮��ľ���
[d_RT] = calDistance(NumberofTag, NumberofReader, PosTag, PosReader);
 % ���Ա�ǩ���Ķ���֮��ľ���
[d_RTT]=calDistance(NumberofTestTag, NumberofReader, PosTestTag, PosReader);

%% Experiment setting

Iters = 1;  % ����������
Error1 = zeros(Iters, NumberofReader); % ÿ�ε�����ѵ�����
Error2 = zeros(Iters,NumberofReader);  % ÿ�ε����Ĳ������
trainError = [];
testError = [];

% ѵ������Ͳ���������
OutputofTrain = zeros(NumberofTag,2);
OutputofTest = zeros(NumberofTestTag,2);
%% Start running
for n = 10
    fprintf('The loss path constant is: %d\n', n);
for iter = 1:Iters
%============================����RSSIֵ============================%
    Para = [PT, Pd0, d0, n, sigma, N]; % RSSI��������
    [PR, PR_Test] = calPR(NumberofTag, NumberofTestTag, NumberofReader, ...
        d_RT, d_RTT,Para);
%==========================����Ԥ����===============================%
%================��˹�˲�===================%
    [PRFilter]=GaussianFilter(PR,NumberofTag,NumberofReader,N);
    [PRTestFilter]=GaussianFilter(PR_Test,NumberofTestTag,NumberofReader,N);
    % ��һ������
    PRGY = [PRFilter; PRTestFilter];
    [PRGY, PRGYMIN, PRGYMAX] = normalPR(PRGY);
    [GYrow,GYcol] = size(PRGY);
    % ����ѵ��������֤���Ͳ��Լ�
    TrainInput = PRGY(1:NumberofTag,:);
    ValInput = TrainInput;
    TestInput = PRGY(NumberofTag + 1:end,:);
    
    %% ELM
    % Initialize the parameters of ELM
    NumberofHidden = 10;    % ����ڵ����
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
    NumberofHidden = 10;
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
    [error]=RBFILS(PosTag,TrainInput,TestInput,NumberofHidden,PosTestTag);
    Error1(iter, 4) = error(1,1);
    Error2(iter, 4) = error(1,2);
end
    trainError = [trainError; mean(Error1, 1)];  % ƽ��ѵ�����
    testError = [testError; mean(Error2, 1)]   % ƽ���������
end