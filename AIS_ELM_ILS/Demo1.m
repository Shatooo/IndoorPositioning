clc;clear;close all;
format compact;
addpath('AIS');addpath('PSO');addpath('RBF');
%% Parameter setting
d0 = 1;%��λm
Pd0 = 31.7;%��λdb���������ֵ
PT = 0;%��λdbm,���书��0
n = 2.2;%·�����ָ��
sigma= 3;%���ӵ�0��ֵ��˹���̵ı�׼��
N = 100;%�ռ���100������
%% The setting of Reader, Reference tag and Test tag
% �ڿռ�Ľ������4���Ķ���
NumberOfReader =  4;
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
% �������121����֤��ǩ
% NumberofValTag = 121;    % ��֤��ǩ������
% PosValTag = 10 * rand(NumberofValTag, 2);
NumberofValTag = 121;
PosValTag = PosTag;
% �ڿռ����������1000�����Ա�ǩ�����ڲ��Զ�λЧ����
NumberofTestTag = 1000;     % ���Ա�ǩ������
PosTestTag = 10 * rand(NumberofTestTag, 2);    % ����������Ա�ǩ��λ��

PR = zeros(NumberofTag, NumberOfReader, N);        % �ο���ǩRSSIֵ
PR_Val = zeros(NumberofValTag, NumberOfReader, N); % ��֤��ǩRSSIֵ 
PR_Test = zeros(NumberofTestTag, NumberOfReader, N); % ���Ա�ǩRSSIֵ

%% Calculate the distances
  % �ο���ǩ���Ķ���֮��ľ���
[d_RT] = calDistance(NumberofTag, NumberOfReader, PosTag, PosReader);
% ������֤��ǩ���Ķ����ľ���
[d_RTV]=calDistance(NumberofValTag, NumberOfReader, PosValTag, PosReader);
 % ���Ա�ǩ���Ķ���֮��ľ���
[d_RTT]=calDistance(NumberofTestTag, NumberOfReader, PosTestTag, PosReader);

%% Experiment setting

Iters = 10;  % ����������
Error1 = zeros(Iters, 4); % ÿ�ε�����ѵ�����
Error2 = zeros(Iters,4);  % ÿ�ε����Ĳ������
trainError = [];
testError = [];

OutputofTrain = zeros(NumberofTag,2,Iters);
OutputofTest = zeros(NumberofTestTag,2,Iters);
%% Start running
for n = 1:10
    fprintf('The loss path constant is: %d\n', n);
for iter = 1:Iters
%============================����RSSIֵ============================%
    Para = [PT, Pd0, d0, n, sigma, N]; % RSSI��������
    [PR, PR_Val, PR_Test] = calPR(NumberofTag, NumberofValTag, ...
             NumberofTestTag, NumberOfReader, d_RT, d_RTV, d_RTT,Para);
%==========================����Ԥ����===============================%
%================��˹�˲�===================%
    [PRFilter]=GaussianFilter(PR,NumberofTag,NumberOfReader,N);
    [PRValFilter]=GaussianFilter(PR_Val,NumberofValTag,NumberOfReader,N);
    [PRTestFilter]=GaussianFilter(PR_Test,NumberofTestTag,NumberOfReader,N);
    % ��һ������
    PRGY = [PRFilter;PRValFilter;PRTestFilter];
    [PRGY, PRGYMIN, PRGYMAX] = normalPR(PRGY);
    [GYrow,GYcol] = size(PRGY);
    % ����ѵ��������֤���Ͳ��Լ�
    TrainInput = PRGY(1:NumberofTag,:);
%     ValInput = PRGY(NumberofTag+1:NumberofTag+NumberofValTag,:);
    ValInput = TrainInput;
    TestInput = PRGY(NumberofTag + NumberofValTag+1:end,:);
    
    %% ELM
    % Initialize the parameters of ELM
    NumberofHidden = 28;    % ����ڵ����
    epsilon_init = sqrt(6)./sqrt(4+NumberofHidden);
    InputWeight_init = 2*rand(NumberofHidden, 4)*epsilon_init-epsilon_init;% ��ʼ������Ȩ��
    HiddenBias_init = 2*rand(NumberofHidden,1)*epsilon_init-epsilon_init; % ��ʼ��������Ԫƫ��
    % ֱ��ʹ��ELM
    [OutputofTrain(:,:,iter),OutputofTest(:,:,iter),trainTime,testTime]= ...
        ELM(PosTag,TrainInput,TestInput,NumberofHidden,...
        InputWeight_init,HiddenBias_init);
    % ���㶨λ���
    Error1(iter, 1) = calLoss(NumberofTag,OutputofTrain(:,:,iter), PosTag); % ѵ�����
    [Error2(iter, 1),max_error, min_error] = ...
        calLoss(NumberofTestTag,OutputofTest(:,:,iter), PosTestTag);
    %% ʹ�������㷨�Ż�
    NumberofHidden = 28;
    [InputWeight_AIS,HiddenBias_AIS]=AIS_ELM(InputWeight_init,HiddenBias_init,...
        NumberofHidden, NumberofTag, PosTag,TrainInput, NumberofValTag, ...
        PosValTag, ValInput);
       % ʹ�� ELM
    [OutputofTrain(:,:,iter),OutputofTest(:,:,iter),trainTime,testTime]= ...
        ELM(PosTag,TrainInput,TestInput,NumberofHidden,InputWeight_AIS,HiddenBias_AIS);
    % ������Զ�λ���
    Error1(iter, 2) = calLoss(NumberofTag,OutputofTrain(:,:,iter), PosTag); % ѵ�����
    Error2(iter, 2) = calLoss(NumberofTestTag,OutputofTest(:,:,iter), PosTestTag);
    %% ʹ��PSO�Ż�
    [InputWeight_PSO, HiddenBias_PSO] = ...
        PSO_ELM(InputWeight_init, HiddenBias_init, NumberofHidden, ...
        PosTag,TrainInput, PosValTag, ValInput);
    % ʹ�� ELM
    [OutputofTrain(:,:,iter),OutputofTest(:,:,iter),trainTime,testTime]= ...
        ELM(PosTag,TrainInput,TestInput,NumberofHidden,InputWeight_PSO,HiddenBias_PSO);
    % ������Զ�λ���
    Error1(iter, 3) = calLoss(NumberofTag,OutputofTrain(:,:,iter), PosTag); % ѵ�����
    Error2(iter, 3) = calLoss(NumberofTestTag,OutputofTest(:,:,iter), PosTestTag);
    
    %% ʹ��RBF
    [error]=RBFILS(PosTag,TrainInput,TestInput,NumberofHidden,PosTestTag);
    Error1(iter, 4) = error(1,1);
    Error2(iter, 4) = error(1,2);
end
    trainError = [trainError; mean(Error1, 1)];
    testError = [testError; mean(Error2, 1)]   % ƽ�����
end
columns = {'ELM', 'AIS-ELM', 'PSO-ELM', 'RBF'};
xlswrite('Results\20180611\output(N=100).xls', columns, 'TrainError', 'A1');
xlswrite('Results\20180611\output(N=100).xls', trainError, 'TrainError', 'A2');
xlswrite('Results\20180611\output(N=100).xls', columns, 'TestError', 'A1');
xlswrite('Results\20180611\output(N=100).xls', testError, 'TestError', 'A2');