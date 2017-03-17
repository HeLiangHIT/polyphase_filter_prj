%% 8路多相滤波信道化软件无线电接收机MATLAB仿真程序
% 复信号输入的多相滤波器信道化接收机
% 问题：
% 1、未知信号功率在何处减小了？%--暂且在信号下采样的地方将其放大。
% 2、信号还原后相位为什么偏移了？--猜测可能是发射或者接收机哪一个地方的相位没有乘对。
% 3、为什么接收到的m通道和发射的m通道之间相反了？%--暂且在下采样后翻转一下yr=flipud(yr);

polyphase_transmitter_complex;
% clear all; clc, close all;
%% 参数初始化
% I=8;%8路
% fc=(1:I)*0.5;%基带调制频率(kHz)
% % fc=8.0*ones(1,I);%基带调制频率(kHz)
% Fs=50.0;%零中频采样率
% fs=Fs*I;%输出采样率
% R=1.56;%原型低通滤波器矩形系数
% load polyphase_transmitter_complex.mat
% signalLen=length(yt)/I;%产生的信号长度

% h=fliplr(h);%匹配滤波是否需要？

%% 输入信号延迟+下采样+相移+多相滤波
for k=1:I
    yr(k,:)=yt(k:I:end).'.*(-1).^(0:signalLen-1);%相移，与发射的y0相同
	% 多相滤波
    delay=size(h,2)/2;%滤波延迟，前面减1了这里不用减1？？
    x_tmp=I*ifft(fft(yr(k,:),signalLen).*fft(h(k,:),signalLen));%滤波
    x(k,:)=circshift(x_tmp,[0,-delay]);%时延消除
%     plot(1:signalLen,yr(k,:),'bo-',1:signalLen,x(k,:),'r.-')
end

%% 相移+IFFT
for r=1:signalLen%每一路信号包含n1+I个采样点
    mfft(:,r)=x(:,r).'.*exp(-1j*pi/I*(0:(I-1)));%相移
    mhat(:,r)=ifft(mfft(:,r));%对每一个采样时刻的I路信号，计算离散傅立叶反变换
end

%% 解调频率
figure,
% 修改与书上原理不同的地方【【1】】！！！
index=[1,I:-1:2];%为什么通道的对应顺序是这样的呢？某个地方的相位错误了吧！！【有空慢慢找，先这样凑事】
for k=1:I%产生I路信号
    %频域去噪
    mf=fft(mhat(k,:));
    thrd_mf=max(abs(mf))/2;%阈值设置
    mf(abs(mf)<thrd_mf)=0;
    mhat(k,:)=ifft(mf);%还原时域信号
    subplot(4,2,k);plot(t,I*real(mhat(index(k),:)),'.-', t,m(k,:),'ro-');legend('接收解调信号','原始发射信号');% pause()%虚部是cos
end
%I=4时1-1,2-4,3-3,4-2
% I=8时1-1,2-8,3-7,4-6,5-5...