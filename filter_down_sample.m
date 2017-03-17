%% 降采样的原始滤波结构
% 理论上fs>8e3，D=8时需要先进行fs/2/8=500的抗混叠滤波器才行，我们试试将滤波器使用多相滤波结构放在下采样之后执行。

clear all; clc, close all;
%% 参数初始化
fs=8e3;%原始信号采样率
fc=[5e2,11.5e2,14e2];%信号频点，必须混叠内和外各有一个信号
p=[0,0,pi/2];%信号初始相位
a=[1,1,0.8];%信号幅度
D=4;%8倍抽取器
deAddF=[600,1000];%抗混叠滤波器通带阻带
% deAddF=[fs/2/D/1.5,fs/2/D];%抗混叠滤波器通带阻带
phaseLen=512;%各相长度
signalLen=D*phaseLen;

%% 信号产生
[t,s]=cosSignalGen(fc,p,a,fs,signalLen);%plot(t,s,'.-') %采样1s产生叠加信号
x=awgn(s,100,'measured');%叠加噪声

%% 原型滤波器设计--Parks–McClellan算法
[n0,f0,m0,w]=remezord(deAddF,[1,0],[0.001,0.001],fs);%原型滤波器阶数计算%原型滤波器阶数 - [通带f,阻带f],[通带A,阻带A],[通带波纹,阻带波纹],fs
n0=ceil(n0/D)*D*2;%取I的整数倍，控制长度为2的整数倍，这样滤波延迟比较好计算
b=remez(n0,f0,m0,w);%计算原型滤波器系数

%% 信号频谱和滤波器响应
figure(1),subplot(311),title('信号频谱和滤波器响应');
[sf,sp]=myPsdCal(s,fs,length(s)); %计算叠加信号的功率谱
[bf,bp]=myPsdCal(b,fs,length(b));%计算滤波器幅频响应
plot(sf,sp,'bo-',bf,bp,'r.-'), legend('信号频谱','滤波器幅频响应');
xlabel('f/Hz');ylabel('A/dB');axis tight;

%% 对信号进行直接频域滤波
N=length(x);
delay=round(length(b)/2)-1;%滤波延迟
% y1=ifft(fft(x,N).*fft(b,N));%频域滤波
y1=conv(x,b);%频域滤波
y1=circshift(y1,[0,-delay]);
y1=y1(1:length(t));

%% 直接抽取信号
yd=y1(1:D:end);
td=(0:phaseLen-1)/fs*D;

%% 绘图
Point=64;
figure(1),subplot(312),title('原始抽取各阶段的信号');
plot(t(1:Point*D),x(1:Point*D),'k.-',t(1:Point*D),y1(1:Point*D),'b+',td(1:Point),yd(1:Point),'ro-');legend('滤波前','直接滤波后','抽取后');
xlabel('t/s');ylabel('A/v');axis tight;

figure(1),subplot(313),title('原始信号和下采样信号频谱');
[xf,xp]=myPsdCal(x,fs,length(x)); %计算原始信号的功率谱
[yf,yp]=myPsdCal(y1,fs,length(y1));%计算直接滤波后信号的功率谱
[ydf,ydp]=myPsdCal(yd,fs/D,length(yd));%计算多相滤波后信号的功率谱
plot(xf,xp,'kp-',yf,yp,'ro-',ydf,ydp,'b+-'), 
legend('原始信号功率谱','滤波后的功率谱','抽取后的功率谱');
xlabel('f/Hz');ylabel('A/dB');axis tight;