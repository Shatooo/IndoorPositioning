clc;
clear;
% close all;
addpath('AIS');
%% Parameter setting
d0 = 1;%��λm
Pd0 = 31.7;%��λdb���������ֵ
PT = 0;%��λdbm,���书��
n = 2.2;%·�����ָ�� 
sigma= 3;%���ӵ�0��ֵ��˹���̵ı�׼��
N = 100;%�ռ���100������
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
% plot(PosTag(:,1), PosTag(:,2), 'ro', 'MarkerSize', 8);
% �ڿռ����������1000�����Ա�ǩ�����ڲ��Զ�λЧ����
nPosTestTag = 1000;
PosTestTag = 10 * rand(nPosTestTag, 2);    % ����������Ա�ǩ��λ��
NumberOfReader = size(PosReader, 1);
NumberOfTag = size(PosTag, 1);
NumberOfTestTag = size(PosTestTag, 1);
d_RT = zeros(NumberOfTag, NumberOfReader);
d_RTT = zeros(NumberOfTestTag, NumberOfReader);
PR = zeros(NumberOfTag, NumberOfReader, N); % 4���Ķ����յ��Ĳο���ǩRSSIֵ
PRtest = zeros(NumberOfTestTag, NumberOfReader, N); % 4���Ķ����յ��Ĳ��Ա�ǩRSSIֵ

%% Calculate the distances
  % ÿ���ο���ǩ���Ķ���֮��ľ���
for j = 1:NumberOfTag
    for i = 1:NumberOfReader
        d_RT(j,i) = norm(PosTag(j, :) - PosReader(i, :));
    end
end
 % ÿ�����Ա�ǩ���Ķ���֮��ľ���
for j = 1:NumberOfTestTag
    for i = 1:NumberOfReader
        d_RTT(j,i) = norm(PosTestTag(j, :) - PosReader(i, :));
    end
end
%% Init the parameter of ELM
NumberOfHidden = 28;    % ����ڵ����
HiddenBias = sigma .* randn(NumberOfHidden, 1); % ����ƫ�ó�ʼ��
InputWeight = sigma .* randn(NumberOfReader, NumberOfHidden);% ����Ȩ�س�ʼ��
OutputWeight = sigma .* randn(NumberOfHidden, 2);   % ���Ȩ�س�ʼ��
%% Experiment setting

Iters = 3;  % ����������
Error = zeros(Iters,1);  % ÿ�ε�����������

OutputOfTrain = zeros(NumberOfTag,2,Iters);
OutputOfTest = zeros(NumberOfTestTag,2,Iters);
%% Start running
for iter = 1:Iters
%============================����RSSIֵ============================%
    for j = 1:N
        AddGauss=sigma * randn(NumberOfTag+NumberOfTestTag,NumberOfReader);
        PR(:,:,j)=PT-(Pd0+10.*n.*log10(d_RT./d0)+AddGauss(1:NumberOfTag,:));
        PRtest(:,:,j) = PT - (Pd0 + 10.*n.*log10(d_RTT./d0)+...
            AddGauss(NumberOfTag+1:NumberOfTag+NumberOfTestTag,:));
    end
%==========================����Ԥ����===============================%
    PR_mean = mean(PR, 3); % �ο���ǩ RSSI ��ֵ
    PRd_square = zeros(NumberOfTag, NumberOfReader);
    for i = 1:N
        PRd_square = PRd_square + (PR(:,:,i)-PR_mean).^2;
    end
    sigma1 = sqrt(1/(N-1) * PRd_square); % ���Ա�ǩ RSSI ֵ�ķ���
    
     uplimit = PR_mean + sigma1;    % �˲��Ͻ�
     downlimit = PR_mean - sigma1;  % �˲��½�
     PRTemp = zeros(NumberOfTag,NumberOfReader);
     PRFilter = zeros(NumberOfTag,NumberOfReader);
     for i = 1:NumberOfTag
        for j = 1:NumberOfReader
           Length = 0;
           for k = 1:N
              if PR(i,j,k)<uplimit(i,j) && PR(i,j,k)>downlimit(i,j)
                  PRTemp(i,j) = PRTemp(i,j) + PR(i,j,k);
                  Length = Length + 1;
              end
           end
           PRFilter(i,j) = PRTemp(i,j)./Length;    % �ο���ǩ�˲����
        end
     end
    
 %%%%%%%%%%%%%%%%%��������Ԥ����%%%%%%%%%%%%%%%%
 %================��˹�˲�===================%
    PRtestmean=mean(PRtest,3);  % ���Ա�ǩ RSSI ��ֵ
    PRd_square1 = zeros(NumberOfTestTag, NumberOfReader); % ���Ʊ�׼��
    for i = 1:N
        PRd_square1 = PRd_square1 + (PRtest(:,:,i)-PRtestmean).^2;
    end
    sigma2 = sqrt(1/(N-1) * PRd_square1);
    %-----ɸѡ��1����׼�Χ�ڵĵ�-----------%
    testuplimit = PRtestmean+sigma2;
    testdownlimit = PRtestmean-sigma2;
    PRtestTemp=zeros(NumberOfTestTag,NumberOfReader);
    PRtestFilter=zeros(NumberOfTestTag,NumberOfReader);
    for i = 1:NumberOfTestTag
      for j=1:NumberOfReader
        Length=0;
        for k=1:N
          if PRtest(i,j,k)<testuplimit(i,j) && PRtest(i,j,k)>testdownlimit(i,j)
             PRtestTemp(i,j)= PRtestTemp(i,j)+PRtest(i,j,k);
             Length=Length+1;
          end
        end
        PRtestFilter(i,j)=PRtestTemp(i,j)./Length;  % ���Ա�ǩ�˲����
       end
    end
    
    % ��һ������
    PRGY = [PRFilter;PRtestFilter];
    PRGYMAX = max(PRGY, [], 1);
    PRGYMIN = min(PRGY, [], 1);
    PRGY = (PRGY - PRGYMIN(ones(size(PRGY, 1), 1), :))./...
        (PRGYMAX(ones(size(PRGY, 1), 1), :) - PRGYMIN(ones(size(PRGY, 1), 1), :));
    [GYrow,GYcol] = size(PRGY);
    % ѵ��������׼��
    TrainInput = PRGY(1:GYrow-NumberOfTestTag,:);
    % ��֤������׼��
    NumberOfValidation = NumberOfTag;
    ValidationInput = TrainInput;
    PosValidation = PosTag;
    % ���Լ�����׼��
    TestInput = PRGY(NumberOfTag+1:NumberOfTestTag+NumberOfTag,:);
    %% Immune system
    % ��ʼ��Ȩ�غ�ƫ��
    epsilon_init = sqrt(6)./sqrt(4+NumberOfHidden);
    InputWeight = rand(NumberOfHidden, 4)*epsilon_init-epsilon_init;% ��ʼ������Ȩ��
    HiddenBias = rand(NumberOfHidden,1)*epsilon_init-epsilon_init; % ��ʼ��������Ԫƫ��
    % ʹ�������㷨�Ż�
    [best_ab,best_fval,it,best_set,FE]=...
        optainet(InputWeight,HiddenBias,NumberOfHidden,...
        NumberOfTag, PosTag,TrainInput, NumberOfValidation, ...
        PosValidation, ValidationInput);
    
    InputWeight = reshape(best_ab(1:NumberOfHidden*4),NumberOfHidden, 4);
    HiddenBias = reshape(best_ab(NumberOfHidden*4+1:end),NumberOfHidden, 1);
    % ʹ�� ELM
    [OutputOfTrain(:,:,iter),OutputOfTest(:,:,iter),trainTime,testTime]= ...
        ELM(PosTag,TrainInput, TestInput, NumberOfHidden, InputWeight, HiddenBias);
    time(iter,1) = trainTime;
    time(iter,2) = testTime;
    % ������Զ�λ���
    temp = 0;
    for i = 1:NumberOfTestTag
        temp = temp + norm(OutputOfTest(i,:,iter) - PosTestTag(i, :));
    end
    Error(iter,1) = temp ./ NumberOfTestTag;
end

%% result computing
meanTime = mean(time,1);
minError = max(min(Error))
maxError = max(max(Error))
meanError = mean(mean(Error))
mse = mean(mean(Error.^2))


%% plot figure
% figure();
% for i = 1:NumberOfTestTag
%    h_error = plot([mean(OutputOfTest(i,1,:),3) PosTestTag(i,1)],...
%        [mean(OutputOfTest(i,2,:),3) PosTestTag(i,2)],'b-');hold on; 
% end
% h_rpos = plot(PosTestTag(:,1), PosTestTag(:,2), 'b+', 'LineWidth', 2);hold on;
% h_epos = plot(mean(OutputOfTest(:,1,:),3), mean(OutputOfTest(:,2,:),3),...
%     'ro', 'LineWidth', 2);hold on;
% xlabel('Width of the Area (m)');ylabel('Length of the Area (m)');
% legend([h_rpos h_epos h_error],'Real position of tags',...
%     'Estimated position of tags','Location error');
% axis([0 11 0 7]);
% grid on;
