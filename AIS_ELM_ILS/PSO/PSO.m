function[xm,fv] = PSO(fitness, sampleN, c1, c2, w, M, D, sigma, ...
    InputWeight_init, HiddenBias_init)
%==========================================================================
% ���ܣ�����Ⱥ�㷨��
% ������fitness ��Ӧ�Ⱥ�����
%       sampleN ��������������
%       c1 ѧϰ����1�������ٶȹ�ʽ��֪���ֲ�����
%       c2 ѧϰ����2�������ٶȹ�ʽ��Ჿ�ֲ���
%       w ����Ȩ�ء������ٶȹ�ʽ�������ֲ�����
%       M ����������
%       D ÿ������Ⱥ��С��
% ����ֵ��xm ȫ�����Ž⡣
%        fv ���Ž��Ӧ��Ӧ��ֵ��
% ��ע��
% ���ڣ�20180418
%==========================================================================
%%%%%%%%%%%������ʼ������%%%%%%%%%%%%
%c1 ѧϰ����1
%c2 ѧϰ����2
%w ����Ȩ��
%M ����������
%D �����ռ�ά��
%N ��ʼ��Ⱥ�������Ŀ
%%%%%%%%��ʼ����Ⱥ�ĸ��壨�����������޶�λ�ú��ٶȵķ�Χ�� %%%%%%%%%%%
format long;
for iraw = 1:sampleN
    for jcol = 1:D
        x(iraw,jcol) = 2 * sigma * rand - sigma;      %�����ʼ��λ��
        v(iraw,jcol) = 2 * sigma * rand - sigma;      %�����ʼ���ٶ�
    end
end
% x(1, :) = [InputWeight_init(:); HiddenBias_init(:)]';
for iraw = 1:sampleN
    p(iraw) = fitness(x(iraw,:));
    y(iraw,:) = x(iraw,:);
end
pg = x(sampleN,:);                        %PgΪȫ������
for iraw = 1:(sampleN-1)
    if fitness(x(iraw,:)) < fitness(pg)
        pg = x(iraw,:);
    end
end
%%%%%%%%%%%%%������Ҫѭ�������չ�ʽ���ε�����ֱ�����㾫��Ҫ��%%%%%%%%%
for t = 1:M
    for i = 1:sampleN                     %�����ٶȡ�λ��
        v(i,:) = w * v(i,:) + c1 * rand *(y(i,:) - x(i,:)) + c2 * rand *...
          (pg - x(i,:));
        x(i,:) = x(i,:) + v(i,:);
        if fitness(x(i,:)) < p(i)
            p(i) = fitness(x(i,:));     % ��i�����Ӹ��弫ֵ
            y(i,:) = x(i,:);            % �������Ÿ���
        end
        if p(i) < fitness(pg)
            pg = y(i,:);        % ����ȫ������ֵ
        end
    end
    Pbest(t) = fitness(pg);
end
xm = pg';            % ȫ�����Ž�
fv = fitness(pg);    % ���Ž��Ӧ��Ӧ��ֵ