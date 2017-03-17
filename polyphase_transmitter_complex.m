%% 8路多相滤波信道化软件无线电发射机MATLAB仿真程序
% 复信号输出的多相滤波器信道化发射机
% 最初版本+纠正书上I和1显示错误+精简循环

clear all; clc, close all;
%% 参数初始化
I=8;%8路
fc=(1:I)*0.5;%基带调制频率(kHz)
% fc=8.0*ones(1,I);%基带调制频率(kHz)
Fs=50.0;%零中频采样率
fs=Fs*I;%输出采样率
% K=2.0;%调频指数
R=1.56;%原型低通滤波器矩形系数
signalLen=200;%产生的信号长度

%% 原型滤波器设计--Parks–McClellan算法
[n0,f0,m0,w]=remezord([Fs/(2*R) Fs/2],[1,0],[0.001,0.001],fs);%原型滤波器阶数计算%原型滤波器阶数 - [通带f,阻带f],[通带A,阻带A],[通带波纹,阻带波纹],fs
n0=ceil(n0/I)*I*2;%取I的整数倍，控制长度为2的整数倍，这样滤波延迟比较好计算
b=remez(n0,f0,m0,w);%计算原型滤波器系数

%% 对原型滤波器进行多相分解
h=reshape(b(1:(end-1)),I,[]);%h(k,r)=b((r-1)*I+k);
h=circshift(h,[1,0]);

%% 发射信号产生
for k=1:I%产生I路信号
    t=0:signalLen-1;%采样时刻
    m(k,:)=cos(2*pi*fc(k)/Fs*t+k/pi);%产生0中频正弦信号便于查看效果，每一个通道发射一个正弦信号
end

%% IFFT+相移
for r=1:signalLen %每一路信号包含n1+I个采样点
    mfft=ifft(m(:,r));%对每一个采样时刻的I路信号，计算离散傅立叶反变换
    x0(:,r)=mfft.'.*exp(1j*pi/I*(0:(I-1)));%相移
end

%% 多相滤波+相移
for k=1:I%每一路信号包含n1+I个采样点
    delay=size(h,2)/2-1;%滤波延迟
    y_tmp=I*ifft(fft(x0(k,:),signalLen).*fft(h(k,:),signalLen));
    y_tmp=circshift(y_tmp,[0,-delay]);%时延消除
    y_phase(k,:)=y_tmp;%用于接收端对比
%     subplot(211),plot(1:signalLen,x0(k,:),'bo-',1:signalLen, y_phase(k,:),'r.-')
%     [ft1,pt1]=myPsdCal(x0(k,:),2*pi);
%     [ft2,pt2]=myPsdCal(y_phase(k,:),2*pi);
%     subplot(212),plot(ft1, pt1,'bo-',ft2,pt2,'r.-'),pause
    y(k,:)=y_tmp.*(-1).^(0:signalLen-1);%相移
end
%% 内插I倍后延迟相加排列
yout=y(:);

%% 频谱绘制
% yt=awgn(yout,30,'measured');
yt=yout;%这样取有什么好处呢
f=fs/length(yt)*(1:length(yt));

pComplex=abs(fft(yt));%计算频谱
figure(2);
plot(f,20*log10(pComplex/max(pComplex)));grid on;title('复数信号的频谱');%滤波器幅频特性
ylim([-150,1]);xlabel('f/Hz');ylabel('A/dB');

% save('polyphase_transmitter_complex.mat','yt','m','t','h');