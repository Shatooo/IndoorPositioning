function [output, PRMIN, PRMAX] = normalPR(PR, PRMIN, PRMAX)
%==========================================================================
% ���ܣ�RSSI ֵ��һ��������ʹ��ͶӰ��[0,1]��
% ������PR - RSSIֵ
%       PRMIN - RSSI��Сֵ����������ǰ���Ѽ�������Сֵʱ���롣
%       PRMAX - RSSI���ֵ��
% ����ֵ��output - RSSI��һ�����������0��1֮�䡣
%       PRMIN - RSSI��Сֵ��
%       PRMAX - RSSI���ֵ��
% ���ڣ�20180605
%==========================================================================
if nargin < 3
    PRMAX = max(PR, [], 1);
    PRMIN = min(PR, [], 1);
end

[irow, jcol] = size(PR);
if length(PRMAX) ~= jcol || length(PRMIN) ~= jcol
   PRMAX = PRMAX(1,1) * ones(1, jcol); 
   PRMIN = PRMIN(1,1) * ones(1, jcol); 
end

PRMAX = ones(irow, 1) * PRMAX;
PRMIN = ones(irow, 1) * PRMIN;

output = (PR - PRMIN)./(PRMAX - PRMIN);
output = (PR - max(max(PR))) ./ (max(max(PR)) - min(min(PR)));
end