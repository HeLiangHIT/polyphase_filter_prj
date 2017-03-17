%% 8路多相滤波信道化软件无线电接收机MATLAB仿真程序
% 实信号输入的多相滤波器信道化接收机

polyphase_transmitter_real;
% clear all; clc, close all;
%% 参数初始化
% I=8;%8路
% fc=(1:I)*1.0;%基带调制频率(kHz)
% % fc=8.0*ones(1,I);%基带调制频率(kHz)
% Fs=50.0;%零中频采样率
% fs=Fs*I*2;%输出采样率
% K=2.0;%调频指数
% R=1.56;%原型低通滤波器矩形系数
% load polyphase_transmitter_real.mat
% signalLen=length(yt)/I/2;%产生的信号长度

%% 输入信号延迟+下采样+相移+多相滤波
yt=reshape(yt,I,[]);%下采样
for k=1:I
    yr(k,:)=I*yt(k,:).*exp(1j*pi/2*(0:signalLen*2-1));%相移
    %多相滤波
	delay=size(h,2)/2;%滤波延迟，前面减1了这里不用减1？？
    x0=I*conv(yr(k,:),h(k,:));%卷积滤波，滤波器增益I才行
    x(k,:)=x0((delay+1):(signalLen*2+delay));%延迟消除
end

%% 下采样2
x=x(:,1:2:end);

% 修改与书上过程不同的地方【【1】】！！
x=circshift(x,[I/2,0]);%为什么这样调整一下会只存在一个相位偏差？？？？？【待解释原因——可能是因为频谱的错位对称】

%% 相移+IFFT
for r=1:signalLen%每一路信号包含n1+I个采样点
    mfft(:,r)=x(:,r).'.*exp(-1j*pi/2/I*(0:(I-1)));%相移
    mhat(:,r)=ifft(mfft(:,r));%对每一个采样时刻的I路信号，计算离散傅立叶反变换
end

%% 解调频率
figure,
for k=1:I%产生I路信号
    %频域去噪
    mf=fft(mhat(k,:));
%     plot(abs(mf)),pause
    thrd_mf=max(abs(mf))/2;%阈值设置
    mf(abs(mf)<thrd_mf)=0;
    %修改与书上原理不同的地方【【2】】！！！
    mhat(k,:)=ifft(mf)*(-1)^k;%还原时域信号，【这里不乘一个(-1)^k的话会存在相位偏差，这个相位偏差是哪儿来的？？？？】
    subplot(4,2,k),plot(t,I*imag(mhat(k,:)),'.-', t,m(k,:),'ro-');legend('接收解调信号','原始发射信号'); 
%     pause()%虚部是cos
end
% 问题：为什么每一个通道都会多一个较低的频点？？？哪儿来的到底！！！艹。。。【跟上面的两处修改之地可以解决这个问题】

