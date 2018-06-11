clc;clear;close all;
format compact;
addpath('AIS');addpath('PSO');addpath('RBF');addpath('DataBase');
%% Parameter setting
d0 = 1;%��λm
Pd0 = 31.7;%��λdb���������ֵ
PT = 0;%��λdbm,���书��0
n = 2.2;%·�����ָ��
sigma= 3;%���ӵ�0��ֵ��˹���̵ı�׼��
N = 100;%�ռ���100������
load('DataBase\Test.mat');
load('DataBase\Train.mat');
load('DataBase\Val.mat');

%% Experiment setting

Iters = 10;  % ����������
Error = zeros(NumberofTag,1);  % ÿ�ε�����������
averageError = zeros(NumberofTag, 1);

%% Start running
nCount = 0;  % ��ʧ·���ĸ���
ind = randperm(NumberofTag);
TrainInput = TrainInput(ind, :);
PosTag = PosTag(ind, :);
for n = 1:NumberofTag
    trainN = n;
    nCount = nCount + 1;
    train = TrainInput(1:trainN, :);
%============================����RSSIֵ============================%

    %% ELM
    % Initialize the parameters of ELM
    NumberofHidden = 28;    % ����ڵ����
%     epsilon_init = sqrt(6)./sqrt(4+NumberOfHidden);
    epsilon_init = 1;
    InputWeight_init = 2*rand(NumberofHidden, 4)*epsilon_init-epsilon_init;% ��ʼ������Ȩ��
    HiddenBias_init = 2*rand(NumberofHidden,1)*epsilon_init-epsilon_init; % ��ʼ��������Ԫƫ��
    % ֱ��ʹ��ELM
    [OutputofTrain,OutputofTest,trainTime,testTime]= ...
        ELM(PosTag(1:trainN, :),train,ValInput,NumberofHidden,...
        InputWeight_init,HiddenBias_init);
    % ���㶨λ���
    [Error(n, 1),max_error, min_error] = ...
        calLoss(NumberofValTag,OutputofTest, PosValTag);
    [Error(n, 2),max_error, min_error] = ...
        calLoss(trainN,OutputofTrain, PosTag(1:trainN, :));
    x(nCount, 1) = n;    % ��ʧ·������
    averageError = Error;   % ƽ�����
end

%% plot figure
figure;
plot(x,averageError(:,1),'go--');hold on;
plot(x,averageError(:,2),'bx--');
xlabel('Training example number');
ylabel('Average positioning error');
legend('CV error', 'Train error');
title('Learning Curve');
