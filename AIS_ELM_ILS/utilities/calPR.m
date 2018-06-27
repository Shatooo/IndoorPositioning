function [PR, PR_Test] = calPR(NumberofTag, NumberofTestTag, ...
    NumberofReader, d_RT, d_RTT, Para)
PT = Para(1);
Pd0 = Para(2); 
d0 = Para(3);
n = Para(4);
sigma = Para(5);
N = Para(6);
PR = zeros(NumberofTag, NumberofReader, N);
PR_Test = zeros(NumberofTestTag, NumberofReader, N);
for j = 1:N
    AddGauss=sigma * randn(NumberofTag+NumberofTestTag, NumberofReader);
    PR(:,:,j)=PT-(Pd0+10.*n.*log10(d_RT./d0)+AddGauss(1:NumberofTag,:));
    PR_Test(:,:,j) = PT - (Pd0 + 10.*n.*log10(d_RTT./d0)+...
        AddGauss(NumberofTag+1:end,:));
end
end