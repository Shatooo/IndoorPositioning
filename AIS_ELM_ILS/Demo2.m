clc;clear;close all;
format compact;
%% Parameter setting
d0 = 1;%��λm
Pd0 = 31.7;%��λdb���������ֵ
PT = 0;%��λdbm,���书��
n = 2.2;%·�����ָ��
sigma= 3;%���ӵ�0��ֵ��˹���̵ı�׼��
N = 1000;%�ռ���100������
%% The setting of Reader, Reference tag and Test tag
% �ڿռ�Ľ������4���Ķ���
PosReader = [-0.5,-0.5;-0.5,10.5;10.5,-0.5;10.5,10.5];
nPosTag = 121;
PosTag = zeros(nPosTag, 2);
% �� 11 x 11 �Ŀռ��з��� 121 ���ο���ǩ
%ÿ����ǩ��� 1 m��������(0,0)������(10,10)  
for iRow = 1:11
   for jCol = 1:11
      PosTag((iRow-1)*11+jCol,:) = [jCol-1 iRow-1]; 
   end
end
nPosValTag = 121;
PosValTag = 10 * rand(nPosValTag, 2);
% �ڿռ����������1000�����Ա�ǩ�����ڲ��Զ�λЧ����
nPosTestTag = 1000;
PosTestTag = 10 * rand(nPosTestTag, 2);    % ����������Ա�ǩ��λ��
NumberOfReader = size(PosReader, 1);    % �Ķ���������
NumberOfTag = size(PosTag, 1);          % �ο���ǩ������
NumberOfValTag = size(PosValTag, 1);    % ��֤��ǩ������
NumberOfTestTag = size(PosTestTag, 1);  % ���Ա�ǩ������
PR = zeros(NumberOfTag, NumberOfReader, N);        % �ο���ǩRSSIֵ
PR_Val = zeros(NumberOfValTag, NumberOfReader, N); % ��֤��ǩRSSIֵ 
PR_Test = zeros(NumberOfTestTag, NumberOfReader, N); % ���Ա�ǩRSSIֵ

%% Calculate the distances
  % �ο���ǩ���Ķ���֮��ľ���
[d_RT] = calDistance(NumberOfTag, NumberOfReader, PosTag, PosReader);
% ������֤��ǩ���Ķ����ľ���
[d_RTV]=calDistance(NumberOfValTag, NumberOfReader, PosValTag, PosReader);
 % ���Ա�ǩ���Ķ���֮��ľ���
[d_RTT]=calDistance(NumberOfTestTag, NumberOfReader, PosTestTag, PosReader);

%% Experiment setting

Iters = 50;  % ����������
Error = zeros(Iters,1);  % ÿ�ε�����������
averageError = zeros(80, 1);

OutputOfTrain = zeros(NumberOfTag,2,Iters);
OutputOfTest = zeros(NumberOfTestTag,2,Iters);
%% Start running
nCount = 0;
for hidden = 1
    nCount = nCount + 1;
for iter = 1:Iters
%============================����RSSIֵ============================%
    Para = [PT, Pd0, d0, n, sigma, N]; % RSSI��������
    [PR PR_Val PR_Test] = calPR(NumberOfTag, NumberOfValTag, ...
             NumberOfTestTag, NumberOfReader, d_RT, d_RTV, d_RTT,Para);
%==========================����Ԥ����===============================%
%================��˹�˲�===================%
    [PRFilter]=GaussianFilter(PR,NumberOfTag,NumberOfReader,N);
    [PRValFilter]=GaussianFilter(PR_Val,NumberOfValTag,NumberOfReader,N);
    [PRTestFilter]=GaussianFilter(PR_Test,NumberOfTestTag,NumberOfReader,N);
    % ��һ������
    PRGY = [PRFilter;PRValFilter;PRTestFilter];
    PRGYMAX = max(PRGY, [], 1);
    PRGYMIN = min(PRGY, [], 1);
    PRGY = (PRGY - PRGYMIN(ones(size(PRGY, 1), 1), :))./...
        (PRGYMAX(ones(size(PRGY, 1), 1), :) - PRGYMIN(ones(size(PRGY, 1), 1), :));
    [GYrow,GYcol] = size(PRGY);
    % ����Ԥ��������ѵ��������֤���Ͳ��Լ�
    TrainInput = PRGY(1:NumberOfTag,:);
    ValInput = PRGY(NumberOfTag+1:NumberOfTag+NumberOfValTag,:);
    TestInput = PRGY(NumberOfTag + NumberOfValTag+1:end,:);
    %% ELM
    % Initialize the parameters of ELM
    NumberOfHidden = 31;    % ����ڵ����
%     epsilon_init = sqrt(6)./sqrt(4+NumberOfHidden);
    epsilon_init = 1;
    InputWeight = 2*rand(NumberOfHidden, 4)*epsilon_init-epsilon_init;% ��ʼ������Ȩ��
    HiddenBias = 2*rand(NumberOfHidden,1)*epsilon_init-epsilon_init; % ��ʼ��������Ԫƫ��
    % ֱ��ʹ��ELM
    [OutputOfTrain(:,:,iter),OutputOfTest(:,:,iter),trainTime,testTime]= ...
        ELM(PosTag,TrainInput, TestInput, NumberOfHidden, InputWeight, HiddenBias);
    
    % ���㶨λ���
    temp = 0;
    for i = 1:NumberOfTestTag
        temp = temp + norm(OutputOfTest(i,:,iter) - PosTestTag(i, :));
    end
    Error(iter,1) = temp ./ NumberOfTestTag;
end
    x(nCount, 1) = hidden;    % ��ʧ·������
    averageError(nCount,:) = mean(Error,1);   % ƽ�����
    mean(Error,1)
end
[a,i] = min(averageError);
i + 20 
%% plot figure
figure();
plot(x, averageError, 'bo-', 'MarkerSize', 6, 'LineWidth', 1);
xlabel('hidden number');
ylabel('MeanError (m)');
title(sprintf('n=%d,sigma=%d', N,sigma));
