clc;clear;close all;
format compact;
addpath('RBF');addpath('AISRBF');
%% Parameter setting
d0 = 1;%��λm
Pd0 = 31.7;%��λdb���������ֵ
PT = 0;%��λdbm,���书��0
n = 2.2;%·�����ָ��
sigma= 3;%���ӵ�0��ֵ��˹���̵ı�׼��
N = 1000;%�ռ���100������
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

%% �鿴��ǩ���Ķ�����λ��
% plot(PosTag(:,1), PosTag(:,2), 'go', 'MarkerSize', 8);
% hold on;
% plot(PosReader(:, 1), PosReader(:, 2), 'ks', 'MarkerFaceColor', 'r', 'MarkerSize', 12);
% plot(PosTestTag(:, 1), PosTestTag(:, 2), 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'b');
% % set(gca,'XTickLabel','','YTickLabel','');
% % set(gca,'XTick','','YTick','');
% axis([-0.6 10.6 -0.6 10.6]);

%% Calculate the distances
  % �ο���ǩ���Ķ���֮��ľ���
[d_RT] = calDistance(NumberofTag, NumberOfReader, PosTag, PosReader);
% ������֤��ǩ���Ķ����ľ���
[d_RTV]=calDistance(NumberofValTag, NumberOfReader, PosValTag, PosReader);
 % ���Ա�ǩ���Ķ���֮��ľ���
[d_RTT]=calDistance(NumberofTestTag, NumberOfReader, PosTestTag, PosReader);

%% Experiment setting

Iters = 10;  % ����������
Error = zeros(Iters,2);  % ÿ�ε�����������
averageError = zeros(10, 2);

OutputofTrain = zeros(NumberofTag,2,Iters);
OutputofTest = zeros(NumberofTestTag,2,Iters);
%% Start running
nCount = 0;  % ��ʧ·���ĸ���
for n = 1:10
    n
    nCount = nCount + 1;
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
    [PRFilter, PRValFilter, PRTestFilter] = addDeltaPR(PRFilter, PRValFilter, PRTestFilter);
    % ��һ������
    PRGY = [PRFilter;PRValFilter;PRTestFilter];
    [PRGY, PRGYMIN, PRGYMAX] = normalPR(PRGY);
    [GYrow,GYcol] = size(PRGY);
    % ����ѵ��������֤���Ͳ��Լ�
    TrainInput = PRGY(1:NumberofTag,:);
%     ValInput = PRGY(NumberofTag+1:NumberofTag+NumberofValTag,:);
    ValInput = TrainInput;
    TestInput = PRGY(NumberofTag + NumberofValTag+1:end,:);
    %% �������ݼ�
%     save('DataBase\Val', 'ValInput', 'NumberofValTag', 'PosValTag');
%     save('DataBase\Train', 'TrainInput', 'NumberofTag', 'PosTag');
%     save('DataBase\Test', 'TestInput', 'NumberofTestTag', 'PosTestTag');
    
    %% ELM
    % Initialize the parameters of ELM
    NumberofHidden = 21;    % ����ڵ����
    epsilon_init = sqrt(6)./sqrt(4+NumberofHidden);
%     epsilon_init = 1;
    InputWeight_init = 2*rand(NumberofHidden, 7)*epsilon_init-epsilon_init;% ��ʼ������Ȩ��
    HiddenBias_init = 2*rand(NumberofHidden,1)*epsilon_init-epsilon_init; % ��ʼ��������Ԫƫ��
    
    %% ʹ��RBF
    [error]=RBFILS(PosTag,TrainInput,TestInput,NumberofHidden,PosTestTag);
    Error(iter, 1) = error(1,1);
%     Error(iter, 2) = error(1,2);
end
    x(nCount, 1) = n;    % ��ʧ·������
    averageError(nCount,:) = mean(Error,1)   % ƽ�����
end

%% plot figure
figure;
plot(x,averageError(:,1),'go--','MarkerSize',8);hold on;
plot(x,averageError(:,2),'bd--','MarkerSize',8);
% plot(x,averageError(:,3),'rx--','MarkerSize',8);
% plot(x,averageError(:,4),'ks--','MarkerSize',8);
xlabel('The signal loss constant(\alpha)');
ylabel('Average positioning error');
% legend('ELM(sp = 2.0m)', 'AIS-ELM(sp = 2.0m)', 'PSO-ELM(sp = 2.0m)', ...
%     'RBF(sp = 2.0m)');
legend('RBF(sp = 1.0m)', 'AIS-RBF(sp = 1.0m)');
title(sprintf('N=%d,sigma=%f', N, sigma));
