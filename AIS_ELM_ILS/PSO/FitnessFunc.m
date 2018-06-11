function error = FitnessFunc(x,inputnum,hiddennum,inputn,outputn,...
    valinput, valoutput)  
% �ú�����������pso��Ӧ��ֵ  
%x          input     ����  
%inputnum   input     �����ڵ���  
%outputnum  input     ������ڵ���  
%net        input     ����  
%inputn     input     ѵ����������  
%outputn    input     ѵ���������  
  
%error      output    ������Ӧ��ֵ  
  
% ��ȡ 
[m, n] = size(x);
error = zeros(m, 1);
C = 0.1;
for k = 1:m
InputWeight = reshape(x(k,1:inputnum*hiddennum),hiddennum,inputnum);
HiddenBias = reshape(x(k,inputnum*hiddennum+1:inputnum*hiddennum+hiddennum),...
    hiddennum,1);

NumberOfInput = size(inputn, 1);

%% training phase
    tempH = inputn * InputWeight';
    ind = ones(1, NumberOfInput);
    tempH = tempH + HiddenBias(:,ind)';
    H = 1 ./ (1 + exp(-tempH)); % sigmoid �����
    %----------------------------�������Ȩ��----------------------------%
    OutputWeight=pinv(H) * outputn;
%     OutputWeight = pinv(H'*H + 1./C) * H' * outputn;
    
%% validating phase
    tempH1 = valinput * InputWeight';
    ind = ones(1, size(valinput, 1));
    tempH1 = tempH1 + HiddenBias(:,ind)';
    H1 = 1 ./ (1 + exp(-tempH1)); % sigmoid �����
    
    Output = H1 * OutputWeight;

% ������ʧֵ
    error(k, 1) = calLoss(size(valinput, 1),Output, valoutput);
end
end