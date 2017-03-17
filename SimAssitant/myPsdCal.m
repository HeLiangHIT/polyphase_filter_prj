function [f,pf]=myPsdCal(s,fs,N)
%计算功率谱密度dB，输入必须是一维的数据。
%% 周期图法
pf=abs(fftshift(fft(s)));
pf=pf/max(pf);
pf=20*log10(pf);
f=linspace(-fs/2,fs/2,length(s));

% WELCH法
% LenWin=N;
% window=blackman(LenWin); %blackman窗 
% noverlap=round(N/2); %数据无重叠  
% range='centered'; %'onesided'  | 'twosided' | 'centered'
% [pf,f]=pwelch(s,window,noverlap,N,fs,range); 
% pf=10*log10(pf/max(pf));


end