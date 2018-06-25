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
for k = 1:m
InputWeight = reshape(x(k,1:inputnum*hiddennum),hiddennum,inputnum);
HiddenBias = reshape(x(k,inputnum*hiddennum+1:inputnum*hiddennum+hiddennum),...
    hiddennum,1);

   % ʹ��ELM��������ֵ�����Լ������
   Output=ELM(outputn,inputn, valinput, hiddennum,InputWeight,HiddenBias);

% ������ʧֵ
    error(k, 1) = calLoss(size(valinput, 1),Output, valoutput);
end
end