%% 8路多相滤波信道化软件无线电发射机MATLAB仿真程序
% 实信号输出的多相滤波器信道化发射机
% 最初版本+纠正书上I和1显示错误+精简循环

clear all; clc, close all;
%% 参数初始化
I=8;%8路
fc=(1:I)*1;%基带调制频率(kHz)
% fc=2.0*ones(1,I);%基带调制频率(kHz)
Fs=50.0;%零中频采样率
fs=Fs*I*2;%输出采样率---这是和复数信号的区别
K=2.0;%调频指数
R=1.56;%原型低通滤波器矩形系数
signalLen=200;%产生的信号长度

%% 原型滤波器设计--原型滤波器不受2倍升采样的影响
[n0,f0,m0,w]=remezord([Fs/(2*R) Fs/2],[1,0],[0.001,0.001],fs);%原型滤波器阶数 - [通带f,阻带f],[通带A,阻带A],[通带波纹,阻带波纹],fs
N=(n0-mod(n0,I))/I+1;%取I的整数倍
n0=I*N*2;%控制长度为2的整数倍，这样滤波延迟比较好计算
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
for r=1:signalLen%每一路信号包含n1+I个采样点
    mfft=ifft(m(:,r));%对每一个采样时刻的I路信号，计算离散傅立叶反变换
    x0(:,r)=mfft.'.*exp(1j*pi/2/I*(0:(I-1)));%相移
end

%% 升采样，2倍内插
z=zeros(size(x0,1),2*size(x0,2));%内插0
z(:,1:2:end)=x0;%采样点赋值

%% 多相滤波+相移
for k=1:I%每一路信号包含n1+I个采样点
    delay=size(h,2)/2-1;%滤波延迟
    y0=I*conv(z(k,:),h(k,:));%卷积滤波，滤波器增益I才行
    y0=y0((delay+1):(signalLen*2+delay));%延迟消除
%         plot(1:length(z(k,:)),abs(z(k,:)),'k',1:length(y0),abs(y0),'r');legend('原始信号','滤波后信号');pause
    y(k,:)=y0.*exp(1j*pi/2*(0:signalLen*2-1));%相移
end
%% 内插I倍
yout=y(:);
% plot(real(yout),'.-')%不需要滤波就正好是频谱周期搬移的效果了

%% 频谱绘制
% yy=awgn(yout,30,'measured');
yy=yout;%这样取有什么好处呢
f=fs/length(yy)*(1:length(yy));
%对复数信号分析--可见前面增加的2倍抽取实现了将频段间隔延长1倍的功能
pComplex=abs(fft(yy));%计算频谱
figure(2);subplot(2,1,1)
plot(f,20*log10(pComplex/max(pComplex)));grid on;title('复数信号的频谱');%滤波器幅频特性
ylim([-60,0])

%取实部输出的信号分析
yt=real(yy);%取实部
pReal=abs(fft(yt));%计算频谱
figure(2);subplot(2,1,2)
plot(f,20*log10(pReal/max(pReal)));grid on;title('实部信号的频谱');%滤波器幅频特性
ylim([-60,0]);xlabel('f/Hz');ylabel('A/dB');

% save('polyphase_transmitter_real.mat','yt','m','t','h');