function [error] = RBFILS(PosTag,TrainInput, TestInput,NumberOfHidden, PosTestTag)
AmtTag = size(TrainInput, 1);
AmtTestTag = size(TestInput, 1);
%%%%%%%%%%%%%ѵ������%%%%%%%%%%%%%%%%%%%%%%%%%
N_cluster = NumberOfHidden;        
%%%%%%%%%%%%%������������%%%%%%%%%%%%%%%%%%%%%
[center,U,obj_fcn] = fcm(TrainInput,N_cluster); %ģ������ȷ������ֵ
%ȷ����Ԫ��ȣ���RBF������������ĵ�ƽ����ȡ�
for i = 1:N_cluster
    eucenter=0;
    for j = 1:N_cluster
        if i~=j
            eucenter = eucenter+norm(center(i,:)-center(j,:));           
        end
    end
    rbfvar(i,1)=mean(eucenter);
end

%%%%%%%%%%%%%�������Ȩ��%%%%%%%%%%%%%%%%%%%%%
for i = 1:N_cluster
    for k = 1:AmtTag
        G(k,i) = exp((-1/(2*rbfvar(i,1)^2))*norm(TrainInput(k,:)-center(i,:)).^2);
    end
end
rbfweight = pinv(G)*(PosTag);
%%%%%%%%%%%%%����ѵ�����%%%%%%%%%%%%%%%%%%%%%
for k = 1:AmtTag
    tempy1=0;
    tempy2=0;
    for i = 1:N_cluster
        tempy1 = rbfweight(i,1).*exp((-1/(2*rbfvar(i,1)^2))*...
            norm(TrainInput(k,:)-center(i,:)).^2)+tempy1;
        tempy2 = rbfweight(i,2).*exp((-1/(2*rbfvar(i,1)^2))*...
            norm(TrainInput(k,:)-center(i,:)).^2)+tempy2;
    end
    y(k,1)= tempy1; %ѵ�����
    y(k,2)= tempy2;
end
eutemp=0;

%%%%%%%%%%%%%����������%%%%%%%%%%%%%%%%%%%%
for k = 1:AmtTestTag
    tempy1=0;
    tempy2=0;
    for i = 1:N_cluster
        tempy1 = rbfweight(i,1).*exp((-1/(2*rbfvar(i,1).^2))*...
            norm(TestInput(k,:)-center(i,:)).^2)+tempy1;
        tempy2 = rbfweight(i,2).*exp((-1/(2*rbfvar(i,1).^2))*...
            norm(TestInput(k,:)-center(i,:)).^2)+tempy2;
    end
    resrbf1(k,1)= tempy1;
    resrbf1(k,2)= tempy2;
end

% ������ʧֵ
error(1,1) = calLoss(AmtTag, y, PosTag); % ѵ�����
error(1,2) = calLoss(AmtTestTag, resrbf1, PosTestTag); % �������

% [best_ab,best_fval]=...
%     optainet(center,N_cluster,AmtTag,TrainInput,PosTag,AmtTag,TrainInput,...
%     PosTag,AmtTestTag,TestInput,PosTestTag);
%  %�����ſ���ȷ��RBF����
%         center=reshape(best_ab,dimension ,N_cluster)';
%          %ȷ����Ԫ��ȣ���RBF������������ĵ�ƽ����ȡ�
%         for i = 1:N_cluster
%             eucenter=0;
%             for j = 1:N_cluster
%                 if i~=j
%                     eucenter = eucenter+norm(center(i,:)-center(j,:));           
%                 end
%             end
%             rbfvar(i,2)=mean(eucenter);
%         end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ͨ��α��ȷ��Ȩֵ%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         for i = 1:(N_cluster)
%             for k = 1:AmtTag
%                 G(k,i) = exp((-1/(2*rbfvar(i,2)^2))*norm(TrainInput(k,:)-center(i,:)).^2);
%             end
%         end
%         rbfweight = pinv(G)*(PosTag);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%ѵ�����ʹ��������%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %-----------------%
%         %��һ��RBF�������-----------------------%
%         for k = 1:AmtTestTag
%             tempy1=0;
%             tempy2=0;
%             for i = 1:N_cluster
%                 tempy1 = rbfweight(i,1).*exp((-1/(2*rbfvar(i,2)^2))*...
%                     norm(TestInput(k,:)-center(i,:)).^2)+tempy1;
%                 tempy2 = rbfweight(i,2).*exp((-1/(2*rbfvar(i,2)^2))*...
%                     norm(TestInput(k,:)-center(i,:)).^2)+tempy2;
%             end
%             resrbf2(k,1)= tempy1;   %���Լ�ʵ��������
%             resrbf2(k,2)= tempy2;
%         end
%         error(1,2) = calLoss(AmtTestTag, resrbf2, PosTestTag);